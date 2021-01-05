import 'package:admin_rhmef/constantes.dart';
import 'package:admin_rhmef/model/actualites.dart';
import 'package:admin_rhmef/net/firebase.dart';
import 'package:admin_rhmef/net/selectFileSystem.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MyActView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ActualitesAdminist(),
      ),
    );
  }
}

class ActualitesAdminist extends StatefulWidget {
  ActualitesAdminist({Key key}) : super(key: key);

  @override
  _ActualitesAdministState createState() => _ActualitesAdministState();
}

class _ActualitesAdministState extends State<ActualitesAdminist> {
  final myTitleController = TextEditingController();
  final myAuthorController = TextEditingController();
  final myDescriptionController = TextEditingController();
  final myLinkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("Gerer les Actualitees"),
          centerTitle: true,
          backgroundColor: Colors.orangeAccent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person),
              title: new TextField(
                controller: myTitleController,
                decoration: new InputDecoration(
                  hintText: "Title",
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: new TextField(
                controller: myAuthorController,
                decoration: new InputDecoration(
                  hintText: "Author",
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: new TextField(
                controller: myDescriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: new InputDecoration(
                  hintText: "Description",
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: new TextField(
                decoration: new InputDecoration(
                  hintText: "ImageUrl",
                ),
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString(ConstantesValues.prefs_imageName,
                      DateTime.now().toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectFileSys()),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: new TextField(
                controller: myLinkController,
                decoration: new InputDecoration(
                  hintText: "Link",
                ),
              ),
            ),
            ListTile(
              title: FlatButton(
                color: Colors.orange,
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Valider",
                  style: TextStyle(fontSize: 20.0),
                ),
                onPressed: () async {
                  initializeDateFormatting();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String piece = prefs.getString("imageUrl");
                  String title = controllerValue(myTitleController);
                  String author = controllerValue(myAuthorController);
                  String description = controllerValue(myDescriptionController);
                  String link = controllerValue(myLinkController);

                  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  Actualites actualites = Actualites(
                      '', title, description, author, date, piece, link);
                  newsSetup(actualites);
                  print('$title $description $author $date $piece $link');
                  // prefs.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initState() {
    super.initState();
    initializeDateFormatting().then((_) {});
  }

  String controllerValue(TextEditingController controller) {
    String text =
        controller.value.text.isNotEmpty ? myTitleController.value.text : "N/A";
    return text;
  }
}
