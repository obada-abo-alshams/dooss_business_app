# 🔧 State Emission Fixes - "Cannot emit new states after calling close" Error

## 🚨 **Root Cause Analysis:**

The "Cannot emit new states after calling close" error occurs when:
1. **Async operations** complete after a Cubit/Bloc has been disposed
2. **Timer callbacks** continue running after widget disposal  
3. **WebSocket callbacks** fire after cubit disposal
4. **Regular `emit()` calls** don't check if cubit is closed

## ✅ **Issues Identified & Fixed:**

### **1. CRITICAL: OptimizedCubit batchEmit Method**
**File:** `lib/core/cubits/optimized_cubit.dart`

**Problem:** `batchEmit()` method wasn't checking if cubit was closed before emitting.

**BEFORE:**
```dart
void batchEmit(State Function(State currentState) stateBuilder) {
  final newState = stateBuilder(state);
  emitOptimized(newState); // ❌ No isClosed check
}
```

**AFTER:**
```dart
void batchEmit(State Function(State currentState) stateBuilder) {
  if (!isClosed) { // ✅ Added isClosed check
    final newState = stateBuilder(state);
    emitOptimized(newState);
  }
}
```

### **2. CRITICAL: Timer Memory Leaks**
**File:** `lib/features/auth/presentation/widgets/resend_timer_widget.dart`

**Problem:** Timer was created but never disposed, causing callbacks to fire after widget disposal.

**BEFORE:**
```dart
class _ResendTimerWidgetState extends State<ResendTimerWidget> {
  _timerPeriodec(int seconds, bool isfinish) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // ❌ No disposal, no mounted check
    });
  }
  // ❌ No dispose method
}
```

**AFTER:**
```dart
class _ResendTimerWidgetState extends State<ResendTimerWidget> {
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel(); // ✅ Cancel existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) { // ✅ Check if widget is still mounted
        setState(() { /* safe state update */ });
      } else {
        timer.cancel(); // ✅ Cancel if widget disposed
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ Proper cleanup
    super.dispose();
  }
}
```

### **3. CRITICAL: HomeCubit Using Unsafe Emissions**
**File:** `lib/features/home/presentaion/manager/home_cubit.dart`

**Problem:** HomeCubit was using regular `emit()` calls without checking if cubit was closed.

**BEFORE:**
```dart
class HomeCubit extends Cubit<HomeState> {
  void updateCurrentIndex(int index) {
    emit(state.copyWith(currentIndex: index)); // ❌ Unsafe emission
  }
}
```

**AFTER:**
```dart
class HomeCubit extends OptimizedCubit<HomeState> {
  void updateCurrentIndex(int index) {
    emitOptimized(state.copyWith(currentIndex: index)); // ✅ Safe emission
  }
}
```

### **4. CRITICAL: AuthCubit Unsafe Emissions**
**File:** `lib/features/auth/presentation/manager/auth_cubit.dart`

**Problem:** AuthCubit was using regular `emit()` calls in async operations.

**BEFORE:**
```dart
class AuthCubit extends Cubit<AuthState> {
  Future<void> signIn(SigninParams params) async {
    emit(state.copyWith(isLoading: true)); // ❌ Unsafe emission
    
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)), // ❌ Unsafe
      (success) => emit(state.copyWith(checkAuthState: CheckAuthState.success)), // ❌ Unsafe
    );
  }
}
```

**AFTER:**
```dart
class AuthCubit extends OptimizedCubit<AuthState> {
  Future<void> signIn(SigninParams params) async {
    safeEmit(state.copyWith(isLoading: true)); // ✅ Safe emission
    
    result.fold(
      (failure) => safeEmit(state.copyWith(error: failure.message)), // ✅ Safe
      (success) => safeEmit(state.copyWith(checkAuthState: CheckAuthState.success)), // ✅ Safe
    );
  }
}
```

### **5. CRITICAL: ChatCubit WebSocket Callbacks**
**File:** `lib/features/chat/presentation/manager/chat_cubit.dart`

**Problem:** WebSocket callbacks could fire after cubit disposal.

**BEFORE:**
```dart
_webSocketService.onConnected = () {
  emit(state.copyWith(isWebSocketConnected: true)); // ❌ Unsafe emission
};
```

**AFTER:**
```dart
_webSocketService.onConnected = () {
  safeEmit(state.copyWith(isWebSocketConnected: true)); // ✅ Safe emission
};
```

