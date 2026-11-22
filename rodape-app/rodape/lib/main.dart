
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rodape/models/address.dart';
import 'package:rodape/models/onboarding_args.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'helpers/auth_helper.dart';
import 'helpers/helper_pref.dart';
import 'screens/cep_step_screen.dart';
import 'screens/home_screen.dart';
import 'screens/name_step_screen.dart';
import 'screens/nearby_books_step_screen.dart';
import 'screens/nearby_screen.dart';
import 'screens/onboarding_complete_screen.dart';
import 'screens/onboarding_screen.dart';

import 'screens/phone_step_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shelf_screen.dart';
import 'screens/wishlist_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/rodape_bottom_nav.dart';
import 'data/local_db.dart';
import 'services/livro_service.dart';
import 'services/net_service.dart';
import 'widgets/offline_banner.dart';

/// Nomes de rota do app — cadastro/login (fluxo de onboarding) + a casca
/// principal com abas ("/home").

class AppRoutes {
  AppRoutes._();

  static const onboarding = '/';
  static const cep = '/cep';
  static const nearbyBooks = '/nearby-books';
  static const phone = '/phone';

  static const name = '/name';
  static const onboardingComplete = '/onboarding-complete';
  static const home = '/home';
}
/// Decide a rota inicial a partir da sessão do Supabase:
/// - sessão + perfil → Home;
/// - sessão confirmada sem perfil (ex.: app foi fechado enquanto a pessoa
///   confirmava o e-mail e reabriu pelo link) → retoma no passo do nome;
/// - sem sessão → abertura.
Future<String> rotaInicialPelaSessao() async {
  final supabase = Supabase.instance.client;
  final authUser = supabase.auth.currentUser;

  if (authUser == null) {
    AuthService.loggedUser = null;
    return AppRoutes.onboarding;
  }

  try {
    final perfil = await ProfileService.obterUsuarioPorAuthId(
      authUser.id,
    );

    if (perfil != null) {
      AuthService.loggedUser = perfil;
      ProfileService.registerModel = perfil;
      return AppRoutes.home;
    }

    AuthService.loggedUser = null;

    final telefone = authUser.userMetadata?['telefone']?.toString() ?? '';
    final emailConfirmado = authUser.emailConfirmedAt != null;

    if (emailConfirmado && telefone.trim().isNotEmpty) {
      ProfileService.registerModel
        ..authUserId = authUser.id
        ..telefone = telefone
        ..cep = await HelperPref.getCep() ?? '';
      return AppRoutes.name;
    }

    return AppRoutes.onboarding;
  } catch (e) {
    debugPrint('Erro ao restaurar sessão: $e');
    AuthService.loggedUser = null;
    return AppRoutes.onboarding;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente.
  await dotenv.load();

  // Inicializa o banco local.
  await LocalDb.db;

  // Inicializa o Supabase antes da autenticação Google.
  await Supabase.initialize(
    url: dotenv.get("SUPABASE_URL"),
    publishableKey: dotenv.get("SUPABASE_KEY"),
  );

  // Inicializa o login nativo com Google.
  await AuthHelper.initializeGoogleSignIn();

  // Inicializa os serviços do aplicativo.
  await Net.i.init();
  await LivroService.atualizarCache();

  // Conferência temporária do banco local.
  final locais = await (await LocalDb.db).query('livros');
  debugPrint('livros no aparelho: ${locais.length}');

  final rotaInicial = await rotaInicialPelaSessao();

  runApp(
  RodapeApp(
    initialRoute: rotaInicial,
  ),
);
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
      builder: (context, child) =>
          OfflineBanner(child: child ?? const SizedBox.shrink()),
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
        NearbyBooksStepScreen(
          cepInfo: settings.arguments as Address,
        ),
      );

    case AppRoutes.phone:
      final args = settings.arguments;

      return _buildRoute(
        settings,
        PhoneStepScreen(
          args: args is PhoneStepArgs ? args : const PhoneStepArgs(),
        ),
      );



    case AppRoutes.name:
      return _buildRoute(
        settings,
        NameStepScreen(
          telefone: settings.arguments as String? ??
              ProfileService.registerModel.telefone,
        ),
      );

    case AppRoutes.onboardingComplete:
      return _buildRoute(
        settings,
        OnboardingCompleteScreen(
          args: settings.arguments as OnboardingCompleteArgs,
        ),
      );

    case AppRoutes.home:
      return _buildRoute(settings, const RootShell());

    case AppRoutes.onboarding:
    default:
      return _buildRoute(settings, const OnboardingScreen());
  }
}

/// Todas as telas do fluxo compartilham a mesma transição (fade).
PageRouteBuilder<void> _buildRoute(
  RouteSettings settings,
  Widget child,
) {
  return PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => child,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Container principal do app: mantém as 5 abas vivas em um IndexedStack.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final GlobalKey<HomeScreenState> _homeKey =
    GlobalKey<HomeScreenState>();

  final GlobalKey<NearbyScreenState> _nearbyKey =
      GlobalKey<NearbyScreenState>();

  late final List<Widget> _screens = [
  HomeScreen(key: _homeKey),
  NearbyScreen(key: _nearbyKey),
  const ShelfScreen(),
  const WishlistScreen(),
  const ProfileScreen(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: RodapeBottomNav(
        currentIndex: _index,
       onTap: (i) {
  final mudouDeAba = _index != i;

  setState(() => _index = i);

  if (mudouDeAba && i == 0) {
    _homeKey.currentState?.atualizarAoRetornar();
  }

  if (i == 1) {
    _nearbyKey.currentState?.atualizarAoRetornar();
  }
},
      ),
    );
  }
}
