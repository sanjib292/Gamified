import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import OpenAI from "https://esm.sh/openai@4";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

const DEFAULT_LIMIT = 10;

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { userId, limit = DEFAULT_LIMIT }: { userId: string; limit?: number } =
      await req.json();

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

    const openai = new OpenAI({ apiKey: Deno.env.get("OPENAI_API_KEY")! });

    // Fetch user AI profile for topic interests and learning style
    const { data: aiProfile } = await supabase
      .from("user_ai_profiles")
      .select("preferred_topics, learning_style, interest_embedding")
      .eq("user_id", userId)
      .single();

    const preferredTopics: string[] = aiProfile?.preferred_topics ?? [];
    const learningStyle: string = aiProfile?.learning_style ?? "visual";

    // Fetch recent lesson activity to infer current interests
    const { data: recentActivity } = await supabase
      .from("user_lesson_progress")
      .select("lesson_id, lessons(title, key_concepts, book_id)")
      .eq("user_id", userId)
      .order("last_accessed_at", { ascending: false })
      .limit(5);

    // Collect completed book IDs to filter them out
    const { data: completedBooks } = await supabase
      .from("user_book_progress")
      .select("book_id")
      .eq("user_id", userId)
      .eq("status", "completed");

    const completedBookIds = new Set(
      (completedBooks ?? []).map((b: { book_id: string }) => b.book_id)
    );

    // Build query text from user interests and recent activity
    const recentTopics: string[] = [];
    for (const activity of recentActivity ?? []) {
      const lesson = (activity as { lessons?: { title?: string; key_concepts?: string[] | string } }).lessons;
      if (lesson?.title) recentTopics.push(lesson.title);
      if (lesson?.key_concepts) {
        const concepts = Array.isArray(lesson.key_concepts)
          ? lesson.key_concepts
          : [lesson.key_concepts];
        recentTopics.push(...concepts);
      }
    }

    const queryParts = [
      ...preferredTopics,
      ...recentTopics,
      learningStyle ? `${learningStyle} learning` : "",
    ].filter(Boolean);

    let queryVector: number[];

    if (aiProfile?.interest_embedding && Array.isArray(aiProfile.interest_embedding)) {
      // Use stored user interest embedding if available
      queryVector = aiProfile.interest_embedding;
    } else if (queryParts.length > 0) {
      // Generate embedding from user interests
      const queryText = queryParts.join(", ");
      const embeddingResponse = await openai.embeddings.create({
        model: "text-embedding-3-small",
        input: queryText,
      });
      queryVector = embeddingResponse.data[0].embedding;
    } else {
      // Fallback: no interests known, return popular books
      const { data: popularBooks } = await supabase
        .from("books")
        .select("id, title")
        .not("id", "in", `(${[...completedBookIds].join(",") || "null"})`)
        .order("enrolled_count", { ascending: false })
        .limit(limit);

      const recommendations = (popularBooks ?? []).map((b: { id: string; title: string }, i: number) => ({
        book_id: b.id,
        score: 1 - i * 0.05,
        reason: "Popular among learners",
      }));

      return new Response(JSON.stringify({ recommendations }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Query embeddings table using pgvector similarity search via RPC
    const { data: similarEmbeddings, error: rpcError } = await supabase.rpc(
      "match_embeddings",
      {
        query_embedding: queryVector,
        match_threshold: 0.5,
        match_count: limit * 3, // Overfetch to allow filtering
        filter_source_type: "book",
      }
    );

    if (rpcError) {
      console.error("pgvector RPC error:", rpcError);
      throw rpcError;
    }

    // Filter out completed books and deduplicate
    const seenBookIds = new Set<string>();
    const filteredResults = (similarEmbeddings ?? [])
      .filter((r: { source_id: string; similarity: number }) => {
        if (completedBookIds.has(r.source_id)) return false;
        if (seenBookIds.has(r.source_id)) return false;
        seenBookIds.add(r.source_id);
        return true;
      })
      .slice(0, limit);

    // Build reason strings based on topic overlap
    const recommendations = filteredResults.map(
      (r: { source_id: string; similarity: number; content_text?: string }) => {
        const overlap = preferredTopics.filter((t) =>
          (r.content_text ?? "").toLowerCase().includes(t.toLowerCase())
        );
        const reason =
          overlap.length > 0
            ? `Matches your interest in ${overlap.slice(0, 2).join(" and ")}`
            : "Recommended based on your learning profile";

        return {
          book_id: r.source_id,
          score: Math.round(r.similarity * 1000) / 1000,
          reason,
        };
      }
    );

    // Delete old recommendations for this user and insert fresh ones
    await supabase.from("book_recommendations").delete().eq("user_id", userId);

    if (recommendations.length > 0) {
      const now = new Date().toISOString();
      await supabase.from("book_recommendations").insert(
        recommendations.map((r: { book_id: string; score: number; reason: string }) => ({
          user_id: userId,
          book_id: r.book_id,
          score: r.score,
          reason: r.reason,
          created_at: now,
        }))
      );
    }

    return new Response(
      JSON.stringify({ recommendations, count: recommendations.length }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("recommend-books error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