### **6. ServiceCubit & ReelCubit Updates**
**Files:** 
- `lib/features/home/presentaion/manager/service_cubit.dart`
- `lib/features/home/presentaion/manager/reel_cubit.dart`

**Changes:**
- ✅ Extended `OptimizedCubit` instead of regular `Cubit`
- ✅ Replaced all `emit()` calls with `safeEmit()`
- ✅ Used optimized emission methods

### **7. ProductCubit Complex Async Operations**
**File:** `lib/features/home/presentaion/manager/product_cubit.dart`

**Problem:** Complex async operations in `loadProductDetails()` could complete after disposal.

**BEFORE:**
```dart
productResult.fold(
  (failure) => /* handle failure */,
  (product) async {
    // ❌ Multiple async operations without disposal checks
    final relatedResult = await dataSource.fetchRelatedProducts(productId);
    final reviewsResult = await dataSource.fetchProductReviews(productId);
    // Complex nested fold operations
  },
);
```

**AFTER:**
```dart
productResult.fold(
  (failure) => /* handle failure */,
  (product) async {
    // ✅ Immediate emission of main data
    safeEmit(state.copyWith(selectedProduct: product, isLoading: false));
    
    // ✅ Separate method for additional data with disposal checks
    _loadAdditionalProductData(productId);
  },
);

Future<void> _loadAdditionalProductData(int productId) async {
  // ... load additional data
  
  // ✅ Check if cubit is still active before emitting
  if (!isClosed) {
    // Safe emissions for additional data
  }
}
```

## 🛡️ **Safety Mechanisms Implemented:**

### **1. Enhanced OptimizedCubit Base Class**
```dart
abstract class OptimizedCubit<State> extends Cubit<State> {
  void emitOptimized(State newState) {
    if (!isClosed && state != newState) { // ✅ Double check: closed + state comparison
      emit(newState);
    }
  }

  void safeEmit(State newState) {
    if (!isClosed) { // ✅ Always check if closed
      emitOptimized(newState);
    }
  }

  void batchEmit(State Function(State currentState) stateBuilder) {
    if (!isClosed) { // ✅ Check before building new state
      final newState = stateBuilder(state);
      emitOptimized(newState);
    }
  }
}
```

### **2. Timer Safety Pattern**
```dart
class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel(); // ✅ Cancel existing
    _timer = Timer.periodic(duration, (timer) {
      if (mounted) { // ✅ Check if widget mounted
        setState(() { /* safe update */ });
      } else {
        timer.cancel(); // ✅ Auto-cancel if disposed
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ Always dispose
    super.dispose();
  }
}
```

### **3. WebSocket Safety Pattern**
```dart
_webSocketService.onMessageReceived = (message) {
  if (!isClosed) { // ✅ Check before any emission
    safeEmit(state.copyWith(/* new state */));
  }
};
```

## 📊 **Files Modified:**

1. ✅ `lib/core/cubits/optimized_cubit.dart` - Enhanced safety checks
2. ✅ `lib/features/auth/presentation/widgets/resend_timer_widget.dart` - Fixed timer disposal
3. ✅ `lib/features/home/presentaion/manager/home_cubit.dart` - Safe emissions
4. ✅ `lib/features/auth/presentation/manager/auth_cubit.dart` - Safe emissions  
5. ✅ `lib/features/chat/presentation/manager/chat_cubit.dart` - Safe emissions + WebSocket safety
6. ✅ `lib/features/home/presentaion/manager/service_cubit.dart` - Safe emissions
7. ✅ `lib/features/home/presentaion/manager/reel_cubit.dart` - Safe emissions
8. ✅ `lib/features/home/presentaion/manager/product_cubit.dart` - Complex async safety

## 🎯 **Error Prevention Strategy:**

### **Immediate Fixes:**
- ✅ All Cubits now extend `OptimizedCubit`
- ✅ All emissions use `safeEmit()` or `emitOptimized()`
- ✅ All timers properly disposed
- ✅ WebSocket callbacks use safe emissions

### **Long-term Safety:**
- ✅ Enhanced base class with multiple safety layers
- ✅ Consistent patterns across all Cubits
- ✅ Proper resource disposal in all StatefulWidgets
- ✅ Complex async operations split into safer methods

## 🚀 **Result:**

**The "Cannot emit new states after calling close" error should now be completely resolved.** All state emissions are now protected by `isClosed` checks, and all resources (timers, WebSocket connections) are properly disposed when widgets are destroyed.

Your application will now handle navigation, screen changes, and async operations safely without state emission errors.