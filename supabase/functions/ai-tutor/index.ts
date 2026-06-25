import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import OpenAI from "https://esm.sh/openai@4";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { conversationId, message, lessonId, bookId, userId } =
      await req.json();

    if (!conversationId || !message || !userId) {
      return new Response(
        JSON.stringify({ error: "conversationId, message, and userId are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const openai = new OpenAI({ apiKey: Deno.env.get("OPENAI_API_KEY")! });

    // Fetch last 10 messages for conversation context
    const { data: recentMessages } = await supabase
      .from("ai_messages")
      .select("role, content")
      .eq("conversation_id", conversationId)
      .order("created_at", { ascending: false })
      .limit(10);

    const conversationHistory = (recentMessages ?? []).reverse();

    // Fetch lesson data if provided
    let lessonContext = "";
    if (lessonId) {
      const { data: lesson } = await supabase
        .from("lessons")
        .select("title, key_concepts")
        .eq("id", lessonId)
        .single();
      if (lesson) {
        const concepts = Array.isArray(lesson.key_concepts)
          ? lesson.key_concepts.join(", ")
          : lesson.key_concepts ?? "";
        lessonContext = `\nCurrent Lesson: "${lesson.title}"\nKey Concepts: ${concepts}`;
      }
    }

    // Fetch book data if provided
    let bookContext = "";
    if (bookId) {
      const { data: book } = await supabase
        .from("books")
        .select("title, author")
        .eq("id", bookId)
        .single();
      if (book) {
        bookContext = `\nBook: "${book.title}" by ${book.author}`;
      }
    }

    // Fetch user profile
    const { data: userProfile } = await supabase
      .from("profiles")
      .select("display_name, level, level_title, streak")
      .eq("id", userId)
      .single();

    // Fetch user AI profile
    const { data: aiProfile } = await supabase
      .from("user_ai_profiles")
      .select("learning_style, weak_areas")
      .eq("user_id", userId)
      .single();

    const userName = userProfile?.display_name ?? "Learner";
    const userLevel = userProfile?.level ?? 1;
    const levelTitle = userProfile?.level_title ?? "";
    const streak = userProfile?.streak ?? 0;
    const learningStyle = aiProfile?.learning_style ?? "visual";
    const weakAreas: string[] = aiProfile?.weak_areas ?? [];

    const systemPrompt = `You are an expert AI tutor for MindQuest, a gamified learning platform. Your name is Quest.

About the learner:
- Name: ${userName}
- Level: ${userLevel}${levelTitle ? ` (${levelTitle})` : ""}
- Current streak: ${streak} days
- Learning style: ${learningStyle}
${weakAreas.length > 0 ? `- Areas to strengthen: ${weakAreas.join(", ")}` : ""}
${bookContext}
${lessonContext}

Adapt your explanations to a ${learningStyle} learner. Be encouraging, concise, and engaging. When the learner struggles, break concepts into smaller steps. Celebrate progress and streaks. If discussing weak areas, be especially patient and thorough. Always respond in a conversational, supportive tone that fits the gamified learning context.`;

    const messages: OpenAI.Chat.ChatCompletionMessageParam[] = [
      { role: "system", content: systemPrompt },
      ...conversationHistory.map((m: { role: string; content: string }) => ({
        role: m.role as "user" | "assistant",
        content: m.content,
      })),
      { role: "user", content: message },
    ];

    // Stream response from OpenAI
    const stream = await openai.chat.completions.create({
      model: "gpt-4o",
      messages,
      stream: true,
    });

    let fullResponse = "";

    const readable = new ReadableStream({
      async start(controller) {
        const encoder = new TextEncoder();
        try {
          for await (const chunk of stream) {
            const delta = chunk.choices[0]?.delta?.content ?? "";
            if (delta) {
              fullResponse += delta;
              controller.enqueue(encoder.encode(delta));
            }
          }
        } catch (err) {
          controller.error(err);
          return;
        }

        controller.close();

        // Persist messages after streaming completes
        const now = new Date().toISOString();

        await supabase.from("ai_messages").insert([
          {
            conversation_id: conversationId,
            role: "user",
            content: message,
            created_at: now,
          },
          {
            conversation_id: conversationId,
            role: "assistant",
            content: fullResponse,
            created_at: now,
          },
        ]);

        // Update conversation metadata
        await supabase
          .from("ai_conversations")
          .update({
            last_message_at: now,
            message_count: supabase.rpc("increment_message_count", {
              conv_id: conversationId,
            }),
          })
          .eq("id", conversationId);
      },
    });

    return new Response(readable, {
      headers: {
        ...corsHeaders,
        "Content-Type": "text/plain; charset=utf-8",
        "Transfer-Encoding": "chunked",
        "X-Content-Type-Options": "nosniff",
      },
    });
  } catch (error) {
    console.error("ai-tutor error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
