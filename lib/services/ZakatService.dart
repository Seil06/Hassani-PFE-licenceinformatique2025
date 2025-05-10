import 'package:myapp/models/don.dart';
import 'package:myapp/models/donateur.dart';
import 'package:myapp/models/association.dart';
import 'package:myapp/models/beneficiaire.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Zakat {
  final int? idZakat;
  final Donateur donateur;
  final double montant;
  final DateTime date;
  final Don donAssocie;
  final Association? association;
  final Beneficiaire? beneficiaire;

  Zakat({
    this.idZakat,
    required this.donateur,
    required this.montant,
    required this.date,
    required this.donAssocie,
    this.association,
    this.beneficiaire,
  }) {
    if (montant < 0) throw ArgumentError('Le montant ne peut pas être négatif');
    if (association == null && beneficiaire == null) {
      throw ArgumentError('Un zakat doit être associé à une association ou un bénéficiaire');
    }
    if (association != null && beneficiaire != null) {
      throw ArgumentError('Un zakat ne peut être associé à la fois à une association et un bénéficiaire');
    }
    if (donAssocie.typeDon != TypeDon.financier) {
      throw ArgumentError('Le don associé doit être de type financier');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id_zakat': idZakat,
      'id_donateur': donateur.id,
      'montant': montant,
      'date': date.toIso8601String(),
      'id_don': donAssocie.idDon,
      'id_association': association?.id,
      'id_beneficiaire': beneficiaire?.id,
    };
  }

  factory Zakat.fromMap(Map<String, dynamic> map) {
    return Zakat(
      idZakat: map['id_zakat'],
      donateur: Donateur.fromMap(map['donateur']),
      montant: map['montant'] != null ? double.tryParse(map['montant'].toString()) ?? 0.0 : 0.0,
      date: DateTime.parse(map['date']),
      donAssocie: Don.fromMap(map['don']),
      association: map['id_association'] != null ? Association.fromMap(map['association']) : null,
      beneficiaire: map['id_beneficiaire'] != null ? Beneficiaire.fromMap(map['beneficiaire']) : null,
    );
  }
}

class ParametreZakat {
  final int? idParametre;
  final String cle;
  final double valeur;
  final DateTime dateMiseAJour;

  ParametreZakat({
    this.idParametre,
    required this.cle,
    required this.valeur,
    required this.dateMiseAJour,
  }) {
    if (cle.isEmpty) throw ArgumentError('La clé ne peut pas être vide');
    if (valeur < 0) throw ArgumentError('La valeur ne peut pas être négative');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_parametre': idParametre,
      'cle': cle,
      'valeur': valeur,
      'date_mise_a_jour': dateMiseAJour.toIso8601String(),
    };
  }

  factory ParametreZakat.fromMap(Map<String, dynamic> map) {
    return ParametreZakat(
      idParametre: map['id_parametre'],
      cle: map['cle'],
      valeur: map['valeur'],
      dateMiseAJour: DateTime.parse(map['date_mise_a_jour']),
    );
  }
}

class BienZakat {
  final int? idBien;
  final String typeBien;
  final double valeur;
  final int idDonateur;
  final DateTime dateEvaluation;

  BienZakat({
    this.idBien,
    required this.typeBien,
    required this.valeur,
    required this.idDonateur,
    required this.dateEvaluation,
  }) {
    if (typeBien.isEmpty) throw ArgumentError('Le type de bien ne peut pas être vide');
    if (valeur < 0) throw ArgumentError('La valeur ne peut pas être négative');
  }

  Map<String, dynamic> toMap() {
    return {
      'id_bien': idBien,
      'type_bien': typeBien,
      'valeur': valeur,
      'id_donateur': idDonateur,
      'date_evaluation': dateEvaluation.toIso8601String(),
    };
  }

  factory BienZakat.fromMap(Map<String, dynamic> map) {
    return BienZakat(
      idBien: map['id_bien'],
      typeBien: map['type_bien'],
      valeur: map['valeur'],
      idDonateur: map['id_donateur'],
      dateEvaluation: DateTime.parse(map['date_evaluation']),
    );
  }
}

class ZakatService {
  static Future<double> calculerZakat({
    required int idDonateur,
  }) async {
    final supabase = Supabase.instance.client;

    // Fetch nisab from parametre_zakat
    final parametreResponse = await supabase
        .from('parametre_zakat')
        .select('valeur')
        .eq('cle', 'nisab')
        .single();

    final double nisab = parametreResponse['valeur'] ?? 595 * 85; // Fallback

    // Fetch assets from bien_zakat
    final biensResponse = await supabase
        .from('bien_zakat')
        .select('valeur')
        .eq('id_donateur', idDonateur);

    final double total = biensResponse.fold(0.0, (sum, bien) => sum + (bien['valeur'] as double));

    if (total >= nisab) {
      return total * 0.025; // 2.5% per Islamic principles
    }
    return 0.0;
  }

  static Future<Zakat> createZakat({
    required Donateur donateur,
    required double montant,
    required Don donAssocie,
    Association? association,
    Beneficiaire? beneficiaire,
  }) async {
    final supabase = Supabase.instance.client;

    final zakatData = Zakat(
      donateur: donateur,
      montant: montant,
      date: DateTime.now(),
      donAssocie: donAssocie,
      association: association,
      beneficiaire: beneficiaire,
    ).toMap();

    final response = await supabase.from('zakat').insert(zakatData).select().single();
    return Zakat.fromMap(response);
  }
}