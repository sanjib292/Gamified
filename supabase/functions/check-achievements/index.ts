import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

interface Achievement {
  id: string;
  name: string;
  description: string;
  condition_type: string;
  condition_value: number | string;
  xp_reward: number;
  icon_url?: string;
  badge_color?: string;
}

interface UserStats {
  lessons_completed: number;
  books_completed: number;
  level: number;
  streak: number;
  quiz_perfect_count: number;
}

function evaluateCondition(
  achievement: Achievement,
  stats: UserStats
): boolean {
  const { condition_type, condition_value } = achievement;
  const numericValue =
    typeof condition_value === "number"
      ? condition_value
      : parseFloat(String(condition_value));

  switch (condition_type) {
    case "lessons_gte":
      return stats.lessons_completed >= numericValue;

    case "books_gte":
      return stats.books_completed >= numericValue;

    case "level_gte":
      return stats.level >= numericValue;

    case "streak_gte":
      return stats.streak >= numericValue;

    case "quiz_perfect_gte":
      return stats.quiz_perfect_count >= numericValue;

    case "time_of_day": {
      // condition_value expected as "HH:MM-HH:MM" range (24h)
      const now = new Date();
      const currentMinutes = now.getUTCHours() * 60 + now.getUTCMinutes();
      const parts = String(condition_value).split("-");
      if (parts.length !== 2) return false;
      const [startStr, endStr] = parts;
      const [sh, sm] = startStr.split(":").map(Number);
      const [eh, em] = endStr.split(":").map(Number);
      const startMinutes = sh * 60 + (sm ?? 0);
      const endMinutes = eh * 60 + (em ?? 0);
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }

    case "day_of_week": {
      // condition_value expected as comma-separated day numbers (0=Sunday, 6=Saturday)
      const today = new Date().getUTCDay();
      const allowedDays = String(condition_value)
        .split(",")
        .map((d) => parseInt(d.trim(), 10));
      return allowedDays.includes(today);
    }

    default:
      console.warn(`Unknown condition_type: ${condition_type}`);
      return false;
  }
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

    // Fetch user profile stats
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("level, streak, lessons_completed, books_completed")
      .eq("id", userId)
      .single();

    if (profileError || !profile) {
      return new Response(
        JSON.stringify({ error: "User profile not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Count perfect quiz scores from xp_logs
    const { count: quizPerfectCount } = await supabase
      .from("xp_logs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("source_type", "quiz_perfect");

    const userStats: UserStats = {
      lessons_completed: profile.lessons_completed ?? 0,
      books_completed: profile.books_completed ?? 0,
      level: profile.level ?? 1,
      streak: profile.streak ?? 0,
      quiz_perfect_count: quizPerfectCount ?? 0,
    };

    // Fetch IDs of achievements already earned by this user
    const { data: earnedRows } = await supabase
      .from("user_achievements")
      .select("achievement_id")
      .eq("user_id", userId);

    const earnedIds = new Set((earnedRows ?? []).map((r: { achievement_id: string }) => r.achievement_id));

    // Fetch all achievements not yet earned
    const { data: allAchievements, error: achieveError } = await supabase
      .from("achievements")
      .select(
        "id, name, description, condition_type, condition_value, xp_reward, icon_url, badge_color"
      );

    if (achieveError) {
      throw achieveError;
    }

    const unearnedAchievements = (allAchievements ?? []).filter(
      (a: Achievement) => !earnedIds.has(a.id)
    );

    const newlyAwarded: Achievement[] = [];
    const now = new Date().toISOString();

    for (const achievement of unearnedAchievements) {
      if (evaluateCondition(achievement, userStats)) {
        // Award the achievement
        const { error: insertError } = await supabase
          .from("user_achievements")
          .insert({
            user_id: userId,
            achievement_id: achievement.id,
            earned_at: now,
          });

        if (insertError) {
          console.error(`Failed to insert achievement ${achievement.id}:`, insertError);
          continue;
        }

        // Award XP if applicable
        if (achievement.xp_reward > 0) {
          await supabase.from("xp_logs").insert({
            user_id: userId,
            amount: achievement.xp_reward,
            source_type: "achievement",
            source_id: achievement.id,
            description: `Achievement unlocked: ${achievement.name}`,
            created_at: now,
          });
        }

        newlyAwarded.push(achievement);
      }
    }

    return new Response(
      JSON.stringify({
        awarded: newlyAwarded,
        count: newlyAwarded.length,
        userStats,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("check-achievements error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
