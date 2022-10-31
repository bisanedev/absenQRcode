import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import './model_absensi.dart';
import '../../utils/app_exception.dart';
import '../../utils/globals.dart' as globals;

class RemoteApi {
  static Future<List<AbsenList>> getAbsenList(
    int page,
    int limit, 
    String userToken,
  ) async =>            
    http.get(
        ApiUrlBuilder.absensiList(page, limit),
        headers:{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
          'CRSF': globals.crsf,
        }
    ).mapFromResponse(      
      (jsonArray) => parseItemListFromJsonArray(
        jsonArray,
        (jsonObject) => AbsenList.fromJson(jsonObject),
      ),
    );  

  static List<T> parseItemListFromJsonArray<T>(
    List<dynamic> jsonArray,
    T Function(dynamic object) mapper,
  ) =>
      jsonArray.map(mapper).toList();

}

class NoConnectionException implements Exception {}

class ApiUrlBuilder {      

  static String absensiList(
    int page,
    int limit, {
    String searchTerm,
  }) =>
      'http://${globals.serverIP}/api/mobile/absensi?'
      'page=$page'
      '&limit=$limit';
}

extension on Future<http.Response> {
  Future<R> mapFromResponse<R, T>(R Function(T) jsonParser) async {
    try {
      final response = await this;      
      if (response.statusCode == 200) {        
        return jsonParser(jsonDecode(response.body)['records']);
      } else if (response.statusCode == 400){
        throw BadRequestException('bad request');
      } else if (response.statusCode == 401){
        throw BadRequestException('tidak di izinkan');      
      } else {        
        FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }
}