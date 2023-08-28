import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hris/models/md_todos.dart';
import 'package:http/http.dart'
    as http; // ดึงข้อมูลจัดการข้อมูลบนเครือข่าย internet

class OTRecordScreen extends StatefulWidget {
  const OTRecordScreen({super.key});

  @override
  State<OTRecordScreen> createState() => _OTRecordScreenState();
}

class _OTRecordScreenState extends State<OTRecordScreen> {
  late Future<List<Todos>> oAryTodos;

  @override
  void initState() {
    super.initState();
    oAryTodos = fetchData();
  }

  void refreshData() {
    setState(() {
      oAryTodos = fetchData();
    });
  }

  Future<List<Todos>> fetchData() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/todos'));

    if (response.statusCode == 200) {
      return compute((message) => parseTodos(response.body), response.body);
      // final parsed = jsonDecode(response.body)['todos'].cast<Map<String, dynamic>>();
      // return parsed.map<Todos>((json) => Todos.fromJson(json)).toList();
    } else {
      // กรณี error
      throw Exception('Failed to load todos');
    }
  }

  List<Todos> parseTodos(String responseBody) {
    final parsed =
        jsonDecode(responseBody)['todos'].cast<Map<String, dynamic>>();
    return parsed.map<Todos>((json) => Todos.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OT Record'),
      ),
      body: Center(
        child: FutureBuilder<List<Todos>>(
            future: oAryTodos,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration:
                          BoxDecoration(color: Colors.teal.withAlpha(100)),
                      child: Row(children: [
                        Text('Total ${snapshot.data!.length} items')
                      ]),
                    ),
                    Expanded(
                        child: snapshot.data!.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                        '${snapshot.data![index].id} : ${snapshot.data![index].todo}'),
                                    subtitle: Text(
                                        'By : ${snapshot.data![index].userId}'),
                                    trailing: (snapshot.data![index].completed)
                                        ? const Icon(
                                            FontAwesomeIcons.circleCheck)
                                        : const Icon(
                                            FontAwesomeIcons.circleXmark),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                                itemCount: snapshot.data!.length)
                            : const Center(child: Text('No item'))),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshData,
        child: const Icon(FontAwesomeIcons.rotate),
      ),
    );
  }
}
