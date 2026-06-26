// ---------------------------------------------------------------------------
// Domain entities for lesson content blocks.
//
// All content is stored as JSONB in the `lesson_content` table.
// The `type` field drives which sealed subclass is constructed.
// ---------------------------------------------------------------------------

/// A quiz with a question, multiple options, and a correct index.
class Quiz {
  const Quiz({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json['id'] as String? ?? '',
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctIndex: (json['correct_index'] as num).toInt(),
        explanation: json['explanation'] as String?,
      );
}

/// A deck of flash cards with front/back content.
class FlashcardDeck {
  const FlashcardDeck({
    required this.id,
    required this.title,
    required this.cards,
  });

  final String id;
  final String title;
  final List<Flashcard> cards;

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) => FlashcardDeck(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        cards: (json['cards'] as List<dynamic>)
            .map((c) => Flashcard.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

class Flashcard {
  const Flashcard({required this.front, required this.back});

  final String front;
  final String back;

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        front: json['front'] as String,
        back: json['back'] as String,
      );
}

/// A story mission with nodes, choices, and an optimal path.
class StoryMission {
  const StoryMission({
    required this.id,
    required this.title,
    required this.nodes,
  });

  final String id;
  final String title;
  final List<StoryNode> nodes;

  factory StoryMission.fromJson(Map<String, dynamic> json) => StoryMission(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        nodes: (json['nodes'] as List<dynamic>)
            .map((n) => StoryNode.fromJson(n as Map<String, dynamic>))
            .toList(),
      );
}

class StoryNode {
  const StoryNode({
    required this.id,
    required this.speaker,
    required this.text,
    required this.choices,
    this.isOptimal = false,
  });

  final String id;
  final String speaker;
  final String text;
  final List<StoryChoice> choices;
  final bool isOptimal;

  factory StoryNode.fromJson(Map<String, dynamic> json) => StoryNode(
        id: json['id'] as String? ?? '',
        speaker: json['speaker'] as String? ?? 'Narrator',
        text: json['text'] as String,
        choices: (json['choices'] as List<dynamic>? ?? [])
            .map((c) => StoryChoice.fromJson(c as Map<String, dynamic>))
            .toList(),
        isOptimal: json['is_optimal'] as bool? ?? false,
      );
}

class StoryChoice {
  const StoryChoice({
    required this.id,
    required this.label,
    required this.nextNodeId,
    this.xpReward = 0,
  });

  final String id;
  final String label;
  final String nextNodeId;
  final int xpReward;

  factory StoryChoice.fromJson(Map<String, dynamic> json) => StoryChoice(
        id: json['id'] as String? ?? '',
        label: json['label'] as String,
        nextNodeId: json['next_node_id'] as String? ?? '',
        xpReward: (json['xp_reward'] as num?)?.toInt() ?? 0,
      );
}

/// A multi-step simulation exercise.
class Simulation {
  const Simulation({
    required this.id,
    required this.title,
    required this.steps,
  });

  final String id;
  final String title;
  final List<SimulationStep> steps;

  factory Simulation.fromJson(Map<String, dynamic> json) => Simulation(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        steps: (json['steps'] as List<dynamic>)
            .map((s) => SimulationStep.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class SimulationStep {
  const SimulationStep({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    this.stateDisplay,
  });

  final String id;
  final String prompt;
  final List<SimulationOption> options;
  final String correctOptionId;
  final String? stateDisplay;

  factory SimulationStep.fromJson(Map<String, dynamic> json) =>
      SimulationStep(
        id: json['id'] as String? ?? '',
        prompt: json['prompt'] as String,
        options: (json['options'] as List<dynamic>)
            .map((o) =>
                SimulationOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        correctOptionId: json['correct_option_id'] as String? ?? '',
        stateDisplay: json['state_display'] as String?,
      );
}

class SimulationOption {
  const SimulationOption({
    required this.id,
    required this.label,
    this.xpReward = 0,
  });

  final String id;
  final String label;
  final int xpReward;

  factory SimulationOption.fromJson(Map<String, dynamic> json) =>
      SimulationOption(
        id: json['id'] as String? ?? '',
        label: json['label'] as String,
        xpReward: (json['xp_reward'] as num?)?.toInt() ?? 0,
      );
}

/// A timed challenge (e.g. rapid-fire questions).
class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.questions,
    this.timeLimitSeconds = 60,
  });

  final String id;
  final String title;
  final List<Quiz> questions;
  final int timeLimitSeconds;

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        questions: (json['questions'] as List<dynamic>)
            .map((q) => Quiz.fromJson(q as Map<String, dynamic>))
            .toList(),
        timeLimitSeconds: (json['time_limit_seconds'] as num?)?.toInt() ?? 60,
      );
}

// ---------------------------------------------------------------------------
// Sealed ContentBlock
// ---------------------------------------------------------------------------

sealed class ContentBlock {
  const ContentBlock();

  /// Factory that maps a [type] string to the correct subclass.
  static ContentBlock fromJson(Map<String, dynamic> json, String type) =>
      switch (type) {
        'quiz' => QuizBlock(
            questions: (json['questions'] as List<dynamic>? ?? [])
                .map((q) => Quiz.fromJson(q as Map<String, dynamic>))
                .toList(),
          ),
        'flashcard' => FlashcardBlock(
            deck: FlashcardDeck.fromJson(json)),
        'story_mission' => StoryMissionBlock(
            mission: StoryMission.fromJson(json)),
        'simulation' => SimulationBlock(
            simulation: Simulation.fromJson(json)),
        'challenge' => ChallengeBlock(
            challenge: Challenge.fromJson(json)),
        _ => ArticleBlock(markdown: json['markdown'] as String? ?? ''),
      };
}

class QuizBlock extends ContentBlock {
  const QuizBlock({required this.questions});
  final List<Quiz> questions;
}

class FlashcardBlock extends ContentBlock {
  const FlashcardBlock({required this.deck});
  final FlashcardDeck deck;
}

class StoryMissionBlock extends ContentBlock {
  const StoryMissionBlock({required this.mission});
  final StoryMission mission;
}

class SimulationBlock extends ContentBlock {
  const SimulationBlock({required this.simulation});
  final Simulation simulation;
}

class ChallengeBlock extends ContentBlock {
  const ChallengeBlock({required this.challenge});
  final Challenge challenge;
}

class ArticleBlock extends ContentBlock {
  const ArticleBlock({required this.markdown});
  final String markdown;
}
