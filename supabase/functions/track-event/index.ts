import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

const MAX_BATCH_SIZE = 100;

interface AnalyticsEvent {
  event_name: string;
  properties?: Record<string, unknown>;
  session_id?: string;
  platform?: string;
  app_version?: string;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { events }: { events: AnalyticsEvent[] } = await req.json();

    if (!Array.isArray(events) || events.length === 0) {
      return new Response(
        JSON.stringify({ error: "events must be a non-empty array" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (events.length > MAX_BATCH_SIZE) {
      return new Response(
        JSON.stringify({
          error: `Batch size exceeds maximum of ${MAX_BATCH_SIZE} events. Received: ${events.length}`,
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate each event has a required event_name
    const invalidEvents = events.filter(
      (e) => !e.event_name || typeof e.event_name !== "string"
    );
    if (invalidEvents.length > 0) {
      return new Response(
        JSON.stringify({
          error: `${invalidEvents.length} event(s) are missing a valid event_name`,
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Extract user ID from the Authorization header via Supabase auth
    const authHeader = req.headers.get("Authorization");
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    let userId: string | null = null;
    if (authHeader) {
      const token = authHeader.replace("Bearer ", "");
      const { data: { user } } = await supabase.auth.getUser(token);
      userId = user?.id ?? null;
    }

    const now = new Date().toISOString();

    const rows = events.map((event) => ({
      user_id: userId,
      event_name: event.event_name,
      properties: event.properties ?? {},
      session_id: event.session_id ?? null,
      platform: event.platform ?? null,
      app_version: event.app_version ?? null,
      created_at: now,
    }));

    const { error: insertError } = await supabase
      .from("analytics_events")
      .insert(rows);

    if (insertError) {
      throw insertError;
    }

    return new Response(
      JSON.stringify({ inserted: rows.length }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("track-event error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
