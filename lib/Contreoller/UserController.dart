
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:provider/provider.dart';
import 'package:userapp/Utils/PasswordDialog.dart';
import 'package:userapp/Utils/screenUtils.dart';
import 'package:userapp/View/AdminPage.dart';
import '../Model/User.dart';
import '../Utils/CustomDialog.dart';

class UserController with ChangeNotifier {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<User> _users = [];

  List<User> get users => _users;

  void loadUsers() async {
    _users = await dbHelper.getUsers();
    notifyListeners();
  }

  void addUser(User user,BuildContext context) async {
    await dbHelper.addUser(user);
    _users.remove(user);
    notifyListeners();
    if(await CustomDialog().showCustomDialog(context, "Success", "data has been saved.",true)){
      addRow();
    }
  }

  void updateUser(User user) async {
    await dbHelper.updateUser(user);
  }

  void deleteUser(int id) async {
    await dbHelper.deleteUser(id);
  }

  Future<void> showDialog(BuildContext context) async {
    if(await PasswordDialog().showCustomDialog(context)){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Adminpage()),
      );
    }
  }
  void downloadExcel(BuildContext context) async {
    // 엑셀 다운로드 로직 구현
  }

  void addRow() {
    _users.insert(0, User(country: 'US', username: '', email: '', emailUsed: true));
    notifyListeners();
  }

  void resetRow(){
    _users = [];
    notifyListeners();
  }
}

class UserDataTable extends StatelessWidget {
  var countryWidth;
  var nameWidth;
  var emailWidth;
  var emailAgreeWidth;
  var actionWidth;

  UserDataTable({this.countryWidth,this.nameWidth,this.emailWidth,this.emailAgreeWidth,this.actionWidth});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, controller, child) {
        return DataTable(
          checkboxHorizontalMargin: 0,
          horizontalMargin: 0,
          columnSpacing: 0,
          dataRowHeight: screenUtils().getHeight(11,context),
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
          rows: controller.users.map((user) {
            return DataRow(cells: [
              DataCell(
                Container(
                  width: countryWidth,
                  child: CountryCodePicker(
                    onChanged: (countryCode) {
                      user.country = countryCode.name!;
                    },
                    initialSelection:'US',
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

              DataCell(
                  Container(
                    padding: EdgeInsets.all(10),
                    width: nameWidth,
                    child: TextFormField(
                      maxLength: 100,
                      decoration: InputDecoration(
                        counterText: '',
                      ),
                      initialValue: user.username,
                      onFieldSubmitted: (_) {
                      },
                      onChanged: (newValue) {
                        user.username = newValue;
                      },
                    ),
                  )
              ),
              DataCell(
                  Container(
                    padding: EdgeInsets.all(10),
                    width: emailWidth,
                    child: TextFormField(
                      initialValue: user.email,
                      onFieldSubmitted: (_) {
                      },
                      onChanged: (newValue) {
                        user.email = newValue;
                      },
                    ),
                  )
              ),
              DataCell(
                  Container(
                width: emailAgreeWidth,
                alignment: Alignment.center,
                child: Checkbox(
                  value: user.emailUsed,
                  onChanged: (newValue) {
                    user.emailUsed = newValue!;
                  },
                ),
              )),
              DataCell(
                  Container(
                    width: actionWidth,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              size: MediaQuery.of(context).size.width * (2.5/100) ,
                              Icons.save,
                            ),
                            onPressed: () =>
                                controller.addUser(user,context),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                                size:  MediaQuery.of(context).size.width * (2.5/100) ,
                                Icons.delete),
                            onPressed:() async {
                                controller.resetRow();
                                if(await CustomDialog().showCustomDialog(context, "Delete", "Data has been deleted.", true)){
                                  controller.addRow();
                                }
                            }
                          ),
                        ),
                      ],
                    ),
                  )
              ),

            ]);
          }).toList(),
        );
      },
    );
  }
}