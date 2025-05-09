import 'package:myapp/models/association.dart';
import 'package:myapp/models/beneficiaire.dart';
import 'package:myapp/models/donateur.dart';
import 'package:myapp/models/post.dart';

enum EtatDon { enAttente, valide, refuse, enCours, termine }

class Don {
  final int? idDon;
  final String numCarteBancaire;
  final DateTime dateDon;
  final TypeDon typeDon;
  final EtatDon etat;
  final Donateur donateurAssocie;
  final Campagne? campagneAssociee;
  final Beneficiaire? beneficiaireAssocie;
  final Post? postAssocie;
  final List<Association> associationsAssociees;

  Don({
    this.idDon,
    required this.numCarteBancaire,
    required this.dateDon,
    required this.typeDon,
    required this.etat,
    required this.donateurAssocie,
    this.campagneAssociee,
    this.beneficiaireAssocie,
    this.postAssocie,
    this.associationsAssociees = const [],
  }) {
    if (numCarteBancaire.isNotEmpty &&
        !RegExp(r'^\d{16}$').hasMatch(numCarteBancaire)) {
      throw ArgumentError('Numéro de carte bancaire invalide');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id_don': idDon,
      'num_carte_bancaire': numCarteBancaire,
      'date_don': dateDon.toIso8601String(),
      'type_don': typeDon.name,
      'etat_don': etat.name,
      'id_donateur': donateurAssocie.id,
      'id_campagne': campagneAssociee?.idPost,
      'id_beneficiaire': beneficiaireAssocie?.id,
      'id_post': postAssocie?.idPost,
    };
  }

  factory Don.fromMap(Map<String, dynamic> map) {
    return Don(
      idDon: map['id_don'],
      numCarteBancaire: map['num_carte_bancaire'],
      dateDon: DateTime.parse(map['date_don']),
      typeDon: TypeDon.values.byName(map['type_don']),
      etat: EtatDon.values.byName(map['etat_don']),
      donateurAssocie: Donateur.fromMap(map['donateur']),
      campagneAssociee: map['id_campagne'] != null
          ? Campagne.fromMap(map['campagne'])
          : null,
      beneficiaireAssocie: map['id_beneficiaire'] != null
          ? Beneficiaire.fromMap(map['beneficiaire'])
          : null,
      postAssocie: map['id_post'] != null ? Post.fromMap(map['post']) : null,
      associationsAssociees: [], // Load via separate query
    );
  }
}