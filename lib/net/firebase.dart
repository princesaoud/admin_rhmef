import 'dart:convert';
import 'dart:math';

import 'package:admin_rhmef/model/actualites.dart';
import 'package:admin_rhmef/model/mDemandeActe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

Future<void> newsSetup(Actualites actualites) async {
  CollectionReference newsadd = FirebaseFirestore.instance.collection('News');
  // FirebaseAuth auth = FirebaseAuth.instance;
  // String uid = auth.currentUser.uid.toString();
  newsadd.add({
    'Title': actualites.title,
    'Description': actualites.subtitle,
    'Author': actualites.author,
    'DatePosted': actualites.publishedDate,
    'Link': actualites.link,
    'ImageUrl': actualites.imageAsset,
  });
  return;
}

Future<void> demandeActeSetup(DemandeActe _demandeacte) async {
  int numeroDemande = Random().nextInt(10000);
  CollectionReference acteDemand =
      FirebaseFirestore.instance.collection('ActeDemand');
  FirebaseMessaging().getToken().then((token) {
    print("token of the device is : $token");
    acteDemand.add({
      'key': _demandeacte.key,
      'deviceId': token,
      'matricule': _demandeacte.matricule,
      'nom': _demandeacte.nom,
      'telephone': _demandeacte.telephone,
      'email': _demandeacte.email,
      'datePriseService': _demandeacte.datePriseService,
      'emploi': _demandeacte.emploi,
      'natureActe': _demandeacte.natureActe,
      'pieceJointe': _demandeacte.pieceJointe,
      'motif': _demandeacte.motif,
      'statuts': _demandeacte.statuts,
      'numeroDemande': '$numeroDemande',
      'updated': DateTime.now(),
    });
  });

  return;
}

Future<bool> callOnFcmApiSendPushNotifications(
    List<String> userToken, String description) async {
  final postUrl = 'https://fcm.googleapis.com/fcm/send';
  final data = {
    "registration_ids": userToken,
    "collapse_key": "type_a",
    "notification": {
      "title": 'Admin RHMEF',
      "body": '$description',
    }
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization':
        "key=AAAAaawcmpI:APA91bEeT9AILBkw6qHzJji5GDPLM6hmqNKg15PRiQOxVeL51G1E3_JJreqWNOMqQmTY5wuysN3Bpvb7WrJVDVQz6LkG-B-jquU7aDP4SqMHndLy7tztuUyByGJHyJ1kxEzDLusNUhMo" // 'key=YOUR_SERVER_KEY'
  };

  final response = await http.post(postUrl,
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
    // on success do sth
    print('test ok push CFM');
    return true;
  } else {
    print(response.body);
    print(' CFM error');
    // on failure do sth
    return false;
  }
}

Future<void> demandeUpdate(String key, String field, var value) {
  CollectionReference myRef =
      FirebaseFirestore.instance.collection("ActeDemand");
  return myRef
      .doc(key)
      .update({'$field': value})
      .then((value) => print("Status changed successfuly"))
      .catchError((onError) => print("Failed to update: $onError"));
}
