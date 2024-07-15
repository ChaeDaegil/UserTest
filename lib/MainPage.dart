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
  String country = "";
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/my_database.db';
    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
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
    _loadRowsFromDatabase();
  }

  Future<void> _loadRowsFromDatabase() async {
    if (_database == null) return;

    List<Map<String, dynamic>> queryRows = await _database!.query('users',orderBy: " id ASC ",);
    setState(() {
      rows = queryRows.map((row) {
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

  void _addRow() {
    setState(() {
      rows.add({
        "country": country,
        "username": "",
        "email": "",
        "email_used": false,
      });
    });
  }

  Future<void> _saveRowToDatabase(int index) async {
    if (_database == null) return;

    Map<String, dynamic> row = Map.from(rows[index]);
    row["email_used"] = row["email_used"] ? 1 : 0;

    if (row["id"] == null) {
      int id = await _database!.insert('users', row);
      setState(() {
        rows[index]["id"] = id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Row ${index + 1} saved to database!')));
    } else {
      await _database!.update(
        'users',
        row,
        where: 'id = ?',
        whereArgs: [row["id"]],
      );
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Row ${index + 1} updated in database!')));
    }
  }
  Future<void> _saveAllToDatabase() async {
    if (_database == null) return;

    await _database!.transaction((txn) async {
      for (var row in rows) {
        Map<String, dynamic> newRow = Map.from(row);
        newRow["email_used"] = newRow["email_used"] ? 1 : 0;
        await txn.insert('users', newRow);
      }
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('All rows saved to database!')));
  }

  void _deleteRow(int id,int index) {
    setState(() {
      _database?.delete("users",where: " id = ? ",whereArgs: [id]);
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
                  child: Text(
                    "사용자 정보 관리 앱",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _addRow,
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
                            child: Text(
                              '나라',
                              style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                            ),
                          ),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '이름',
                              style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                            ),
                          ),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Container(
                              alignment: Alignment.center,
                              child: Text(
                                '이메일',
                                style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                              ))
                          ,
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '이메일사용',
                              style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                            ),
                          ),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '비고',
                              style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
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
                                      rows[index]["country"] = countryCode.name;
                                    });
                                  },
                                  initialSelection: rows[index]["country"] ?? "US",
                                  favorite:  ['+1', 'US'],
                                  showFlag: false,
                                  alignLeft: false,
                                  showOnlyCountryWhenClosed: true,
                                  textStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
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
                            DataCell(
                                Container(
                                  alignment: Alignment.center,
                                  child: Checkbox(
                                    value: rows[index]["email_used"],
                                    onChanged: (newValue) {
                                      setState(() {
                                        rows[index]["email_used"] = newValue!;
                                      });
                                    },
                                  ),
                                )
                            ),
                            DataCell(
                                Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: Icon(
                                            size: 15,
                                            Icons.save,
                                          ),
                                          onPressed: () => _saveRowToDatabase(index),
                                        ),
                                      ),
                                      Container(
                                        width:30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: Icon(
                                              size: 15,
                                              Icons.delete
                                          ),
                                          onPressed: () => _deleteRow( rows[index]["id"],index),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            )
                          ]))),
                )
              ],
            )));
  }
}
