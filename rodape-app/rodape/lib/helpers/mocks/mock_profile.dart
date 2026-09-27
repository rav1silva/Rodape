import '../models/circulation_entry.dart';
import '../models/credit_transaction.dart';
import '../models/user_profile.dart';
import '../../theme/app_colors.dart';

class MockProfile {
  MockProfile._();

  static const user = UserProfile(
    nome: 'Ana Lemos',
    iniciais: 'AL',
    desde: '03/2025',
    saldoCredito: 4,
    validadeCredito: '12/10',
    entregues: 23,
    recebidos: 21,
    rodas: 9,
    freteMaximo: 25,
  );

  static const List<CreditTransaction> extrato = [
    CreditTransaction(data: '25/08', descricao: 'entrega O cortiço', valor: 1),
    CreditTransaction(data: '02/08', descricao: 'resgate Torto arado', valor: -1),
    CreditTransaction(
      data: '30/07',
      descricao: 'entrega Quarto de despejo',
      valor: 1,
    ),
    CreditTransaction(
      data: '15/07',
      descricao: 'expirado sem resgate',
      valor: -1,
    ),
  ];

  static const List<CirculationEntry> historico = [
    CirculationEntry(
      titulo: 'Quarto de despejo',
      spineColor: AppColors.spineTeal,
      coverAsset: 'lib/assets/images/quarto de despejo.jpg',
      maos: 4,
      statusLabel: 'Foi para Diego F. · 12/07',
    ),
    CirculationEntry(
      titulo: 'Memórias póstumas',
      spineColor: AppColors.spineOlive,
      coverAsset: 'lib/assets/images/memorias postumas.jpg',
      maos: 7,
      statusLabel: 'Foi para Luísa R. · 28/06',
    ),
    CirculationEntry(
      titulo: 'O cortiço',
      spineColor: AppColors.spineOrange,
      coverAsset: 'lib/assets/images/o cortico.jpg',
      maos: 3,
      statusLabel: 'A caminho de Bruno M.',
      statusColor: AppColors.spineTeal,
    ),
  ];
}
