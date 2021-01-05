import 'package:firebase_database/firebase_database.dart';

class Actualites {
  String key;
  String title;
  String subtitle;
  String author;
  String publishedDate;
  String imageAsset;
  String link;

  Actualites(this.key, this.title, this.subtitle, this.author,
      this.publishedDate, this.imageAsset, this.link);

  Actualites.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value["title"],
        subtitle = snapshot.value["subtitle"],
        author = snapshot.value["author"],
        publishedDate = snapshot.value["publishedDate"],
        link = snapshot.value["link"],
        imageAsset = snapshot.value["imageAsset"];

  toJson() {
    return {
      "title": title,
      "subtitle": subtitle,
      "author": author,
      "publishedDate": publishedDate,
      "imageAsset": imageAsset,
      "link": link,
    };
  }
}
