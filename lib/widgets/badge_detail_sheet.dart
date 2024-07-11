import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BadgeDetailSheet extends StatelessWidget {
  final String imageUrl;
  final String badgeName;
  final String routeName;
  final String routeImageUrl;

  const BadgeDetailSheet({
    Key? key,
    required this.imageUrl,
    required this.badgeName,
    required this.routeName,
    required this.routeImageUrl,
  }) : super(key: key);

  Future<void> _shareBadge(BuildContext context) async {
    final text =
        'He conseguido la insignia "$badgeName" en la ruta "$routeName" gracias a Vive la UCA!';

    try {
      // Imprimir las URLs para verificar que sean correctas
      print('imageUrl: $imageUrl');
      print('routeImageUrl: $routeImageUrl');

      // Verificar si las URLs son válidas
      if (imageUrl.isEmpty || routeImageUrl.isEmpty) {
        throw Exception('Las URLs de las imágenes no pueden estar vacías');
      }

      // Descargar las imágenes
      final badgeResponse = await http.get(Uri.parse(imageUrl));
      final routeResponse = await http.get(Uri.parse(routeImageUrl));

      if (badgeResponse.statusCode == 200 && routeResponse.statusCode == 200) {
        final badgeBytes = badgeResponse.bodyBytes;
        final routeBytes = routeResponse.bodyBytes;

        // Cargar la imagen del logo desde los assets
        final ByteData logoData =
            await rootBundle.load('lib/assets/images/logo.png');
        final Uint8List logoBytes = logoData.buffer.asUint8List();

        // Combinar las imágenes usando un CustomPainter
        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);

        final badgeImage = await _loadImage(Uint8List.fromList(badgeBytes));
        final routeImage = await _loadImage(Uint8List.fromList(routeBytes));
        final logoImage = await _loadImage(Uint8List.fromList(logoBytes));

        // Dimensiones cuadradas
        final double squareSize =
            routeImage.width.toDouble() < routeImage.height.toDouble()
                ? routeImage.width.toDouble()
                : routeImage.height.toDouble();

        // Calcular el rectángulo de destino para centrar y ajustar la imagen de fondo
        final double scale = squareSize /
            (routeImage.width.toDouble() > routeImage.height.toDouble()
                ? routeImage.height.toDouble()
                : routeImage.width.toDouble());
        final double newWidth = routeImage.width.toDouble() * scale;
        final double newHeight = routeImage.height.toDouble() * scale;
        final routeRect = Rect.fromLTWH(
          (squareSize - newWidth) / 2,
          (squareSize - newHeight) / 2,
          newWidth,
          newHeight,
        );

        final badgeRect = Rect.fromLTWH(
          (squareSize - 200) / 2,
          (squareSize - 200) / 2,
          200,
          200,
        );
        final logoRect = Rect.fromLTWH(
          squareSize - 100,
          squareSize - 100,
          100,
          100,
        );

        // Dibujar imagen de fondo y aplicar filtro oscuro
        canvas.drawImageRect(
            routeImage,
            Rect.fromLTWH(0, 0, routeImage.width.toDouble(),
                routeImage.height.toDouble()),
            routeRect,
            Paint());
        canvas.drawRect(Rect.fromLTWH(0, 0, squareSize, squareSize),
            Paint()..color = Colors.black.withOpacity(0.5));

        // Fondo blanco y redondeado para la insignia con borde cuadrado
        final paint = Paint()..color = Colors.white;
        final borderRect = Rect.fromLTWH(
          (squareSize - 210) / 2,
          (squareSize - 210) / 2,
          210,
          210,
        );
        canvas.drawRect(borderRect, paint);

        // Dibujar imágenes y texto
        canvas.drawImageRect(
            badgeImage,
            Rect.fromLTWH(0, 0, badgeImage.width.toDouble(),
                badgeImage.height.toDouble()),
            badgeRect,
            Paint());
        canvas.drawImageRect(
            logoImage,
            Rect.fromLTWH(
                0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
            logoRect,
            Paint());

        // Añadir texto a la imagen
        final textPainter = TextPainter(
          text: TextSpan(
            text: routeName,
            style: TextStyle(
              color: Colors.orange,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: squareSize,
        );
        final offset = Offset(
          (squareSize - textPainter.width) / 2,
          (squareSize / 2) + 110,
        );
        textPainter.paint(canvas, offset);

        final combinedImage = await pictureRecorder
            .endRecording()
            .toImage(squareSize.toInt(), squareSize.toInt());
        final byteData =
            await combinedImage.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        // Guardar la imagen combinada en un archivo temporal
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/combined_image.png';
        final combinedImageFile = File(filePath);
        await combinedImageFile.writeAsBytes(pngBytes);

        // Compartir la imagen combinada junto con el texto
        await Share.shareXFiles([XFile(filePath)],
            text: text, subject: 'Mi insignia en Vive la UCA');
      } else {
        throw Exception('Error al descargar las imágenes: '
            'badgeResponse: ${badgeResponse.statusCode}, '
            'routeResponse: ${routeResponse.statusCode}');
      }
    } catch (e) {
      print('Error al compartir la insignia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir la insignia: $e')),
      );
    }
  }

  Future<ui.Image> _loadImage(Uint8List imgBytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imgBytes, (img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.network(import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BadgeDetailSheet extends StatelessWidget {
  final String imageUrl;
  final String badgeName;
  final String routeName;
  final String routeImageUrl;

  const BadgeDetailSheet({
    Key? key,
    required this.imageUrl,
    required this.badgeName,
    required this.routeName,
    required this.routeImageUrl,
  }) : super(key: key);

  Future<void> _shareBadge(BuildContext context) async {
    final text =
        'He conseguido la insignia "$badgeName" en la ruta "$routeName" gracias a Vive la UCA!';

    try {
      // Imprimir las URLs para verificar que sean correctas
      print('imageUrl: $imageUrl');
      print('routeImageUrl: $routeImageUrl');

      // Verificar si las URLs son válidas
      if (imageUrl.isEmpty || routeImageUrl.isEmpty) {
        throw Exception('Las URLs de las imágenes no pueden estar vacías');
      }

      // Descargar las imágenes
      final badgeResponse = await http.get(Uri.parse(imageUrl));
      final routeResponse = await http.get(Uri.parse(routeImageUrl));

      if (badgeResponse.statusCode == 200 && routeResponse.statusCode == 200) {
        final badgeBytes = badgeResponse.bodyBytes;
        final routeBytes = routeResponse.bodyBytes;

        // Cargar la imagen del logo desde los assets
        final ByteData logoData =
            await rootBundle.load('lib/assets/images/logo.png');
        final Uint8List logoBytes = logoData.buffer.asUint8List();

        // Combinar las imágenes usando un CustomPainter
        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);

        final badgeImage = await _loadImage(Uint8List.fromList(badgeBytes));
        final routeImage = await _loadImage(Uint8List.fromList(routeBytes));
        final logoImage = await _loadImage(Uint8List.fromList(logoBytes));

        // Dimensiones cuadradas
        final double squareSize =
            routeImage.width.toDouble() < routeImage.height.toDouble()
                ? routeImage.width.toDouble()
                : routeImage.height.toDouble();

        // Calcular el rectángulo de destino para centrar y ajustar la imagen de fondo
        final double scale = squareSize / (routeImage.width.toDouble() > routeImage.height.toDouble() ? routeImage.height.toDouble() : routeImage.width.toDouble());
        final double newWidth = routeImage.width.toDouble() * scale;
        final double newHeight = routeImage.height.toDouble() * scale;
        final routeRect = Rect.fromLTWH(
          (squareSize - newWidth) / 2,
          (squareSize - newHeight) / 2,
          newWidth,
          newHeight,
        );

        final badgeRect = Rect.fromLTWH(
          (squareSize - 200) / 2,
          (squareSize - 200) / 2,
          200,
          200,
        );
        final logoRect = Rect.fromLTWH(
          squareSize - 100,
          squareSize - 100,
          100,
          100,
        );

        // Dibujar imagen de fondo y aplicar filtro oscuro
        canvas.drawImageRect(routeImage, Rect.fromLTWH(0, 0, routeImage.width.toDouble(), routeImage.height.toDouble()), routeRect, Paint());
        canvas.drawRect(
            Rect.fromLTWH(0, 0, squareSize, squareSize), Paint()..color = Colors.black.withOpacity(0.5));

        // Fondo blanco y redondeado para la insignia con borde cuadrado
        final paint = Paint()..color = Colors.white;
        final borderRect = Rect.fromLTWH(
          (squareSize - 210) / 2,
          (squareSize - 210) / 2,
          210,
          210,
        );
        canvas.drawRect(borderRect, paint);

        // Dibujar imágenes y texto
        canvas.drawImageRect(
            badgeImage,
            Rect.fromLTWH(0, 0, badgeImage.width.toDouble(),
                badgeImage.height.toDouble()),
            badgeRect,
            Paint());
        canvas.drawImageRect(
            logoImage,
            Rect.fromLTWH(
                0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
            logoRect,
            Paint());

        // Añadir texto a la imagen
        final textPainter = TextPainter(
          text: TextSpan(
            text: routeName,
            style: TextStyle(
              color: Colors.orange,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: squareSize,
        );
        final offset = Offset(
          (squareSize - textPainter.width) / 2,
          (squareSize / 2) + 110,
        );
        textPainter.paint(canvas, offset);

        final combinedImage = await pictureRecorder
            .endRecording()
            .toImage(squareSize.toInt(), squareSize.toInt());
        final byteData =
            await combinedImage.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        // Guardar la imagen combinada en un archivo temporal
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/combined_image.png';
        final combinedImageFile = File(filePath);
        await combinedImageFile.writeAsBytes(pngBytes);

        // Compartir la imagen combinada junto con el texto
        await Share.shareXFiles([XFile(filePath)],
            text: text, subject: 'Mi insignia en Vive la UCA');
      } else {
        throw Exception('Error al descargar las imágenes: '
            'badgeResponse: ${badgeResponse.statusCode}, '
            'routeResponse: ${routeResponse.statusCode}');
      }
    } catch (e) {
      print('Error al compartir la insignia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir la insignia: $e')),
      );
    }
  }

  Future<ui.Image> _loadImage(Uint8List imgBytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imgBytes, (img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        badgeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.verified,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      text: 'Conseguido en ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: routeName,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () => _shareBadge(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Compartir',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            badgeName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        badgeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.verified,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      text: 'Conseguido en ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: routeName,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () => _shareBadge(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Compartir',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
