import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
} 

class _MyHomeState extends State<MyHome> {
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;
  final _textinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> novaTarefa = Map();
      novaTarefa["Title"] = _textinController.text;
      _textinController.text = "";
      novaTarefa["ok"] = false;
      _toDoList.add(novaTarefa);
      _salveData();
    });
  }

  // essa fincao e para obter o arquivo
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

// essa funcao e para salvar o arquivo
  Future<File> _salveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

// essa funcao e para ler os dados do arquivo
  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {
    _toDoList.sort((a, b){
      if (a["ok"] && !b["ok"]) return 1;
      else if (!a["ok"] && b["ok"]) return -1;
      else return 0;
    });
    _salveData();
    });
  return null;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textinController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        border: InputBorder.none,
                        labelStyle: TextStyle(
                          color: Colors.blueAccent,
                        )),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  onPressed: _addToDo,
                  child: Text("Add"),
                  textColor: Colors.white,
                )
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: RefreshIndicator(
              child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _toDoList.length,
              itemBuilder: buildItem
            ), onRefresh: _refresh,
            )
          )
        ],
      ),
    );
  }

Widget buildItem (context, index) {
  return Dismissible(
    key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
    background: Container(
      color: Colors.blueAccent.withOpacity(0.6),
      child: Align(
        alignment: Alignment(-0.9, 0.0),
        child: Icon(Icons.delete,
        color: Colors.white),
      ),
    ),
    direction: DismissDirection.startToEnd,
    child:
  CheckboxListTile(
    title: Text(_toDoList[index]["Title"]),
    value: _toDoList[index]["ok"],
    secondary: CircleAvatar(
    child: Icon(
    _toDoList[index]["ok"] ? Icons.check : Icons.error),
    ),
    onChanged: (c) {
    setState(() {
    _toDoList[index]["ok"] = c;
    _salveData();
    });
    },
    ),
    onDismissed: (direction){
      setState(() {
      _lastRemoved = Map.from(_toDoList[index]);
      _lastRemovedPos = index;
      _toDoList.removeAt(index);
      _salveData();

    final snack = SnackBar(
      content: Text(
        "Tarefa ${_lastRemoved["Title"]} removida!"
      ),
      action: SnackBarAction(label: "Desfazer",
      onPressed: (){setState((){
        _toDoList.insert(_lastRemovedPos, _lastRemoved);
        _salveData();
          });}
        ),
        duration: Duration(
          seconds: 2
          ),
        );
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snack);
     });},
    );
  }
}
