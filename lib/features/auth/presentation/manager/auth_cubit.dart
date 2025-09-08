import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dooss_business_app/core/cubits/optimized_cubit.dart';

import '../../../../core/services/token_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_preferences_service.dart';
import '../../../../core/network/failure.dart';
import '../../data/data_source/auth_remote_data_source_imp.dart' show AuthRemoteDataSourceImp;
import '../../data/models/create_account_params_model.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import '../pages/verify_otp_page.dart';
import '../manager/auth_state.dart';

class AuthCubit extends OptimizedCubit<AuthState> {
  final AuthRemoteDataSourceImp _authRemoteDataSource;

  AuthCubit(this._authRemoteDataSource) : super(AuthState());

  /// تبديل إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    emitOptimized(state.copyWith(
      isObscurePassword: !(state.isObscurePassword ?? false),
    ));
  }

  /// تبديل حالة "تذكرني"
  void toggleRememberMe() {
    emitOptimized(state.copyWith(
      isRememberMe: !(state.isRememberMe ?? false),
    ));
  }

  /// تسجيل الدخول
  Future<void> signIn(SigninParams params) async {
    log("🚀 AuthCubit - Starting sign in process");
    safeEmit(state.copyWith(isLoading: true));

    final Either<Failure, AuthResponceModel> result = 
        await _authRemoteDataSource.signin(params);
    
    result.fold(
      (failure) {
        log("❌ AuthCubit - Sign in failed: ${failure.message}");
        safeEmit(state.copyWith(
          isLoading: false,
          error: failure.message,
          checkAuthState: CheckAuthState.error,
        ));
      },
      (authResponse) async {
        log("✅ AuthCubit - Sign in successful");
        log("🔍 AuthCubit - AuthResponse details:");
        log("🔍 AuthCubit - Message: ${authResponse.message}");
        log("🔍 AuthCubit - Token: ${authResponse.token}");
        log("🔍 AuthCubit - Token length: ${authResponse.token.length}");
        log("🔍 AuthCubit - Token is empty: ${authResponse.token.isEmpty}");
        log("🔍 AuthCubit - User: ${authResponse.user.name}");
        
        // الـ token يتم حفظه تلقائياً في AuthResponceModel.fromJson
        if (authResponse.token.isNotEmpty) {
          log("✅ AuthCubit - Token saved automatically in AuthResponceModel");
          
          // اختبار التحقق من الـ authentication
          final hasToken = await TokenService.hasToken();
          log("🔍 AuthCubit - Has token: $hasToken");
          
          // اختبار AuthService
          final isAuthenticated = await AuthService.isAuthenticated();
          log("🔍 AuthCubit - Is authenticated: $isAuthenticated");
        } else {
          log("⚠️ AuthCubit - Token is empty");
          log("⚠️ AuthCubit - This might be the issue - API is not returning token");
        }
        
        // حفظ بيانات المستخدم في shared_preferences
        if (authResponse.user != null) {
          
          log("💾 AuthCubit - User data saving temporarily disabled");
        }
        
        safeEmit(state.copyWith(
          isLoading: false,
          checkAuthState: CheckAuthState.signinSuccess,
          success: authResponse.message,
        ));
      },
    );
  }

  /// إنشاء حساب جديد
  Future<void> register(CreateAccountParams params) async {
    log("🚀 AuthCubit - Starting register process");
    safeEmit(state.copyWith(isLoading: true));

    final Either<Failure, UserModel> result = 
        await _authRemoteDataSource.register(params);
    
    result.fold(
      (failure) {
        log("❌ AuthCubit - Register failed: ${failure.message}");
        safeEmit(state.copyWith(
          isLoading: false,
          error: failure.message,
          checkAuthState: CheckAuthState.error,
        ));
      },
      (userModel) async {
        log("✅ AuthCubit - Register successful, emitting success state");
        // في حالة التسجيل، لا نحفظ token لأن المستخدم يحتاج للتحقق من OTP أولاً
        safeEmit(state.copyWith(
          isLoading: false,
          checkAuthState: CheckAuthState.success,
          success: "Account created successfully! Please verify your phone number.",
        ));
      },
    );
  }

  /// طلب كود التحقق (OTP) لرقم الهاتف
  Future<void> resetPassword(String phoneNumber) async {
    log("🚀 AuthCubit - Starting reset password process for: $phoneNumber");
    safeEmit(state.copyWith(isLoading: true));

    final Either<Failure, Map<String, dynamic>> result = 
        await _authRemoteDataSource.resetPassword(phoneNumber);
    
    result.fold(
      (failure) {
        log("❌ AuthCubit - Reset password failed: ${failure.message}");
        safeEmit(state.copyWith(
          isLoading: false,
          error: failure.message,
          checkAuthState: CheckAuthState.error,
        ));
      },
      (successResponse) {
        log("✅ AuthCubit - Reset password successful");
        safeEmit(state.copyWith(
          isLoading: false,
          checkAuthState: CheckAuthState.success,
          success: successResponse["message"] ?? "OTP sent successfully",
        ));
      },
    );
  }

  /// التحقق من كود OTP
  Future<void> verifyOtp(VerifycodeParams params) async {
    log("🚀 AuthCubit - Starting OTP verification for: ${params.phoneNumber}");
    safeEmit(state.copyWith(isLoading: true));

    final Either<Failure, String> result = 
        await _authRemoteDataSource.verifyOtp(params);
    
    result.fold(
      (failure) {
        log("❌ AuthCubit - OTP verification failed: ${failure.message}");
        safeEmit(state.copyWith(
          isLoading: false,
          error: failure.message,
          checkAuthState: CheckAuthState.error,
        ));
      },
      (successMessage) async {
        log("✅ AuthCubit - OTP verification successful");
        // بعد التحقق من OTP، نحفظ الـ token إذا كان موجوداً في الـ response
        // يمكن تعديل هذا حسب هيكل الـ API response
        safeEmit(state.copyWith(
          isLoading: false,
          checkAuthState: CheckAuthState.success,
          success: successMessage,
        ));
      },
    );
  }

  /// التحقق من كود OTP مع إعادة تعيين كلمة المرور (لـ forget password flow)
  Future<void> verifyOtpForResetPassword(ResetPasswordParams params) async {
    log("🚀 AuthCubit - Starting OTP verification for reset password: ${params.phoneNumber}");
    safeEmit(state.copyWith(isLoading: true));

    final Either<Failure, String> result = 
        await _authRemoteDataSource.verifyOtpForResetPassword(params);
    
    result.fold(
      (failure) {
        log("❌ AuthCubit - OTP verification for reset password failed: ${failure.message}");
        safeEmit(state.copyWith(
          isLoading: false,
          error: failure.message,
          checkAuthState: CheckAuthState.error,
        ));
      },
      (successMessage) {
        log("✅ AuthCubit - OTP verification for reset password successful");
        safeEmit(state.copyWith(
          isLoading: false,
          checkAuthState: CheckAuthState.success,
          success: successMessage,
        ));
      },
    );
  }

  /// إنشاء كلمة مرور جديدة
  Future<void> createNewPassword(ResetPasswordParams params) async {
    log("🚀 AuthCubit - Starting new password creation");
    
    safeEmit(state.copyWith(isLoading: true));

    final Either<Failure, String> result = 
        await _authRemoteDataSource.newPassword(params);
    
    result.fold(
      (failure) {
        log("❌ AuthCubit - New password creation failed: ${failure.message}");
        safeEmit(state.copyWith(
          isLoading: false,
          error: failure.message,
          checkAuthState: CheckAuthState.error,
        ));
      },
      (successMessage) {
        log("✅ AuthCubit - New password creation successful");
        safeEmit(state.copyWith(
          isLoading: false,
          checkAuthState: CheckAuthState.success,
          success: successMessage,
        ));
      },
    );
  }

  /// إعادة إرسال كود OTP
  Future<void> resendOtp(String phoneNumber) async {
    log("🚀 AuthCubit - Starting resend OTP for: $phoneNumber");
    safeEmit(state.copyWith(isLoading: true));

    final Either<Failure, String> result = 
        await _authRemoteDataSource.resendOtp(phoneNumber);
    
    result.fold(
      (failure) {
        log("❌ AuthCubit - Resend OTP failed: ${failure.message}");
        safeEmit(state.copyWith(
          isLoading: false,
          error: failure.message,
          checkAuthState: CheckAuthState.error,
        ));
      },
      (successMessage) {
        log("✅ AuthCubit - Resend OTP successful");
        safeEmit(state.copyWith(
          isLoading: false,
          checkAuthState: CheckAuthState.resendOtpSuccess,
          success: successMessage,
        ));
      },
    );
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    log("🚀 AuthCubit - Starting logout process");
    safeEmit(state.copyWith(isLoading: true));

    try {
      // الحصول على الـ refresh token
      final refreshToken = await TokenService.getRefreshToken();
      log("🔍 AuthCubit - Refresh token: $refreshToken");
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        // إرسال طلب تسجيل الخروج للـ API
        final Either<Failure, String> result = 
            await _authRemoteDataSource.logout(refreshToken);
        
        result.fold(
          (failure) {
            log("❌ AuthCubit - API logout failed: ${failure.message}");
            // حتى لو فشل الـ API call، نقوم بحذف البيانات محلياً
            _clearLocalData();
            emit(state.copyWith(
              isLoading: false,
              error: failure.message,
              checkAuthState: CheckAuthState.error,
            ));
          },
          (successMessage) {
            log("✅ AuthCubit - API logout successful");
            // حذف البيانات محلياً بعد نجاح الـ API call
            _clearLocalData();
            emit(state.copyWith(
              isLoading: false,
              checkAuthState: CheckAuthState.logoutSuccess,
              success: successMessage,
            ));
          },
        );
      } else {
        log("⚠️ AuthCubit - No refresh token found, clearing local data only");
        // إذا لم يكن هناك refresh token، نقوم بحذف البيانات محلياً فقط
        await _clearLocalData();
        safeEmit(state.copyWith(
          isLoading: false,
          checkAuthState: CheckAuthState.logoutSuccess,
          success: "Logged out successfully",
        ));
      }
    } catch (e) {
      log("❌ AuthCubit - Logout failed: $e");
      // في حالة الخطأ، نقوم بحذف البيانات محلياً على أي حال
      await _clearLocalData();
      emit(state.copyWith(
        isLoading: false,
        error: "Logout failed: $e",
        checkAuthState: CheckAuthState.error,
      ));
    }
  }

  /// حذف البيانات المحلية
  Future<void> _clearLocalData() async {
    try {
      // حذف جميع الـ tokens من الـ storage
      await TokenService.clearToken();
      log("✅ AuthCubit - All tokens cleared successfully");
      
      // حذف بيانات المستخدم من الـ storage
      await UserPreferencesService.clearAuthData();
      log("✅ AuthCubit - User data cleared successfully");
    } catch (e) {
      log("❌ AuthCubit - Error clearing local data: $e");
    }
  }

  /// إعادة تعيين الحالة إلى الحالة الأولية
  void resetState() {
    emitOptimized(AuthState());
  }

  @override
  Future<void> close() {
    log("🔒 AuthCubit - Closing");
    return super.close();
  }
}
