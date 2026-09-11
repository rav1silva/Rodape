import 'package:flutter/material.dart';

import 'helpers/helper_pref.dart';
import 'helpers/models/cep_info.dart';
import 'helpers/models/onboarding_args.dart';
import 'screens/cep_step_screen.dart';
import 'screens/home_screen.dart';
import 'screens/name_step_screen.dart';
import 'screens/nearby_books_step_screen.dart';
import 'screens/nearby_screen.dart';
import 'screens/onboarding_complete_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/otp_step_screen.dart';
import 'screens/phone_step_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shelf_screen.dart';
import 'screens/wishlist_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/rodape_bottom_nav.dart';

/// Nomes de rota do app — cadastro/login (fluxo de onboarding) + a casca
/// principal com abas ("/home").
class AppRoutes {
  AppRoutes._();

  static const onboarding = '/';
  static const cep = '/cep';
  static const nearbyBooks = '/nearby-books';
  static const phone = '/phone';
  static const otp = '/otp';
  static const name = '/name';
  static const onboardingComplete = '/onboarding-complete';
  static const home = '/home';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Usuário que já concluiu o cadastro nesta sessão do device não vê o
  // onboarding de novo — só o gate final "/home".
  final onboardingConcluido = await HelperPref.isOnboardingDone();

  runApp(RodapeApp(
    initialRoute: onboardingConcluido ? AppRoutes.home : AppRoutes.onboarding,
  ));
}

class RodapeApp extends StatelessWidget {
  const RodapeApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rodapé',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.cep:
      return _buildRoute(settings, const CepStepScreen());

    case AppRoutes.nearbyBooks:
      return _buildRoute(
        settings,
        NearbyBooksStepScreen(cepInfo: settings.arguments as CepInfo),
      );

    case AppRoutes.phone:
      final args = settings.arguments;
      return _buildRoute(
        settings,
        PhoneStepScreen(args: args is PhoneStepArgs ? args : const PhoneStepArgs()),
      );

    case AppRoutes.otp:
      return _buildRoute(settings, OtpStepScreen(args: settings.arguments as OtpStepArgs));

    case AppRoutes.name:
      return _buildRoute(settings, NameStepScreen(telefone: settings.arguments as String));

    case AppRoutes.onboardingComplete:
      return _buildRoute(
        settings,
        OnboardingCompleteScreen(args: settings.arguments as OnboardingCompleteArgs),
      );

    case AppRoutes.home:
      return _buildRoute(settings, const RootShell());

    case AppRoutes.onboarding:
    default:
      return _buildRoute(settings, const OnboardingScreen());
  }
}

/// Todas as telas do fluxo compartilham a mesma transição (fade), via um
/// único [PageRouteBuilder] central.
PageRouteBuilder<void> _buildRoute(RouteSettings settings, Widget child) {
  return PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => child,
    transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
  );
}

/// Container principal do app: mantém as 5 abas vivas em um [IndexedStack]
/// e alterna entre elas pela barra de navegação inferior.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    NearbyScreen(),
    ShelfScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: RodapeBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
