import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Splash em Flutter: exibe `splash.png` enquanto o app inicializa
/// (.env, banco local, Supabase, cache...) e, ao terminar, troca para a
/// rota devolvida por [inicializar], limpando a pilha.
///
/// Vem logo depois da splash nativa, que tem só a mesma cor de fundo — por
/// isso a troca entre as duas não pisca.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.inicializar});

  /// Faz as inicializações e devolve a rota para onde seguir.
  final Future<String> Function() inicializar;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Tempo mínimo na tela, para a marca não "piscar" quando a
  /// inicialização for muito rápida.
  static const _tempoMinimo = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final minimo = Future<void>.delayed(_tempoMinimo);
    final rota = await widget.inicializar();
    await minimo;

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(rota, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Decodifica a imagem no tamanho da tela, não nos 1290×2796 originais.
    final larguraPx = (media.size.width * media.devicePixelRatio).round();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.splashBackground,
      ),
      child: ColoredBox(
        color: AppColors.splashBackground,
        // `contain` + fundo da mesma cor da imagem: a arte aparece inteira
        // (sem cortar o nome/slogan) em qualquer proporção de tela, e a
        // sobra vira fundo contínuo.
        child: SizedBox.expand(
          child: Image.asset(
            'lib/assets/images/splash.png',
            fit: BoxFit.contain,
            cacheWidth: larguraPx > 0 ? larguraPx : null,
            semanticLabel: 'Rodapé — troca de livros em roda',
            frameBuilder: (context, child, frame, carregouSincrono) {
              if (carregouSincrono) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
