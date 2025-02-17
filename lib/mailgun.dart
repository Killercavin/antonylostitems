import 'dart:convert';
import 'package:http/http.dart' as http;

class MailgunService {
  final String apiKey = "9c3f0c68-1030f4a5"; // Replace with your actual API key
  final String domain = "sandbox0712313d7a5b4f7eb176921a1206c949.mailgun.org"; // Replace with your actual Mailgun domain
  final String mailgunBaseUrl = "https://api.mailgun.net/v3";

  Future<void> sendEmail({
    required String fromEmail,
    required String toEmail,
    required String subject,
    required String message,
  }) async {
    final String url = "$mailgunBaseUrl/$domain/messages";
    final String credentials = "api:$apiKey";
    final String encodedCredentials = base64Encode(utf8.encode(credentials));

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Basic $encodedCredentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'from': fromEmail,
        'to': toEmail,
        'subject': subject,
        'text': message,
      },
    );

    if (response.statusCode == 200) {
      print('Email sent successfully.');
    } else {
      print('Failed to send email: ${response.statusCode}');
      print('Error: ${response.body}');
    }
  }
}
