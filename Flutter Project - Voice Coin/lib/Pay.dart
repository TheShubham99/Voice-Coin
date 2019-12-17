
import 'package:flutter_upi/flutter_upi.dart';

class Pay{
String response="";


 void payment(String upiid,String amount,String username,String upiPlatform) async{
    response = await FlutterUpi.initiateTransaction(
    app: upiPlatform,
    pa: upiid,
    pn: username,
    tr: "9e543J979m9",
    tn: "Paid with Voice Coin",
    cu: "INR",
    url: "https://www.google.com", am: amount,
); 

print("Response = "+response.toString());

}
}