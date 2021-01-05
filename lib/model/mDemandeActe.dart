import 'package:firebase_database/firebase_database.dart';

class DemandeActe {
  String key;
  String matricule = "Entrer le matricule";
  String nom = "Entrer votre nom et prenom";
  String telephone = "Entrer votre numero de telephone";
  String email = "Entrer votre email";
  String datePriseService = "Entrer votre date de prise de service";
  String emploi = "Choisir votre emploi";
  String natureActe = "Choisir la nature de l'acte";
  String pieceJointe = "Ajouter une piece jointe";
  String motif = "Choisir le motif";
  int numeroDemande;
  int statuts;
  String deviceId = "";
  DemandeActe(
    this.key,
    this.deviceId,
    this.matricule,
    this.nom,
    this.telephone,
    this.email,
    this.datePriseService,
    this.emploi,
    this.natureActe,
    this.pieceJointe,
    this.motif,
    this.numeroDemande,
    this.statuts,
  );

  DemandeActe.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.value['key'],
        deviceId = snapshot.value["deviceId"],
        matricule = snapshot.value["matricule"],
        nom = snapshot.value["nom"],
        telephone = snapshot.value["telephone"],
        email = snapshot.value["email"],
        datePriseService = snapshot.value["datePriseService"],
        emploi = snapshot.value["emploi"],
        natureActe = snapshot.value["natureActe"],
        pieceJointe = snapshot.value["pieceJointe"],
        numeroDemande = snapshot.value["numeroDemande"],
        motif = snapshot.value["motif"],
        statuts = snapshot.value["statuts"];

  @override
  String toString() {
    return 'DemandeActe{key: $key, matricule: $matricule, nom: $nom, telephone: $telephone, email: $email, datePriseService: $datePriseService, emploi: $emploi, natureActe: $natureActe, pieceJointe: $pieceJointe, motif: $motif, numeroDemande: $numeroDemande, statuts: $statuts, deviceId: $deviceId}';
  }

  toJson() {
    return {
      "key": key,
      "deviceId": deviceId,
      "matricule": matricule,
      "nom": nom,
      "telephone": telephone,
      "datePriseService": datePriseService,
      "emploi": emploi,
      "natureActe": natureActe,
      "pieceJointe": pieceJointe,
      "motif": motif,
      "numeroDemande": numeroDemande,
    };
  }
}
