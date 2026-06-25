import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import OpenAI from "https://esm.sh/openai@4";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

type SourceType = "book" | "lesson" | "lesson_content";

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { sourceType, sourceId }: { sourceType: SourceType; sourceId: string } =
      await req.json();

    if (!sourceType || !sourceId) {
      return new Response(
        JSON.stringify({ error: "sourceType and sourceId are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const validSourceTypes: SourceType[] = ["book", "lesson", "lesson_content"];
    if (!validSourceTypes.includes(sourceType)) {
      return new Response(
        JSON.stringify({ error: `sourceType must be one of: ${validSourceTypes.join(", ")}` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const openai = new OpenAI({ apiKey: Deno.env.get("OPENAI_API_KEY")! });

    let contentText = "";

    if (sourceType === "book") {
      const { data: book, error } = await supabase
        .from("books")
        .select("title, description")
        .eq("id", sourceId)
        .single();

      if (error || !book) {
        return new Response(
          JSON.stringify({ error: "Book not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      contentText = `[BOOK: ${book.title}]\n${book.description ?? ""}`.trim();
    } else if (sourceType === "lesson") {
      const { data: lesson, error } = await supabase
        .from("lessons")
        .select("title, key_concepts, summary, book_id")
        .eq("id", sourceId)
        .single();

      if (error || !lesson) {
        return new Response(
          JSON.stringify({ error: "Lesson not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Fetch associated book title for context prefix
      let bookTitle = "";
      if (lesson.book_id) {
        const { data: book } = await supabase
          .from("books")
          .select("title")
          .eq("id", lesson.book_id)
          .single();
        bookTitle = book?.title ?? "";
      }

      const concepts = Array.isArray(lesson.key_concepts)
        ? lesson.key_concepts.join(", ")
        : lesson.key_concepts ?? "";

      const prefix = bookTitle ? `[BOOK: ${bookTitle}] ` : "";
      contentText = `${prefix}${lesson.title}\n${concepts}\n${lesson.summary ?? ""}`.trim();
    } else if (sourceType === "lesson_content") {
      const { data: content, error } = await supabase
        .from("lesson_content")
        .select("content, lesson_id")
        .eq("id", sourceId)
        .single();

      if (error || !content) {
        return new Response(
          JSON.stringify({ error: "Lesson content not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Fetch parent lesson for context
      let lessonTitle = "";
      let bookTitle = "";
      if (content.lesson_id) {
        const { data: lesson } = await supabase
          .from("lessons")
          .select("title, book_id")
          .eq("id", content.lesson_id)
          .single();
        lessonTitle = lesson?.title ?? "";

        if (lesson?.book_id) {
          const { data: book } = await supabase
            .from("books")
            .select("title")
            .eq("id", lesson.book_id)
            .single();
          bookTitle = book?.title ?? "";
        }
      }

      // Extract text from JSONB content
      const rawContent = content.content;
      let extractedText = "";
      if (typeof rawContent === "string") {
        extractedText = rawContent;
      } else if (rawContent && typeof rawContent === "object") {
        // Extract text fields from JSONB content structure
        const textParts: string[] = [];
        const extract = (obj: unknown): void => {
          if (typeof obj === "string") {
            textParts.push(obj);
          } else if (Array.isArray(obj)) {
            obj.forEach(extract);
          } else if (obj && typeof obj === "object") {
            Object.values(obj as Record<string, unknown>).forEach(extract);
          }
        };
        extract(rawContent);
        extractedText = textParts.join(" ");
      }

      const prefix = bookTitle ? `[BOOK: ${bookTitle}] ` : "";
      contentText = `${prefix}${lessonTitle}\n${extractedText}`.trim();
    }

    if (!contentText) {
      return new Response(
        JSON.stringify({ error: "No content available to embed" }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Generate embedding
    const embeddingModel = "text-embedding-3-small";
    const embeddingResponse = await openai.embeddings.create({
      model: embeddingModel,
      input: contentText,
    });

    const embedding = embeddingResponse.data[0].embedding;

    // Upsert to embeddings table
    const { error: upsertError } = await supabase
      .from("embeddings")
      .upsert(
        {
          source_type: sourceType,
          source_id: sourceId,
          content_text: contentText,
          embedding,
          model: embeddingModel,
          updated_at: new Date().toISOString(),
        },
        { onConflict: "source_type,source_id" }
      );

    if (upsertError) {
      throw upsertError;
    }

    return new Response(
      JSON.stringify({
        success: true,
        sourceType,
        sourceId,
        model: embeddingModel,
        contentLength: contentText.length,
        dimensions: embedding.length,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("generate-embedding error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
