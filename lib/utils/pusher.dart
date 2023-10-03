import 'package:foreground_service_poc/config.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

Digest getSignature(String value) {
  var key = utf8.encode(PUSHER_APP_SECRET);
  var bytes = utf8.encode(value);

  var hmacSha256 = Hmac(sha256, key);
  Digest digest = hmacSha256.convert(bytes);
  return digest;
}

// TODO: Get the auth details from the backend server
// This implementation only for POC app
dynamic onAuthorizer(String channelName, String socketId, dynamic options) async {
  return {"auth": "$PUSHER_APP_KEY:${getSignature("$socketId:$channelName")}"};
}
