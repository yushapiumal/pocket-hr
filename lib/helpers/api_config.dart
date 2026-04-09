import 'package:localstorage/localstorage.dart';

class APIConfig {
  final LocalStorage storage = LocalStorage('pocketHR');

  api() {
    // http: //mahajana.rype3.loc/human/account
    // return "http://" +
    //     storage.getItem('company').toLowerCase().trim() +
    //     ".rype3.loc/human/api/v1/";
    //-------- LIVE----------
    return "https://api.human.go.digitable.io/human/v2/api/";
  }
}



//mahajana@digitable.io
// sWax5ra$Ha&2