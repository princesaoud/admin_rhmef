import 'package:admin_rhmef/model/mDemandeActe.dart';
import 'package:admin_rhmef/net/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AdminDemandeActe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: AdminDemandeActes(),
      ),
    );
  }
}

class AdminDemandeActes extends StatefulWidget {
  @override
  _AdminDemandeActesState createState() => _AdminDemandeActesState();
}

class _AdminDemandeActesState extends State<AdminDemandeActes> {
  int sumDemande = 0;
  FlutterLocalNotificationsPlugin fltrNotification;
  var mySearchController = TextEditingController();
  List _allResults = [];
  Future resultLoaded;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountDemande();
    var androidInitilize =
        new AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);

    mySearchController.addListener(onSearchTextChanged);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mySearchController.removeListener(onSearchTextChanged);
    mySearchController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.pending_actions_sharp)),
                Tab(icon: Icon(Icons.cloud_download_rounded)),
                Tab(icon: Icon(Icons.download_done_sharp))
              ],
            ),
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: const Text("Gerer les Demandes"),
            centerTitle: true,
            backgroundColor: Colors.green,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  Container(
                    child: Card(
                      child: ListTile(
                        title: TextField(
                          controller: mySearchController,
                          decoration: new InputDecoration(
                              hintText: 'Recherche', border: InputBorder.none),
                        ),
                        trailing: new IconButton(
                          icon: new Icon(Icons.cancel),
                          onPressed: () {
                            mySearchController.clear();
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Expanded(child: SizedBox(child: getTab1())),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    child: Card(
                      child: ListTile(
                        title: TextField(
                          controller: mySearchController,
                          decoration: new InputDecoration(
                              hintText: 'Recherche', border: InputBorder.none),
                        ),
                        trailing: new IconButton(
                          icon: new Icon(Icons.cancel),
                          onPressed: () {
                            mySearchController.clear();
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: getTab2(),
                    ),
                  ),
                ],
              ),
              Container()
            ],
          ),
        ),
      ),
    );
  }

  void getCountDemande() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sumDemande = prefs.getInt("sum_demand");
    // print(sumDemande);
  }

  void setCountDemande(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("sum_demand", value);
    // print(sumDemande);
  }

  Widget getTab2() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("ActeDemand")
            .orderBy('updated', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                if (snapshot.hasError) {
                  print("Something went wrong");
                  return Center(
                    child: Text("Something went wrong"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("Waiting for data");
                  return Center(
                    child: Text("Waiting for data ..."),
                  );
                }
                if (sumDemande != snapshot.data.docs.length) {
                  //TODO: send notification
                  int nbrActe = snapshot.data.docs.length - sumDemande;
                  if (nbrActe > 0) {
                    // var channelId = new Random().nextInt(100);
                    _showNotification("Demande d'acte",
                        "$nbrActe  Demande d'acte en attente", 1);
                  } else {
                    _showNotification("Demande d'acte",
                        "Nouvelle demande d'acte en attente", 1);
                  }
                  setCountDemande(snapshot.data.docs.length);
                }
                // _addBadge();
                DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                // print(documentSnapshot.id);
                DemandeActe demandeActe = DemandeActe(
                    documentSnapshot.data()['key'],
                    documentSnapshot.data()['deviceId'],
                    documentSnapshot.data()['matricule'],
                    documentSnapshot.data()['nom'],
                    documentSnapshot.data()['telephone'],
                    documentSnapshot.data()['email'],
                    documentSnapshot.data()['datePriseService'],
                    documentSnapshot.data()['emploi'],
                    documentSnapshot.data()['natureActe'],
                    documentSnapshot.data()['pieceJointe'],
                    documentSnapshot.data()['motif'],
                    documentSnapshot.data()['numeroDemande'],
                    documentSnapshot.data()['statuts']);
                if (demandeActe.statuts == 1) {
                  // print(demandeActe.toString());
                  return getRowComplete(demandeActe);
                }
                return Container();
              });
        });
  }

  Widget getTab1() {
    getCountDemande();
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("ActeDemand")
            .orderBy('updated', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                if (snapshot.data == null) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  print("Something went wrong");
                  return Center(
                    child: Text("Something went wrong"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("Waiting for data");
                  return Center(
                    child: Text("Waiting for data ..."),
                  );
                }

                if (sumDemande > snapshot.data.docs.length) {
                  //TODO: send notification
                  int nbrActe = snapshot.data.docs.length - sumDemande;
                  if (nbrActe > 0) {
                    // var channelId = new Random().nextInt(100);
                    _showNotification("Demande d'acte",
                        "$nbrActe  Demande d'acte en attente", 1);
                  } else {
                    _showNotification("Demande d'acte",
                        "Nouvelle demande d'acte en attente", 1);
                  }
                  setCountDemande(snapshot.data.docs.length);
                }
                // _addBadge();
                DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                // print(documentSnapshot.id);
                DemandeActe demandeActe = DemandeActe(
                    documentSnapshot.data()['key'],
                    documentSnapshot.data()['deviceId'],
                    documentSnapshot.data()['matricule'],
                    documentSnapshot.data()['nom'],
                    documentSnapshot.data()['telephone'],
                    documentSnapshot.data()['email'],
                    documentSnapshot.data()['datePriseService'],
                    documentSnapshot.data()['emploi'],
                    documentSnapshot.data()['natureActe'],
                    documentSnapshot.data()['pieceJointe'],
                    documentSnapshot.data()['motif'],
                    documentSnapshot.data()['numeroDemande'],
                    documentSnapshot.data()['statuts']);
                if (demandeActe.statuts == 0) {
                  // print(demandeActe.toString());
                  return getRow(demandeActe);
                }
                return Container();
              });
        });
  }

  Widget getRow(DemandeActe demandeActe) {
    return new Padding(
        padding: new EdgeInsets.all(1.0),
        child: new Card(
          child: new Column(
            children: <Widget>[
              new ListTile(
                title: new Text(
                    "Numero de demande : ${demandeActe.numeroDemande}"),
              ),
              new ListTile(
                title: new Text("Matricule : ${demandeActe.matricule}"),
              ),
              new ListTile(
                title: new Text("Nom & Prenom : ${demandeActe.nom}"),
              ),
              new ListTile(
                title: new Text("Email : ${demandeActe.email}"),
              ),
              new ListTile(
                title: new Text("Emploi : ${demandeActe.emploi}"),
              ),
              new ListTile(
                title: new Text(
                    "Date de prise de service : ${demandeActe.datePriseService}"),
              ),
              new ListTile(
                title: new Text("Numero d'acte : ${demandeActe.natureActe}"),
              ),
              new ListTile(
                title: new Text("Motif : ${demandeActe.motif}"),
              ),
              new ListTile(
                title: new Text("Piece Jointe : ${demandeActe.pieceJointe}"),
              ),
              // ignore: deprecated_member_use
              new ButtonTheme.bar(
                child: new ButtonBar(
                  children: <Widget>[
                    new FlatButton(
                        child: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                        onPressed: () async {
                          //TODO: Send notification to the sepcific device that own the demand selected
                          List<String> tokens = [demandeActe.deviceId];
                          String descrition =
                              "La Demande d'acte No: ${demandeActe.numeroDemande} est en cours de validation";
                          var result = await callOnFcmApiSendPushNotifications(
                              tokens, descrition);
                          demandeUpdate(demandeActe.key, "statuts", 1);
                          print(result);
                        }),
                    new FlatButton(
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        // print(demandeActe.key);
                        List<String> userToken = [demandeActe.deviceId];
                        String description =
                            "Demande d'acte rejeter: Dossier incomplet";
                        callOnFcmApiSendPushNotifications(
                            userToken, description);
                        // demandeUpdate(demandeActe.key, "statuts", 1);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget getRowComplete(DemandeActe demandeActe) {
    return new Padding(
        padding: new EdgeInsets.all(1.0),
        child: new Card(
          child: new Column(
            children: <Widget>[
              new ListTile(
                title: new Text(
                    "Numero de demande : ${demandeActe.numeroDemande}"),
              ),
              new ListTile(
                title: new Text("Matricule : ${demandeActe.matricule}"),
              ),
              new ListTile(
                title: new Text("Nom & Prenom : ${demandeActe.nom}"),
              ),
              new ListTile(
                title: new Text("Email : ${demandeActe.email}"),
              ),
              new ListTile(
                title: new Text("Emploi : ${demandeActe.emploi}"),
              ),
              new ListTile(
                title: new Text(
                    "Date de prise de service : ${demandeActe.datePriseService}"),
              ),
              new ListTile(
                title: new Text("Numero d'acte : ${demandeActe.natureActe}"),
              ),
              new ListTile(
                title: new Text("Motif : ${demandeActe.motif}"),
              ),
              new ListTile(
                title: new Text("Piece Jointe : ${demandeActe.pieceJointe}"),
              ),
              // ignore: deprecated_member_use
              new ButtonTheme.bar(
                child: new ButtonBar(
                  children: <Widget>[
                    new FlatButton(
                        child: const Text(
                          'Complete Demande',
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                        onPressed: () async {
                          //TODO: Send notification to the sepcific device that own the demand selected
                          List<String> tokens = [demandeActe.deviceId];
                          var result = await callOnFcmApiSendPushNotifications(
                              tokens,
                              "Votre demande demande d'acte est disponible et peut etre retire");
                          print("Complete demande result: $result");
                        }),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Future _showNotification(
      String titre, String description, int channelId) async {
    // print('notification is going to be shown');
    var androidDetails = new AndroidNotificationDetails(
        "$channelId", "YKK programmer", "This is my MEF channel",
        importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    await fltrNotification.show(
        channelId, "$titre", description, generalNotificationDetails,
        payload: "DemandeActe");
  }

  Future notificationSelected(String payload) async {
    showDialog(
      builder: (context) => AlertDialog(
        content: Text("Notification : $payload"),
      ),
      context: context,
    );
  }

  void onSearchTextChanged() {
    print(mySearchController.text);
  }

  getDemandeActeList() async {
    var data = await FirebaseFirestore.instance
        .collection("ActeDemand")
        .orderBy('updated', descending: true)
        .get();
    setState(() {
      _allResults = data.docs;
    });
    return "complete";
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    resultLoaded = getDemandeActeList();
  }
}
