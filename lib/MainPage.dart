import 'package:country_code_picker/country_code_picker.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  List<Map<String, dynamic>> rows = [];
  String country = "US";
  Database? database;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/my_database.db';
    database = await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY,
          country TEXT,
          username TEXT,
          email TEXT,
          email_used INTEGER
        )
      ''');
    });
    loadRowsFromDatabase();
  }

  Future<void> loadRowsFromDatabase() async {
    if (database == null) return;

    List<Map<String, dynamic>> queryRows = await database!.query(
      'users',
      orderBy: " id ASC ",
    );
    setState(() {
      rows = queryRows.map((row) {
        print(row["country"]);
        return {
          "id": row["id"],
          "country": row["country"],
          "username": row["username"],
          "email": row["email"],
          "email_used": row["email_used"] == 1
        };
      }).toList();
    });
  }

  void addRow() {
    setState(() {
      rows.add({
        "country": country,
        "username": "",
        "email": "",
        "email_used": false,
      });
    });
  }

  Future<void> saveRowToDatabase(int index) async {
    if (database == null) return;

    Map<String, dynamic> row = Map.from(rows[index]);
    row["email_used"] = row["email_used"] ? 1 : 0;

    if (row["id"] == null) {
      int id = await database!.insert('users', row);
      setState(() {
        rows[index]["id"] = id;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar( const SnackBar(content: Text('추가 되었습니다.')));
    } else {
      await database!.update(
        'users',
        row,
        where: 'id = ?',
        whereArgs: [row["id"]],
      );
      ScaffoldMessenger.of(context)
          .showSnackBar( const SnackBar(content: Text('수정되었습니다.')));
    }
  }

  void deleteRow(int id, int index) {
    setState(() {
      database?.delete("users", where: " id = ? ", whereArgs: [id]);
      rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(top: 30, right: 0, left: 0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "사용자 정보 관리 앱",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: addRow,
                    child: Text("추가"),
                  ),
                ),
                Expanded(
                  child: DataTable2(
                      columnSpacing: 5,
                      horizontalMargin: 0,
                      minWidth: 200,
                      columns: [
                        DataColumn2(
                          label: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              '나라',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              '이름',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                '이메일',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              )),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              '이메일사용',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              '비고',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          size: ColumnSize.S,
                        ),
                      ],
                      rows: List<DataRow>.generate(
                          rows.length,
                          (index) => DataRow(cells: [
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    alignment: Alignment.center,
                                    child: CountryCodePicker(
                                      onChanged: (countryCode) {
                                        setState(() {
                                          rows[index]["country"] =
                                              countryCode.name;
                                        });
                                      },
                                      initialSelection:
                                          rows[index]["country"] ?? "US",
                                      favorite: ['+1', 'US'],
                                      showFlag: false,
                                      alignLeft: false,
                                      showOnlyCountryWhenClosed: true,
                                      textStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                DataCell(Container(
                                  alignment: Alignment.centerLeft,
                                  child: TextFormField(
                                    initialValue: rows[index]["username"],
                                    onChanged: (newValue) {
                                      setState(() {
                                        rows[index]["username"] = newValue;
                                      });
                                    },
                                  ),
                                )),
                                DataCell(TextFormField(
                                  initialValue: rows[index]["email"],
                                  onChanged: (newValue) {
                                    setState(() {
                                      rows[index]["email"] = newValue;
                                    });
                                  },
                                )),
                                DataCell(Container(
                                  alignment: Alignment.center,
                                  child: Checkbox(
                                    value: rows[index]["email_used"],
                                    onChanged: (newValue) {
                                      setState(() {
                                        rows[index]["email_used"] = newValue!;
                                      });
                                    },
                                  ),
                                )),
                                DataCell(Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: const Icon(
                                            size: 15,
                                            Icons.save,
                                          ),
                                          onPressed: () =>
                                              saveRowToDatabase(index),
                                        ),
                                      ),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: Icon(size: 15, Icons.delete),
                                          onPressed: () => deleteRow(
                                              rows[index]["id"], index),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                              ]
                          )
                      )
                  ),
                )
              ],
            )
        )
    );
  }
}
