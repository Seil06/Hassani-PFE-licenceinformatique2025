import 'package:myapp/models/don.dart';
import 'package:myapp/models/donateur.dart';

class Zakat {
  final int? idZakat;
  final Donateur donateur;
  final double montant;
  final DateTime date;
  final Don? donAssocie;

  Zakat({
    this.idZakat,
    required this.donateur,
    required this.montant,
    required this.date,
    this.donAssocie,
  }) {
    if (montant < 0) throw ArgumentError('Le montant ne peut pas être négatif');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_zakat': idZakat,
      'id_donateur': donateur.id,
      'montant': montant,
      'date': date.toIso8601String(),
      'id_don': donAssocie?.idDon,
    };
  }

  factory Zakat.fromMap(Map<String, dynamic> map) {
    return Zakat(
      idZakat: map['id_zakat'],
      donateur: Donateur.fromMap(map['donateur']),
      montant: map['montant'],
      date: DateTime.parse(map['date']),
      donAssocie: map['id_don'] != null ? Don.fromMap(map['don']) : null,
    );
  }

  static double calculerZakat({
    required double argentLiquide,
    required double orArgent,
    required double investissements,
  }) {
    const double nisab = 595 * 85; // Example: 595g gold at $85/g
    final double total = argentLiquide + orArgent + investissements;
    if (total >= nisab) {
      return total * 0.025; // 2.5% per Islamic principles
    }
    return 0.0;
  }
}