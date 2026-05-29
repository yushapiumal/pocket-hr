import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:localstorage/localstorage.dart';

class APIConfig {
  final LocalStorage storage = LocalStorage('pocketHR');

  api() {
    return '${FlavorConfig.instance.apiBaseUrl}/';
  }
}



//mahajana@digitable.io
// sWax5ra$Ha&2