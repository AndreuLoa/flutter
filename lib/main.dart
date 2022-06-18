import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State {
  String textoSalida = "Hola";
  String url = "https://proyectomixto1.azurewebsites.net/api/";
  TextEditingController input = TextEditingController();

  void cargar() async {
    String name = "person";
    //definir camara
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    File imagetemp = File(image.path);

    //transformar archivo a base64
    Uint8List bytes = await imagetemp.readAsBytes();
    String base64 = base64Encode(bytes);

    //http request
    Uri uri = Uri.parse(url + "postdb/?");
    name = input.text;
    if (name != "person") {
      var response = await http.post(uri,
          body: jsonEncode(<String, String>{'name': name, 'img': base64}));
      if (response.statusCode == 200) {
        setState(() {
          textoSalida = "Cargado " + name + " en la BD";
        });
      } else {
        setState(() {
          textoSalida = "Intente de nuevo";
        });
      }
    }
  }

  void verificar() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;

    File imagetemp = File(image.path);
    Uint8List bytes = await imagetemp.readAsBytes();
    String base64 = base64Encode(bytes);
    Uri uri = Uri.parse(url + "compare/");
    var response =
        await http.post(uri, body: jsonEncode(<String, String>{'img': base64}));
    setState(() {
      textoSalida = response.body.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Proyecto Mixto"),
        ),
        body: Column(
          children: [
            TextField(
              controller: input,
              decoration: const InputDecoration(
                hintText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              children: [
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () => cargar(), child: const Text("Cargar")),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () => verificar(), child: const Text("Verificar")),
                  ],
                ),
              ],
            ),
            Text(textoSalida),
          ],
        ),
      ),
    );
  }
}
