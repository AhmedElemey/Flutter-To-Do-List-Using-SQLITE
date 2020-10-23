import 'package:flutter/material.dart';
import 'package:todoapp/database/todo_item.dart';
import 'database/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
        accentColor: Color.fromRGBO(209, 224, 224, 0.2),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ToDoItem> _todo = [];
  List<Widget> get _items => _todo.map((item) => format(item)).toList();
  String _name;
  Widget format(ToDoItem item) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Dismissible(
            key: Key(item.id.toString()),
            child: Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).accentColor,
                  shape: BoxShape.rectangle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0.0, 10),
                    )
                  ]),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
            onDismissed: (DismissDirection d) {
              DB.delete(ToDoItem.table, item);
              refresh();
            }));
  }

  void _create(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add Items"),
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    onChanged: (name) {
                      _name = name;
                    },
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(onPressed: () => _save(), child: Text("Save"))
            ],
          );
        });
  }

  void _save() async {
    Navigator.of(context).pop();
    ToDoItem item = ToDoItem(name: _name);
    await DB.insert(ToDoItem.table, item);
    setState(() => _name = '');
    refresh();
  }

  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    List<Map<String, dynamic>> _result = await DB.query(ToDoItem.table);
    _todo = _result.map((item) => ToDoItem.fromMap(item)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
              child: Text(
                "To-Do",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListView(
              children: _items,
              shrinkWrap: true,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _create(context),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
