import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
