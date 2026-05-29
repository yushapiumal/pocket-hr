import 'package:cn_pocket_hr/config/flavor_config.dart';

class AppConfig {
  static String get baseUrl => FlavorConfig.instance.apiBaseUrl;
}
