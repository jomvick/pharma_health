import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_colors.dart';
import 'providers/auth_provider.dart';
import 'models/user.dart';
import 'screens/add_medicine_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/login_screen.dart';
import 'screens/medicine_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/stock_entry_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/reports_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");
  runApp(const ProviderScope(child: MyApp()));
}

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
  final Ref ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const POSScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/medicine/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MedicineDetailScreen(medicineId: id);
        },
      ),
      GoRoute(
        path: '/add-medicine',
        builder: (context, state) => const AddMedicineScreen(),
      ),
      GoRoute(
        path: '/edit-medicine/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddMedicineScreen(medicineId: id);
        },
      ),
      GoRoute(
        path: '/stock-entry',
        builder: (context, state) => const StockEntryScreen(),
      ),
      GoRoute(
        path: '/clients',
        builder: (context, state) => const ClientsScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final role = authState.role;

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn) {
        if (isLoggingIn) {
          // Redirection initiale selon le rôle
          switch (role) {
            case UserRole.admin:
              return '/dashboard';
            case UserRole.pharmacist:
              return '/dashboard'; // Changé vers dashboard pour coller à (Accès au Tableau de Bord, ...)
            case UserRole.seller:
              return '/pos';
            default:
              return '/pos';
          }
        }

        // Protection des routes spécifiques (ex: Dashboard réservé à l'admin et au pharmacien)
        if (state.matchedLocation == '/dashboard' && 
            role != UserRole.admin && 
            role != UserRole.pharmacist) {
          return '/pos';
        }

        // Protection des routes de gestion de stock (Admin/Pharmacien uniquement)
        if ((state.matchedLocation == '/add-medicine' || state.matchedLocation == '/stock-entry') &&
            role != UserRole.admin && 
            role != UserRole.pharmacist) {
          return '/pos';
        }
      }

      return null;
    },
  );
});


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PharmacyManager BF',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary500,
          primary: AppColors.primary600,
          secondary: AppColors.secondary500,
          surface: AppColors.white,
          background: AppColors.gray50,
          error: AppColors.alert500,
        ),
        scaffoldBackgroundColor: AppColors.gray50,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.gray900,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.gray600),
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.gray900,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.gray200, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primary600,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.gray100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gray200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary500, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.alert500),
          ),
          hintStyle: const TextStyle(color: AppColors.gray400),
          labelStyle: const TextStyle(color: AppColors.gray600),
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
