
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/profile_service.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    final user = AuthService.loggedUser;

    if (user != null) {
      _nomeController.text = user.nome;
      _sobrenomeController.text = user.sobrenome;
      _telefoneController.text = user.telefone;
      _cepController.text = user.cep;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AuthService.loggedUser;

    if (user == null) return;

    final nomeAnterior = user.nome;
    final sobrenomeAnterior = user.sobrenome;
    final telefoneAnterior = user.telefone;
    final cepAnterior = user.cep;

    setState(() => _salvando = true);

    try {
      user.nome = _nomeController.text.trim();
      user.sobrenome = _sobrenomeController.text.trim();
      user.telefone = _telefoneController.text.trim();
      user.cep = _cepController.text.replaceAll(RegExp(r'\D'), '');

      final atualizado =
          await ProfileService.atualizarDadosPessoais(user);

      if (atualizado == null) {
        throw Exception('Não foi possível atualizar o perfil.');
      }

      AuthService.loggedUser = atualizado;

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      user.nome = nomeAnterior;
      user.sobrenome = sobrenomeAnterior;
      user.telefone = telefoneAnterior;
      user.cep = cepAnterior;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar perfil: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      appBar: AppBar(
        backgroundColor: AppColors.wood800,
        foregroundColor: AppColors.paper050,
        title: Text(
          'Editar perfil',
          style: AppTextStyles.display(
            fontSize: 22,
            color: AppColors.paper050,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'DADOS PESSOAIS',
              style: AppTextStyles.mono(
                fontSize: 11,
                color: AppColors.paperGray600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _campo(
              label: 'Nome',
              controller: _nomeController,
            ),
            _campo(
              label: 'Sobrenome',
              controller: _sobrenomeController,
            ),
            _campo(
              label: 'Telefone',
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
            ),
            _campo(
              label: 'CEP',
              controller: _cepController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
            ),

            const SizedBox(height: 28),

            RodapeButton(
              label: _salvando ? 'Salvando...' : 'Salvar alterações',
              icon: Icons.save_outlined,
              onPressed: _salvando ? null : _salvar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Preencha este campo.';
          }

          if (label == 'CEP' &&
              value.replaceAll(RegExp(r'\D'), '').length != 8) {
            return 'Informe um CEP com 8 dígitos.';
          }

          return null;
        },
      ),
    );
  }
}
