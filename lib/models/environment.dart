import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName {
    if (kReleaseMode) {
      return '.env.production';
    }

    return '.env.development';
  }

  static String get googleApiKey {
    return dotenv.env['GOOGLE_API_KEY'] ?? 'API_KEY not found';
  }

  static String get googleApiKey2 {
    return dotenv.env['GOOGLE_API_KEY2'] ?? 'API_KEY not found';
  }

  static String get appBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'API_BASE_URL not found';
  }

  static String get endpointRPCs {
    return dotenv.env['ENDPOINT_RPC'] ?? 'API_BASE_URL not found';
  }

  static String get endpointLogins {
    return dotenv.env['ENDPOINT_LOGIN'] ?? 'API_BASE_URL not found';
  }

  static String get urlSturn {
    return dotenv.env['URLS_STURN'] ?? 'API_BASE_URL not found';
  }

  static String get urlTurn {
    return dotenv.env['URLS_TURN'] ?? 'API_BASE_URL not found';
  }

  static String get usernameIce {
    return dotenv.env['USERNAME'] ?? 'API_BASE_URL not found';
  }

  static String get passwordIce {
    return dotenv.env['CREDENTIAL'] ?? 'API_BASE_URL not found';
  }

  static String get portDownload {
    return dotenv.env['PORT_DOWNLOAD'] ?? 'API_BASE_URL not found';
  }

  static String get paymentUrl {
    return dotenv.env['PAYMENT_URL'] ?? 'API_BASE_URL not found';
  }
}
