import 'dart:async';
import 'dart:io';
import 'package:flutter_upi/flutter_upi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/flutter_dialogflow.dart';
import 'package:flutter_dialogflow/v2/auth_google.dart';
import 'package:flutter_dialogflow/v2/message.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:sqflite/sqflite.dart';
import 'HomeScreen.dart';
import 'Pay.dart';


//Created by Prathamesh Sahasrabhojane.

class HomePageDialogflow extends StatefulWidget {
  HomePageDialogflow({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageDialogflow createState() => new _HomePageDialogflow();
}

class _HomePageDialogflow extends State<HomePageDialogflow> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  SpeechRecognition _speechRecognition;
  Pay pay=new Pay();
  bool _isAvailable = false;
  bool _isListening = false;
  String resultText = "";
  String oldmessage="";
  bool errorgiven=false;
  FlutterTts flutterTts =  FlutterTts();
  String newupi="";
  String databasesPath;
  String dbPath;
  String upiPlatform=FlutterUpiApps.GooglePay.toString();
  var database;

  void speakmessage(String speakstring)
    async {
      await flutterTts.setLanguage("en-IN");
  
        await flutterTts.setVoice("en-in-x-cxx-local");
        await flutterTts.speak(speakstring);

        flutterTts.setCompletionHandler(userspeak);

    }

      void userspeak()
      {
        
        //                print("here-------------------------------------");
                          _speechRecognition
                              .listen(locale: "en_US")
                              .then((result) => print('$result'));
                           _isAvailable=true;
                           _isListening=false;

                            
                          _speechRecognition.setRecognitionErrorHandler(speecherror);  
                           _speechRecognition.setRecognitionCompleteHandler(sendUserResponse);
                           
      }

      void speecherror()
      {
        if(errorgiven==false){
           ChatMessage message = new ChatMessage(
              text: "I didn't got that. Please Try Saying 'Pay'. OR Try saying 'Help' to get tutorial.",
              name: "Voice Coin",
              type: false,
            );


            setState(() {
              _messages.insert(0, message);
            });
               speakmessage("I didn't got that. Please Try Saying 'Pay'. or Try saying 'Help' to get tutorial.");

        errorgiven=true;
      }
      }

      @override
      void initState() {
        getdefaultapp();
        errorgiven=false;
        super.initState();
        
        initSpeechRecognizer();        
        userspeak();
      }

      Future getdefaultapp()
      async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if(prefs.containsKey("upiapp"))
        {
          upiPlatform=prefs.getString("upiapp").toString();
        }
      }
    
      void initSpeechRecognizer() {
        _speechRecognition = SpeechRecognition();
    
        _speechRecognition.setAvailabilityHandler(
          (bool result) => setState(() => _isAvailable = result),
        );
    
        _speechRecognition.setRecognitionStartedHandler(
          () => setState(() => _isListening = true),
        );
    
        _speechRecognition.setRecognitionResultHandler(
          (String speech) => setState(() => resultText = speech),
        );
    
        _speechRecognition.setRecognitionCompleteHandler(
          () => setState(() => _isListening = false),
        );
    
        _speechRecognition.activate().then(
              (result) => setState(() => _isAvailable = result),
            );
      }


  void sendUserResponse()
  {
    
    if(resultText.isNotEmpty){

       if(resultText.toLowerCase()=="exit")
       {
          exit(0);
       }
       else if(resultText.toLowerCase().contains("help"))
       {
         Navigator.push(context, MaterialPageRoute(builder: (context) => Home_Screen()));
         _speechRecognition.stop();
       }
       else{ 
      _handleSubmitted(resultText);
       }
    }
  }


  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              
               child : new Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent[100],
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  child: Text(
                    resultText,
                  ),
                ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.bubble_chart),
                  onPressed: () { 
                    errorgiven=false;
                    userspeak();
                    }
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void Response(query) async {
    try{
    resultText="";
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/credentials.json")
            .build();

//  print("Query issssssssssssssss ="+query);
    query = query.toString().replaceAll(" ", "_");
    query = query.toString().replaceAll("*", "_");
    query = query.toString().replaceAll("'", "");
    Dialogflow dialogflow = Dialogflow(token: "4227dcdaaea44e15acfa93ceb8187657");
    AIResponse response = await dialogflow.sendQuery(query);
    print(response.getMessageResponse()+"status :");
    
    if(response.getMessageResponse().toString().contains("Processing Payment of")){

          String paymentResponse=response.getMessageResponse().toString().replaceAll("Processing Payment of", "");
          paymentResponse=paymentResponse.replaceAll(" to", "");
          paymentResponse=paymentResponse.trim();
          List<String> data=paymentResponse.split(" ");
          String username=data[1].toLowerCase();
          String amount=data[0];

          databasesPath = await getDatabasesPath();
          dbPath = databasesPath + '/upistore.db';
          
          database = await openDatabase(dbPath, version: 1);
        
          var tempupiid = (await database.rawQuery('Select upiid from Upiuser where first_name = "$username"')).toList().toString();

          
         if(tempupiid=="[]")
         {
            _addUserinDb(username);
         }
         else {

          tempupiid= tempupiid.toString().replaceAll("[{upiid: ", "");
          tempupiid=tempupiid.replaceAll("}]", "");
          print("upiif is :-------->"+tempupiid);
          pay.payment(tempupiid,amount,username,upiPlatform);
          speakmessage(response.getSpeechResponse().toString());


            ChatMessage message = new ChatMessage(
              text: response.getMessageResponse() ??
                  new CardDialogflow(response.getMessageResponse()[0]).title,
              name: "Voice Coin",
              type: false,
            );


            setState(() {
              _messages.insert(0, message);
            });

         }

    }
    else{
    
            speakmessage(response.getSpeechResponse().toString());
            

            ChatMessage message = new ChatMessage(
              text: response.getMessageResponse() ??
                  new CardDialogflow(response.getMessageResponse()[0]).title,
              name: "Voice Coin",
              type: false,
            );


            setState(() {
              _messages.insert(0, message);
            });
        }
    }
    catch(Exception){

    }
  }
  
  void _handleSubmitted(String text) {
   // resultText="";
    ChatMessage message = new ChatMessage(
      text: text,
      name: "You",
      type: true,
    );
    setState(() {

      if(oldmessage.isEmpty || oldmessage!=text)
      {
      _messages.insert(0, message);
    
      }
    });
    if(text.isNotEmpty || oldmessage.isEmpty || oldmessage!=text){
     Response(text);
     oldmessage=text;
     
    }
//    print("texttttt:"+text);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Voice Coin Assistant"),
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
          padding: new EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
        )),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(),
        ),
      ]),
    );
  }

  Future<void> _addUserinDb(String username) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add upi Id "),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text("Name : "+username)
              ,TextField(
            onChanged: (text){
                newupi=text;
            }
          ),
        
            ]
          )
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            onPressed: () {
              addnewupicontact(username);  
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
              
    Future addnewupicontact(String username) async {

        var result = await database.rawInsert(
      "INSERT INTO Upiuser (first_name,upiid) VALUES ('$username','$newupi')");

    }

}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.type});

  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: new CircleAvatar(child: new Text('V')),
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(this.name,
                style: new TextStyle(fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(this.name, style: Theme.of(context).textTheme.subhead),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
      new Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: new CircleAvatar(
            child: new Text(
          this.name[0],
          style: new TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}

