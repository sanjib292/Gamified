import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

const CHALLENGE_XP = 50;

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  try {
    if (req.method === "GET") {
      // Return today's active challenge
      const now = new Date().toISOString();

      const { data: challenges, error } = await supabase
        .from("lesson_content")
        .select(
          "id, lesson_id, content, sort_order, lessons(id, title, book_id)"
        )
        .eq("content_type", "challenge")
        .lte("content->>opens_at", now)
        .gte("content->>closes_at", now)
        .order("sort_order", { ascending: true })
        .limit(1);

      if (error) throw error;

      if (!challenges || challenges.length === 0) {
        return new Response(
          JSON.stringify({ challenge: null, message: "No active challenge today." }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const challenge = challenges[0];

      return new Response(
        JSON.stringify({
          challenge: {
            id: challenge.id,
            lesson_id: challenge.lesson_id,
            content: challenge.content,
            lesson: challenge.lessons,
          },
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (req.method === "POST") {
      const {
        userId,
        lessonId,
        submission,
      }: {
        userId: string;
        lessonId: string;
        submission: unknown;
      } = await req.json();

      if (!userId || !lessonId || submission === undefined) {
        return new Response(
          JSON.stringify({ error: "userId, lessonId, and submission are required" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Fetch the active challenge for this lesson
      const now = new Date().toISOString();
      const { data: challenges, error: fetchError } = await supabase
        .from("lesson_content")
        .select("id, content, content_type")
        .eq("lesson_id", lessonId)
        .eq("content_type", "challenge")
        .lte("content->>opens_at", now)
        .gte("content->>closes_at", now)
        .limit(1);

      if (fetchError) throw fetchError;

      if (!challenges || challenges.length === 0) {
        return new Response(
          JSON.stringify({ error: "No active challenge found for this lesson" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const challenge = challenges[0];
      const challengeContent = challenge.content as Record<string, unknown>;

      // Check if user already submitted today
      const today = new Date().toISOString().split("T")[0];
      const { data: existingAttempt } = await supabase
        .from("challenge_attempts")
        .select("id, xp_awarded")
        .eq("user_id", userId)
        .eq("challenge_id", challenge.id)
        .gte("created_at", `${today}T00:00:00.000Z`)
        .limit(1);

      if (existingAttempt && existingAttempt.length > 0) {
        return new Response(
          JSON.stringify({
            challenge,
            submission_received: false,
            xp_awarded: 0,
            message: "You already submitted today's challenge.",
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Auto-evaluate quiz-type challenges
      let isCorrect: boolean | null = null;
      let xpAwarded = 0;
      const challengeType = challengeContent?.type as string | undefined;

      if (challengeType === "quiz" || challengeType === "multiple_choice") {
        const correctAnswer = challengeContent?.correct_answer;
        if (correctAnswer !== undefined) {
          isCorrect =
            JSON.stringify(submission) === JSON.stringify(correctAnswer) ||
            String(submission).toLowerCase() === String(correctAnswer).toLowerCase();
        }
      }

      // Award XP: full XP for correct, partial for participation on non-auto-evaluable types
      if (isCorrect === true) {
        xpAwarded = CHALLENGE_XP;
      } else if (isCorrect === null) {
        // Manual review needed — award participation XP
        xpAwarded = Math.floor(CHALLENGE_XP * 0.2);
      }

      const attemptNow = new Date().toISOString();

      // Record attempt
      await supabase.from("challenge_attempts").insert({
        user_id: userId,
        challenge_id: challenge.id,
        lesson_id: lessonId,
        submission,
        is_correct: isCorrect,
        xp_awarded: xpAwarded,
        requires_review: isCorrect === null,
        created_at: attemptNow,
      });

      // Award XP if applicable
      if (xpAwarded > 0) {
        await supabase.from("xp_logs").insert({
          user_id: userId,
          amount: xpAwarded,
          source_type: "challenge",
          source_id: challenge.id,
          description:
            isCorrect === true
              ? "Daily challenge completed correctly"
              : "Daily challenge participation",
          created_at: attemptNow,
        });
      }

      return new Response(
        JSON.stringify({
          challenge: { id: challenge.id, content: challengeContent },
          submission_received: true,
          is_correct: isCorrect,
          xp_awarded: xpAwarded,
          requires_review: isCorrect === null,
          message:
            isCorrect === true
              ? `Challenge complete! +${xpAwarded} XP`
              : isCorrect === false
              ? "Not quite — review the lesson and try again tomorrow."
              : `Submission received. +${xpAwarded} XP for participating.`,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("daily-challenge error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
