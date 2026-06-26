import 'package:freezed_annotation/freezed_annotation.dart';

part 'simulation_model.freezed.dart';
part 'simulation_model.g.dart';

@freezed
class SimOption with _$SimOption {
  const factory SimOption({
    required String label,
    @JsonKey(name: 'state_delta') @Default({}) Map<String, dynamic> stateDelta,
    @JsonKey(name: 'is_optimal') @Default(false) bool isOptimal,
  }) = _SimOption;

  factory SimOption.fromJson(Map<String, dynamic> json) =>
      _$SimOptionFromJson(json);
}

@freezed
class SimStep with _$SimStep {
  const factory SimStep({
    required String id,
    required String type,
    required String prompt,
    @Default([]) List<SimOption> options,
  }) = _SimStep;

  factory SimStep.fromJson(Map<String, dynamic> json) =>
      _$SimStepFromJson(json);
}

@freezed
class Simulation with _$Simulation {
  const factory Simulation({
    required String id,
    @JsonKey(name: 'lesson_id') required String lessonId,
    required String title,
    String? description,
    @JsonKey(name: 'initial_state') @Default({}) Map<String, dynamic> initialState,
    @JsonKey(name: 'win_condition') @Default({}) Map<String, dynamic> winCondition,
    @JsonKey(name: 'max_steps') @Default(10) int maxSteps,
    @JsonKey(name: 'xp_reward') @Default(0) int xpReward,
    @Default([]) List<SimStep> steps,
  }) = _Simulation;

  factory Simulation.fromJson(Map<String, dynamic> json) =>
      _$SimulationFromJson(json);
}
