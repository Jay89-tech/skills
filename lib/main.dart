// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Services
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/skill_controller.dart';

// Views
import 'views/auth/splash_screen.dart';

// Utils
import 'utils/app_colors.dart';
import 'utils/app_styles.dart';
import 'utils/routes.dart';
import 'config/app_config.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.primary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(SkillsAuditApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize API Service
    ApiService().initialize();
    
    // Initialize Database Service
    await DatabaseService().initialize();
    
    // Initialize Notification Service
    await NotificationService().initialize();
    
    // Initialize Auth Service
    await AuthService().initialize();
    
    print('✅ All services initialized successfully');
  } catch (e) {
    print('❌ Error initializing services: $e');
  }
}

class SkillsAuditApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Controllers as Providers
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => SkillController()),
        
        // Services as Providers (if needed for global access)
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, _) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            
            // Theme Configuration
            theme: _buildThemeData(context),
            darkTheme: _buildDarkThemeData(context),
            themeMode: ThemeMode.system,
            
            // Navigation
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.generateRoute,
            navigatorKey: NavigationService.navigatorKey,
            
            // Home Screen
            home: SplashScreen(),
            
            // Localization (if needed)
            supportedLocales: [
              Locale('en', 'ZA'), // English (South Africa)
              Locale('af', 'ZA'), // Afrikaans (South Africa)
            ],
            
            // Builder for global configurations
            builder: (context, child) {
              return MediaQuery(
                // Prevent text scaling issues
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
  
  ThemeData _buildThemeData(BuildContext context) {
    return ThemeData(
      // Color Scheme
      primarySwatch: AppColors.primarySwatch,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: AppColors.primarySwatch,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      
      // Typography
      fontFamily: AppStyles.primaryFont,
      textTheme: AppStyles.textTheme,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppStyles.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppStyles.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppStyles.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppStyles.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      
      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      
      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primary.withOpacity(0.2),
        circularTrackColor: AppColors.primary.withOpacity(0.2),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  ThemeData _buildDarkThemeData(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: AppColors.primarySwatch,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: AppColors.primarySwatch,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
      ),
      fontFamily: AppStyles.primaryFont,
      textTheme: AppStyles.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// Navigation Service for global navigation
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  static Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }
  
  static Future<dynamic> navigateAndReplace(String routeName, {dynamic arguments}) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }
  
  static Future<dynamic> navigateAndClearStack(String routeName, {dynamic arguments}) {
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void goBack([dynamic result]) {
    return navigator!.pop(result);
  }
  
  static bool canGoBack() {
    return navigator!.canPop();
  }
  
  // Global Snackbar
  static void showSnackBar(String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
          action: action,
        ),
      );
    }
  }
  
  // Global Dialog
  static Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => child,
      );
    }
    return Future.value(null);
  }
  
  // Global Loading Dialog
  static void showLoadingDialog({String message = 'Loading...'}) {
    showCustomDialog(
      barrierDismissible: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  static void hideLoadingDialog() {
    final context = navigatorKey.currentContext;
    if (context != null && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

// Global Error Handler
class GlobalErrorHandler {
  static void handleError(dynamic error, {StackTrace? stackTrace}) {
    // Log error
    print('❌ Global Error: $error');
    if (stackTrace != null) {
      print('Stack Trace: $stackTrace');
    }
    
    // Show user-friendly message
    String userMessage = _getUserFriendlyMessage(error);
    NavigationService.showSnackBar(
      userMessage,
      backgroundColor: AppColors.error,
      duration: Duration(seconds: 5),
    );
    
    // TODO: Send error to crash reporting service (Firebase Crashlytics, Sentry, etc.)
  }
  
  static String _getUserFriendlyMessage(dynamic error) {
    if (error.toString().contains('network') || error.toString().contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (error.toString().contains('unauthorized') || error.toString().contains('401')) {
      return 'Please log in again to continue.';
    } else if (error.toString().contains('forbidden') || error.toString().contains('403')) {
      return 'You don\'t have permission to perform this action.';
    } else if (error.toString().contains('not found') || error.toString().contains('404')) {
      return 'The requested resource was not found.';
    } else if (error.toString().contains('server') || error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}

// App Lifecycle Observer
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed');
        // Handle app resume (refresh data, check notifications, etc.)
        break;
      case AppLifecycleState.inactive:
        print('📱 App inactive');
        break;
      case AppLifecycleState.paused:
        print('📱 App paused');
        // Save current state, pause timers, etc.
        break;
      case AppLifecycleState.detached:
        print('📱 App detached');
        // Clean up resources
        break;
      case AppLifecycleState.hidden:
        print('📱 App hidden');
        break;
    }
  }
}