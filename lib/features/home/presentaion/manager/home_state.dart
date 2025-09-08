// Home State
// Single state class for home feature

class HomeState {
  final int currentIndex;
  final int selectedBrowseType;
  final bool isLoading;

  const HomeState({
    this.currentIndex = 0,
    this.selectedBrowseType = 0,
    this.isLoading = false,
  });

  HomeState copyWith({
    int? currentIndex,
    int? selectedBrowseType,
    bool? isLoading,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      selectedBrowseType: selectedBrowseType ?? this.selectedBrowseType,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeState &&
        other.currentIndex == currentIndex &&
        other.selectedBrowseType == selectedBrowseType &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentIndex,
      selectedBrowseType,
      isLoading,
    );
  }
}
