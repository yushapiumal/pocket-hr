import 'package:localstorage/localstorage.dart';

class APIConfig {
  final LocalStorage storage = LocalStorage('pocketHR');

  api() {
    // http: //mahajana.rype3.loc/human/account
    // return "http://" +
    //     storage.getItem('company').toLowerCase().trim() +
    //     ".rype3.loc/human/api/v1/";
    //-------- LIVE----------
    return "https://mahajana.rype3.com/human/api/v1/";
  }
}



//mahajana@digitable.io
// sWax5ra$Ha&2