import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String secilenSehir;
  final myController = TextEditingController();

  void _showDialog(){
    showDialog(
        context: context,
        barrierDismissible: false, //boşluga tıklandığında kapansınmı
        builder: (ctx){
          return AlertDialog(
            title: Text("Geçersiz Bir Şehir Giriniz"),
            content: Text(
                "${myController.text}\n\n\n"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();//kapatmak için kullanıyoruz
                },
                child: Text("tamam"),
              ),

            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/search.jpg"),
        ),
      ),
      child: Scaffold(

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: myController,
                 /* onChanged: (value){
                    secilenSehir = value;
                    print(secilenSehir);
                  },*/
                  decoration: InputDecoration(hintText: "Şehir yazınız",
                  border: OutlineInputBorder(borderSide: BorderSide.none)
                  ),
                    style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,),
              ),
              FlatButton(onPressed: ()async{
                var response = await http.get("https://www.metaweather.com/api/location/search/?query=${myController.text}");
                jsonDecode(response.body).isEmpty
                    ?_showDialog()
                    :Navigator.pop(context,myController.text);
              }, child: Text("Şehri Seç"))
            ],
          ),
        ),
      ),
    );
  }
}
