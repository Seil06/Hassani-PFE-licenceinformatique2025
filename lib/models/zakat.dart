import 'package:myapp/models/don.dart';
import 'package:myapp/models/donateur.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/beneficiaire.dart';

class Zakat {
  final int? idZakat;
  final double montant;
  final DateTime date;
  final Donateur donateur;
  final Don don;
  final Association? association;
  final Beneficiaire? beneficiaire;

  Zakat({
    this.idZakat,
    required this.montant,
    required this.date,
    required this.donateur,
    required this.don,
    this.association,
    this.beneficiaire,
  }) {
    if (montant < 0) throw ArgumentError('Le montant ne peut pas être négatif');
    if (association == null && beneficiaire == null) {
      throw ArgumentError('Un zakat doit avoir une association ou un bénéficiaire');
    }
    if (association != null && beneficiaire != null) {
      throw ArgumentError('Un zakat ne peut pas avoir à la fois une association et un bénéficiaire');
    }
    if (don.typeDon != TypeDon.financier) {
      throw ArgumentError('Le don associé doit être de type financier');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id_zakat': idZakat,
      'montant': montant,
      'date': date.toIso8601String(),
      'id_donateur': donateur.id,
      'id_don': don.idDon,
      'id_association': association?.id,
      'id_beneficiaire': beneficiaire?.id,
    };
  }

  factory Zakat.fromMap(Map<String, dynamic> map) {
    return Zakat(
      idZakat: map['id_zakat'],
      montant: map['montant'] != null ? double.tryParse(map['montant'].toString()) ?? 0.0 : 0.0,
      date: DateTime.parse(map['date']),
      donateur: Donateur.fromMap(map['donateur']),
      don: Don.fromMap(map['don']),
      association: map['id_association'] != null ? Association.fromMap(map['association']) : null,
      beneficiaire: map['id_beneficiaire'] != null ? Beneficiaire.fromMap(map['beneficiaire']) : null,
    );
  }
}