import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xraychatboat/models/hospital_response.dart';
import 'package:xraychatboat/models/login_response.dart';
import 'package:xraychatboat/models/signup_response.dart';
import 'package:xraychatboat/models/xray_response.dart';
import 'package:xraychatboat/services/constants.dart';

class ApiService {
  static const String baseUrl = Constants.baseUrl;
  Future<Loginresponse> login(String username, String password) async {
    try{
      final url = Uri.parse('$baseUrl/success');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      var data = jsonDecode(response.body);
      if(response.statusCode == 200){
        return Loginresponse(hospitalName: data['hospitalname'], role :data['role'], userName: data['username'],status: data['status'],statusCode: response.statusCode);
      }else{
        return Loginresponse(status: data['status'], message: data['message'], statusCode: response.statusCode);    
      }
    }catch(e){
      return Loginresponse(statusCode: 800, status: 'error', message: 'Error: $e');
    }
  }


  Future<XrayResponse> sendRequest(String username, String imagePath) async {
    File file = File(imagePath);
    String filename = file.path.split('/').last;

    try {
      final url = Uri.parse('$baseUrl/multFiles_upload');
      final request = http.MultipartRequest('POST', url);

      request.files.add(await http.MultipartFile.fromPath(
        'xrayfile',
        file.path,
        filename: filename,
      ));
      request.fields['username'] = username;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return XrayResponse.fromJson(data);
      } else {
        var data = jsonDecode(response.body);
        return XrayResponse.fromJson(data);
      }
    } catch (e) {
      return XrayResponse(
        status: 'error',
        message: e.toString(),
        countFindings: 0,
        totalFiles: 0,
        files: [],
      );
    }
  }


  // Future<XrayResponse> sendRequest(String username, String imagePath) async {
  //   File file = File(imagePath);
  //   String filename = file.path.split('/').last;
  //   try{
  //     final url = Uri.parse('$baseUrl/multFiles_upload');
  //     final request = http.MultipartRequest(
  //       'POST',
  //       url
  //     );
  //     request.files.add(await http.MultipartFile.fromPath(
  //       'xrayfile',
  //       file.path,
  //       filename: filename,
  //     ));
  //     request.fields['username'] = username;
  //     print('Request1122122: ${request.files} ');
  //     var streamedResponse = await request.send();
  //     var response = await http.Response.fromStream(streamedResponse);
  //     print('Statuscode: ${response.statusCode}');
  //     var data = jsonDecode(response.body);
  //     if (response.statusCode == 200) {
  //       List<Map<String, dynamic>> findings = [];
  //       var camFiles = data['findings'][0]['cam_files'];
  //       var probList = data['findings'][0]['pred_probs'];

  //       int i = 0;
  //       for (var entry in camFiles.entries) {
  //         if (i < probList.length) {
  //           findings.add({
  //             'disease': entry.key,
  //             'path': entry.value.toString(),
  //             'probability': '${probList[i].toStringAsFixed(2)}%',
  //           });
  //           i++;
  //         }
  //       }

  //       return XrayResponse(
  //         message: data['message'],
  //         status: data['status'],
  //         uploadedFile: data['uploaded_files'][0],
  //         findings: findings,
  //       );
  //     } else {
  //       return XrayResponse(message: data['message'],status: data['status']);
  //     }
  //   }catch(e){
  //     print('Error: ${e.toString()}');
  //     return XrayResponse(status: 'error', message: '$e');
  //   }
  // }

  Future<SignupResponse> signup({
    required String fullname,
    required String email,
    required String username,
    required String mobile,
    required String specialization,
    required String hospitalname,
    required String password,
  }) async {
    try{
      final url = Uri.parse('$baseUrl/signup');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'username': username,
          'mobile': mobile,
          'specialization': specialization,
          'hospitalname': hospitalname,
          'password': password,
        }),
      );
      var data = jsonDecode(response.body);
      if(response.statusCode == 200){
        return SignupResponse(
          status: data['status'],
          statusCode: response.statusCode,
          message: data['message'] 
        );
      }else{
        return SignupResponse(status: data['status'], message: data['message'], statusCode: response.statusCode);    
      }
    }catch(e){
      return SignupResponse(statusCode: 800, status: 'error', message: 'Error: $e');
    }
  }

  Future<HospitalResponse> fetchHospitals() async {
    try{
      final url = Uri.parse('$baseUrl/hospitals');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        List<String> hospitals = List<String>.from(data['hospitals']);
        return HospitalResponse(statusCode: response.statusCode, message: data['message'], status: data['status'], hospitalList: hospitals);
      } else {
        return HospitalResponse(statusCode: response.statusCode, status: data['status'], message: data['message']);
      }
    }catch (e) {
      return HospitalResponse(statusCode: 800, status: 'error. $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchChats(String userId) async {
    final url = Uri.parse('$baseUrl/chats/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        List<Map<String, dynamic>> chats =
            List<Map<String, dynamic>>.from(data['chats']);
        return chats;
      } else {
        throw Exception('Failed to fetch chats: ${data['message']}');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }
}
