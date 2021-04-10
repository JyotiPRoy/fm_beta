import 'package:flutter/services.dart';

enum IntentType {
  Open,
  Share
}

/// May convert this class to something where all communications to the android code occurs
/// and not just intents.
class IntentHandler {
  dynamic data;
  IntentType intentType;
  String mimeType;
  MethodChannel _methodChannel;

  IntentHandler({
    this.data,
    this.intentType,
    this.mimeType
  }){
    _methodChannel = MethodChannel('com.example.fm_beta'); /// TODO: Create a file with all global constants
  }

  void launch() async{
    switch(intentType){
      case IntentType.Open: {
        await _methodChannel.invokeMethod('openFile', {"data":data.toString(), "mimeType":mimeType});
        break;
      }
      case IntentType.Share: {
        if(data is String){
          await _methodChannel.invokeMethod('share', {"data":data, "dataList":null, "mimeType":mimeType});
        }else if(data is List<String>){
          await _methodChannel.invokeMethod('share', {"data":null, "dataList":data, "mimeType":mimeType});
        }
        break;
      }
    }
  }
}