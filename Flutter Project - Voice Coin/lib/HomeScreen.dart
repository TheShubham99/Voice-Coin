// Created bt Prathamesh Sahasrabhojane.

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_upi/flutter_upi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:voicecoin/Bot.dart';
import 'package:voicecoin/main.dart';
import 'package:voicecoin/model/Upiuser.dart';

class Home_Screen extends StatefulWidget {
  String dropdownstring;
  Home_Screen({Key key, this.title}) : super(key: key);
  @override
  _VoiceHomeState createState() {
     getdefaultapp();   
    
    return _VoiceHomeState(dropdownstring);
  }
  
  void getdefaultapp()
  async {
     SharedPreferences prefs= await SharedPreferences.getInstance();
     String temp = prefs.getString("upiapp");
     if (temp==FlutterUpiApps.GooglePay) {
                        dropdownstring = "Google Pay";                     
                      } else if (temp == FlutterUpiApps.PayTM) {
                        dropdownstring="Paytm";
                      } else if (temp==FlutterUpiApps.PhonePe) {
                        dropdownstring = "PhonePe";
                      } else if (temp == FlutterUpiApps.BHIMUPI) {
                        dropdownstring="BHIM UPI";
                      }
     print(dropdownstring);
  }
  final String title;
}

class _VoiceHomeState extends State<Home_Screen> {
  
  String resultText = "";
  String dropdownValue="Google Pay";
  String defaultapp = "";
  Upiuser upiuser;
  FlutterTts flutterTts = FlutterTts();
  
  bool notfirst;

  _VoiceHomeState(String dropdownstring)
  {
    dropdownValue=dropdownstring;    
  }
  
  void systemspeak() async {
    await flutterTts.setLanguage("en-IN");

    await flutterTts.setVoice("en-in-x-cxx-local");

    await flutterTts
        .speak("Hey there, Welcome to VoiceCoin. How may i help you?");

    flutterTts.setCompletionHandler(gotobot);
    MyApp.help=true;
    
  }



  @override
  void initState() {
    
    super.initState();
    PermissionsService ps = new PermissionsService();
    Future<bool> permission = ps.requestMicPermission();
   createDatabase();

    if(MyApp.help==false)
    {
        systemspeak();}
  }

  
  createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = databasesPath + '/upistore.db';

    var database =
        await openDatabase(dbPath, version: 1, onCreate: createtables);
    return database;
  }

  void createtables(Database database, int version) async {
    
    try{
    var temp = (await database.rawQuery('Select * from Upiuser')).toList().toString();
    print("Data in Database \n "+temp);
    }
    catch(Exception)
    {
      print("Created Database: \n");
         await database.execute("CREATE TABLE Upiuser ("
        "id INTEGER PRIMARY KEY,"
        "first_name TEXT UNIQUE,"
        "upiid TEXT"
        ")");
  
    }
  }
  void gotobot() async{
  
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePageDialogflow()));
  }

  @override
  Widget build(BuildContext context) {
    dropdownValue=dropdownValue;
    return Scaffold(
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                  Text("Try Saying Pay to \ndo the payment",style: TextStyle(color: Colors.redAccent,fontSize: 24))
                ,
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                      ),


                Text("Select a UPI Application:",style: TextStyle(color: Colors.black,fontSize: 22))
                ,
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                      ),

                DropdownButton<String>(
                  hint: Text("Click to choose a UPI app"),
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 34,
                  elevation: 100,
                  style: TextStyle(
                      color: Colors.deepPurple, fontSize: 18, wordSpacing: 2),
                  underline: Container(
                    height: 3,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                        
                      dropdownValue = newValue;
                      if (dropdownValue == "Google Pay") {
                        defaultapp=FlutterUpiApps.GooglePay;
                      } else if (dropdownValue == "Paytm") {
                        defaultapp=FlutterUpiApps.PayTM;
                      } else if (dropdownValue == "PhonePe") {
                        defaultapp=FlutterUpiApps.PhonePe;
                      } else if (dropdownValue == "BHIM UPI") {
                        defaultapp=FlutterUpiApps.BHIMUPI;
                      }
                        setdefaultapp();
                      
                       });
                           },
                                        items: <String>["Google Pay", "Paytm", "PhonePe", "BHIM UPI"]
                                            .map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(80.0),
                                      ),
                                      FloatingActionButton(
                                        heroTag: "fbot",
                                        child: Icon(Icons.save),
                                        onPressed: () {
                                          gotobot();
                                        },
                                        backgroundColor: Colors.pink,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      
                        void setdefaultapp() async {
                          SharedPreferences prefs= await SharedPreferences.getInstance();
                          await prefs.setString("upiapp", defaultapp);
                          prefs.setBool("notfirst", true);
                        }
}


class PermissionsService {
  final PermissionHandler _permissionHandler = PermissionHandler();

  /// Requests the users permission to read their contacts.
  Future<bool> requestMicPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await _permissionHandler
            .requestPermissions([PermissionGroup.microphone]);
    /*  if (permissions.s) {
      onPermissionDenied();
    }*/
  //  print(permissions);
    return true;
  }
}
