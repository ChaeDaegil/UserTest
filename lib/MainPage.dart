import 'dart:core';
import 'dart:core';
import 'dart:core';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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

  List<FocusNode> _focusNodes = [];


  final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  // 높이
  late double columnsHeight = 0;

  //넓이
  late double countryWidth;
  late double nameWidth;
  late double emailWidth;
  late double emailAgreeWidth;
  late double actionWidth;

  @override
  void initState() {
    super.initState();

    requestStoragePermission();
    initDatabase();
  }

  double getWidth(double persent) {
    Size size = MediaQuery.of(context).size;
    return size.width * (persent / 100);
  }

  double getHeight(double persent) {
    Size size = MediaQuery.of(context).size;
    return size.height * (persent / 100);
  }


  Future<void> requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
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
    addRow();
  }

  Future<void> loadRowsFromDatabase() async {
    if (database == null) return;
    List<Map<String, dynamic>> queryRows = await database!.query(
      'users',
      orderBy: "id DESC",
    );
    setState(() {
      rows = queryRows.map((row) {
        return {
          "id": row["id"],
          "country": row["country"],
          "username": row["username"],
          "email": row["email"],
          "email_used": row["email_used"] == 1,
          "saveMode": false
        };
      }).toList();
      _focusNodes = List.generate(rows.length * 3, (index) => FocusNode());
    });
  }

  void addRow() {
    setState(() {
      rows.insert(0,{
        "country": country,
        "username": "",
        "email": "",
        "email_used": true,
        "saveMode": true,
      });
      _focusNodes.add(FocusNode());
      _focusNodes.add(FocusNode());
      _focusNodes.add(FocusNode());
    });
  }

  Future<void> saveRowToDatabase(int index) async {
    if (database == null) return;

    Map<String, dynamic> row = Map.from(rows[index]);
    row["email_used"] = row["email_used"] ? 1 : 0;

    row.remove("saveMode");
    if (!emailRegExp.hasMatch(row["email"])) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('이메일 형식을 확인 부탁 드립니다.')));
      return;
    }

    if (row["id"] == null) {
      int id = await database!.insert('users', row);
      setState(() {
        rows[index]["id"] = id;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('추가 되었습니다.')));
    } else {
      await database!.update(
        'users',
        row,
        where: 'id = ?',
        whereArgs: [row["id"]],
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('수정되었습니다.')));
    }
    addRow();
    // loadRowsFromDatabase();
  }

  void deleteRow(int index) {
    Map<String, dynamic> row = Map.from(rows[index]);
    setState(() {
      if (row["id"] != null) {
        database?.delete("users", where: "id = ?", whereArgs: [row["id"]]);
      }
      rows.removeAt(index);
    });
    // loadRowsFromDatabase();
  }

  void downloadExcel() async {
    List<Map<String, dynamic>> data = await database!.query(
      'users',
      orderBy: "id ASC",
    );

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // 헤더 추가

    // 헤더 추가
    List<String> headers = ['나라', '이름', '이메일', '이메일 동의'];

    for (int i = 0; i < headers.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
      sheetObject.setColumnWidth(i, 20.0);
    }
    // 데이터 추가
    for (var row in data) {
      sheetObject.appendRow([
        TextCellValue(row['country']),
        TextCellValue(row['username']),
        TextCellValue(row['email']),
        TextCellValue(row['email_used'] == 1 ? "yes" : "no")
      ]);
    }
    final Directory tempDir = await getTemporaryDirectory();
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final Directory? downloadsDir = await getDownloadsDirectory();
    String filePath = await getExternalDocumentPath() + '/example.xlsx';

    File file = File(filePath);

    if (await file.exists()) {
      // 파일이 이미 존재하면 기존 파일을 삭제하거나 덮어씁니다.
      await file.delete();
      print("Existing file deleted.");
    }

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.save()!);

    // 사용자에게 파일이 저장되었음을 알리는 알림
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('엑셀 파일이 $filePath에 저장되었습니다.')),
    );
  }

  changeSaveMode(int index) {
    Map<String, dynamic> row = Map.from(rows[index]);
    setState(() {
      rows[index]["saveMode"] = !rows[index]["saveMode"];
    });
  }

  static Future<String> getExternalDocumentPath() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory _directory = Directory("dir");
    if (Platform.isAndroid) {
      _directory = Directory("/storage/emulated/0/Download/");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  @override
  Widget build(BuildContext context) {

    countryWidth = getWidth(15);
    nameWidth = getWidth(23);
    emailWidth = getWidth(35);
    emailAgreeWidth = getWidth(13);
    actionWidth = getWidth(12);


    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: [
        Container(
          height: 40,
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            "Letter of Intent for Participation",
            style: TextStyle(fontSize: getWidth(4), fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: getWidth(1)),
          child: Text(
            "[2026 Daegu World Maters Athletics Championships]",
            style: TextStyle(fontSize: getWidth(3.0)),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: getWidth(1),
            right: getWidth(1.5)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: (){

                  },
                  child: Text("admin"),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          child: DataTable(
              checkboxHorizontalMargin: 0,
              horizontalMargin: 0,
              columnSpacing: 0,
              dataRowHeight: getHeight(11),
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Color.fromRGBO(252, 245, 201, 1)),
              border: TableBorder.all(
                width: 1.0,
                color: Colors.black,
              ),
              columns: [
                DataColumn(
                  label: Container(
                    width: countryWidth,
                    margin: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: nameWidth,
                    alignment: Alignment.center,
                    child: const Text(
                      'Name',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                      width: emailWidth,
                      alignment: Alignment.center,
                      child: const Text(
                        'E-mail Address',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                ),
                DataColumn(
                  label: Container(
                    width: emailAgreeWidth,
                    alignment: Alignment.center,
                    child: const Text(
                      'Consent to Email \n newsletter Service',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: actionWidth,
                    alignment: Alignment.center,
                    child: const Text(
                      'actions',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                  rows.length,
                  (index) => DataRow(cells: [
                        DataCell(
                          Container(
                            width: countryWidth,
                            child: CountryCodePicker(
                              enabled: rows[index]["saveMode"],
                              onChanged: (countryCode) {
                                setState(() {
                                  rows[index]["country"] = countryCode.name;
                                  FocusScope.of(context)
                                      .requestFocus(_focusNodes[index * 3]);
                                });
                              },
                              initialSelection: rows[index]["country"] ?? "US",
                              favorite: ['+1', 'US'],
                              showFlag: true,
                              alignLeft: false,
                              showOnlyCountryWhenClosed: true,
                              textStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(rows[index]["saveMode"]
                            ? Container(
                          padding: EdgeInsets.all(getWidth(0.5)),
                                width: nameWidth,
                                child: TextFormField(
                                  maxLength: 100,
                                  decoration: InputDecoration(
                                    counterText: '',
                                  ),
                                  initialValue: rows[index]["username"],
                                  focusNode: _focusNodes[index * 3],
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(
                                        _focusNodes[index * 3 + 1]);
                                  },
                                  onChanged: (newValue) {
                                    setState(() {
                                      rows[index]["username"] = newValue;
                                    });
                                  },
                                ),
                              )
                            : Container(
                                width: nameWidth,
                                alignment: Alignment.center,
                                child: Text(
                                  rows[index]["username"],
                                  textAlign: TextAlign.center,
                                ),
                              )),
                        DataCell(rows[index]["saveMode"]
                            ? Container(
                          padding: EdgeInsets.all(getWidth(0.5)),
                                width: emailWidth,
                                child: TextFormField(
                                  initialValue: rows[index]["email"],
                                  focusNode: _focusNodes[index * 3 + 1],
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(
                                        _focusNodes[index * 3 + 2]);
                                  },
                                  onChanged: (newValue) {
                                    setState(() {
                                      rows[index]["email"] = newValue;
                                    });
                                  },
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: Text(
                                  rows[index]["email"],
                                  textAlign: TextAlign.center,
                                ),
                              )),
                        DataCell(Container(
                          width: emailAgreeWidth,
                          alignment: Alignment.center,
                          child: Checkbox(
                            value: rows[index]["email_used"],
                            onChanged: (newValue) {
                              setState(() {
                                if (rows[index]["saveMode"]) {
                                  rows[index]["email_used"] = newValue!;
                                }
                              });
                            },
                          ),
                        )),
                        DataCell(
                          rows[index]["saveMode"]
                              ? Container(
                                  width: actionWidth,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: Icon(
                                            size: getWidth(2.5),
                                            Icons.save,
                                          ),
                                          onPressed: () =>
                                              saveRowToDatabase(index),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: Icon(
                                              size: getWidth(2.5),
                                              Icons.delete),
                                          onPressed: () => deleteRow(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  width: actionWidth,
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    icon: Icon(
                                      size: getWidth(2.5),
                                      Icons.edit,
                                    ),
                                    onPressed: () => changeSaveMode(index),
                                  ),
                                ),
                        )
                      ]))),
        )
      ],
    )));
  }
}
