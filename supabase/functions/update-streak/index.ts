import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

const MAX_FREEZES = 3;

function toDateString(date: Date): string {
  return date.toISOString().split("T")[0]; // YYYY-MM-DD
}

function dayDiff(a: string, b: string): number {
  const msPerDay = 24 * 60 * 60 * 1000;
  const dateA = new Date(a).getTime();
  const dateB = new Date(b).getTime();
  return Math.round(Math.abs(dateA - dateB) / msPerDay);
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { userId }: { userId: string } = await req.json();

    if (!userId) {
      return new Response(
        JSON.stringify({ error: "userId is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const today = toDateString(new Date());

    // Fetch current streak record
    const { data: streakRecord, error: fetchError } = await supabase
      .from("streaks")
      .select(
        "id, user_id, current_streak, last_activity_date, freeze_count, max_freezes, longest_streak"
      )
      .eq("user_id", userId)
      .single();

    if (fetchError && fetchError.code !== "PGRST116") {
      // PGRST116 = no rows found
      throw fetchError;
    }

    // No streak record exists — create initial record
    if (!streakRecord) {
      await supabase.from("streaks").insert({
        user_id: userId,
        current_streak: 1,
        last_activity_date: today,
        freeze_count: 0,
        max_freezes: MAX_FREEZES,
        longest_streak: 1,
      });

      await supabase.from("xp_logs").insert({
        user_id: userId,
        amount: 5,
        source_type: "streak",
        description: "First day streak started",
        created_at: new Date().toISOString(),
      });

      return new Response(
        JSON.stringify({
          streak: 1,
          bonusXp: 5,
          freezeUsed: false,
          message: "Streak started! Welcome aboard.",
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const {
      current_streak: currentStreak,
      last_activity_date: lastActivityDate,
      freeze_count: freezeCount,
      max_freezes: maxFreezes,
      longest_streak: longestStreak,
    } = streakRecord;

    // Already recorded today — no change
    if (lastActivityDate === today) {
      return new Response(
        JSON.stringify({
          streak: currentStreak,
          bonusXp: 0,
          freezeUsed: false,
          message: "Already recorded for today.",
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const gap = dayDiff(lastActivityDate, today);
    let newStreak = currentStreak;
    let bonusXp = 0;
    let freezeUsed = false;
    let message = "";
    let newFreezeCount = freezeCount;

    if (gap === 1) {
      // Consecutive day — extend streak
      newStreak = currentStreak + 1;
      bonusXp = 5 * Math.min(newStreak, 10);
      message = `Streak extended to ${newStreak} days! +${bonusXp} XP`;
    } else if (gap > 1 && freezeCount > 0) {
      // Gap but freeze available — use freeze, keep streak
      newFreezeCount = freezeCount - 1;
      freezeUsed = true;
      newStreak = currentStreak + 1;
      bonusXp = 5 * Math.min(newStreak, 10);
      message = `Streak shield used! Streak maintained at ${newStreak} days. ${newFreezeCount} shield(s) remaining.`;
    } else {
      // Gap and no freeze — reset streak
      newStreak = 1;
      bonusXp = 5;
      message = "Streak reset. Starting fresh — keep going!";
    }

    // Check for 7-day milestone freeze award
    const prevMilestone = Math.floor(currentStreak / 7);
    const newMilestone = Math.floor(newStreak / 7);
    if (newMilestone > prevMilestone && newStreak % 7 === 0) {
      newFreezeCount = Math.min(newFreezeCount + 1, maxFreezes ?? MAX_FREEZES);
      message += ` 7-day milestone reached — streak shield earned!`;
    }

    const newLongest = Math.max(longestStreak ?? 0, newStreak);
    const now = new Date().toISOString();

    // Update streak record
    await supabase
      .from("streaks")
      .update({
        current_streak: newStreak,
        last_activity_date: today,
        freeze_count: newFreezeCount,
        longest_streak: newLongest,
        updated_at: now,
      })
      .eq("user_id", userId);

    // Update streak on profile as well
    await supabase
      .from("profiles")
      .update({ streak: newStreak })
      .eq("id", userId);

    // Insert XP log if XP awarded
    if (bonusXp > 0) {
      await supabase.from("xp_logs").insert({
        user_id: userId,
        amount: bonusXp,
        source_type: "streak",
        description: freezeUsed
          ? `Streak shield used — day ${newStreak} streak XP`
          : `Day ${newStreak} streak bonus`,
        created_at: now,
      });
    }

    return new Response(
      JSON.stringify({
        streak: newStreak,
        bonusXp,
        freezeUsed,
        freezeCount: newFreezeCount,
        longestStreak: newLongest,
        message,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("update-streak error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
