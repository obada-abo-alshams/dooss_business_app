// Reel State
// Single state class for reel feature

import '../../data/models/reel_model.dart';

class ReelState {
  final List<ReelModel> reels;
  final bool isLoading;
  final String? error;
  final bool hasNextPage;
  final int currentPage;
  final int totalCount;
  final int currentReelIndex;

  const ReelState({
    this.reels = const [],
    this.isLoading = false,
    this.error,
    this.hasNextPage = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.currentReelIndex = 0,
  });

  factory ReelState.initial() {
    return const ReelState();
  }

  ReelState copyWith({
    List<ReelModel>? reels,
    bool? isLoading,
    String? error,
    bool? hasNextPage,
    int? currentPage,
    int? totalCount,
    int? currentReelIndex,
  }) {
    return ReelState(
      reels: reels ?? this.reels,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      currentReelIndex: currentReelIndex ?? this.currentReelIndex,
    );
  }
}
