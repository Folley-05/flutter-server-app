import 'dart:math';
import 'dart:convert';
import 'dart:io';

/// function to generate random string
String generateRandomString(int length) {
  /// list of characters allowed
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  //   Random random = Random();

  return List.generate(
    length,
    (index) => chars[Random().nextInt(chars.length)],
  ).join();
}
