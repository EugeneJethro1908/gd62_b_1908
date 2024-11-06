import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gd6_b_1908/entity/employee.dart';
import 'package:gd6_b_1908/inputPage.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF2196F3),
      ),
      home: const HomePage(
        title: 'firebase',
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("EMPLOYEE"),
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InputPage(
                            title: 'INPUT EMPLOYEE',
                            id: null,
                            name: null,
                            email: null)),
                  );
                }),
          ],
        ),
        body: StreamBuilder(
            stream: getEmployee(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Center(child: Text('Something went error !!'));
              }
              if (snapshot.hasData) {
                final Employee = snapshot.data!;
                return ListView(
                  children: Employee.map(buildEmployee).toList(),
                );
              } else {
                return Center(child: Text('No Data'));
              }
            }));
  }

  Widget buildEmployee(Employee employee) => Slidable(
        child: ListTile(
          title: Text(employee.name),
          subtitle: Text(employee.email),
        ),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputPage(
                      title: 'INPUT EMPLOYEE',
                      id: employee.id,
                      name: employee.name,
                      email: employee.email,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.update,
              label: 'Update',
            ),
            SlidableAction(
              onPressed: (context) async {
                final docEmployee = FirebaseFirestore.instance
                    .collection('employee')
                    .doc(employee.id);
                await docEmployee.delete();
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
      );

  Stream<List<Employee>> getEmployee() => FirebaseFirestore.instance
      .collection('employee')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Employee.fromJson(doc.data())).toList());
}
