import 'package:flutter_bloc/flutter_bloc.dart';

/// High-performance base Cubit with optimizations
abstract class OptimizedCubit<State> extends Cubit<State> {
  OptimizedCubit(State initialState) : super(initialState);

  /// High-performance state emission with automatic comparison
  void emitOptimized(State newState) {
    if (state != newState) {
      emit(newState);
    }
  }

  /// Emit state only if cubit is not closed
  void safeEmit(State newState) {
    if (!isClosed) {
      emitOptimized(newState);
    }
  }

  /// Batch multiple state changes into one emission
  void batchEmit(State Function(State currentState) stateBuilder) {
    final newState = stateBuilder(state);
    emitOptimized(newState);
  }
}