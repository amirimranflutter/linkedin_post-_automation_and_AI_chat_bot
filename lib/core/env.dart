import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  static Future<void> init() async {
    await dotenv.load(fileName: "assets/.env");
  }
}
