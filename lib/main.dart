import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/my_home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lista de tarefas",
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: MyHome(),
    );
  }
}