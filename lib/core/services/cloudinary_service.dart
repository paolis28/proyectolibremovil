import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servicio para subir imágenes a Cloudinary
class CloudinaryService {
  //CREDENCIALES DE CLOUDINARY
  static const String cloudName = 'dfuajei2k'; // Key: 'dxxxxx'
  static const String uploadPreset = 'gym_areas'; // Carpeta de destino 'gym_areas'

  static const String baseUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Subir imagen a Cloudinary
  /// Retorna la URL de la imagen subida o null si falla
  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Crear FormData para enviar la imagen
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'upload_preset': uploadPreset,
        'folder': 'gym_areas', // Carpeta en Cloudinary
      });

      // Usar Dio para subir
      final dio = Dio();
      final response = await dio.post(
        baseUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final secureUrl = data['secure_url'] as String;
        return secureUrl;
      }

      return null;
    } catch (e) {
      print('Error al subir imagen a Cloudinary: $e');
      return null;
    }
  }

  /// Subir imagen usando http (alternativa sin Dio)
  static Future<String?> uploadImageWithHttp(File imageFile) async {
    try {
      final uri = Uri.parse(baseUrl);
      final request = http.MultipartRequest('POST', uri);

      // Agregar preset y carpeta
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'gym_areas';

      // Agregar archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Enviar request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final secureUrl = data['secure_url'] as String;
        return secureUrl;
      }

      return null;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  /// Eliminar imagen de Cloudinary (opcional)
  static Future<bool> deleteImage(String publicId) async {
    // Requiere configuración adicional con API Key y Secret
    // Por ahora, las imágenes se mantienen en Cloudinary
    return true;
  }
}