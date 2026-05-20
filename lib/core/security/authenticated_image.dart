import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';

class AuthenticatedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getIt<SecureStorageService>().getUserToken(),
      builder: (context, snapshot) {
        // Show a brief spinner or placeholder while retrieving the token
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ??
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
        }

        final token = snapshot.data;
        final headers = <String, String>{};
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }

        return CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: headers,
          // On web, HtmlImage loads via <img> URL only — custom headers are ignored.
          // HttpGet uses the cache manager fetch path so Authorization is sent.
          imageRenderMethodForWeb: kIsWeb && headers.isNotEmpty
              ? ImageRenderMethodForWeb.HttpGet
              : ImageRenderMethodForWeb.HtmlImage,
          fit: fit,
          width: width,
          height: height,
          placeholder: (context, url) =>
              placeholder ??
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          errorWidget: (context, url, error) =>
              errorWidget ??
              const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 32),
              ),
        );
      },
    );
  }
}
