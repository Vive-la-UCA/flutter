import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CustomDialogRoute extends StatelessWidget {
  final String locationName;
  final String badgeName;
  final String badgeImageUrl;
  final String routeName;
  final String routeImage;
  final VoidCallback onConfirm; // Añadir el callback de confirmación

  const CustomDialogRoute({
    Key? key,
    required this.locationName,
    required this.badgeName,
    required this.badgeImageUrl,
    required this.routeName,
    required this.routeImage,
    required this.onConfirm, // Añadir el callback de confirmación al constructor
  }) : super(key: key);

  Future<void> _shareBadge(BuildContext context) async {
    final text =
        'He conseguido la insignia "$badgeName" en la ruta "$routeName" gracias a Vive la UCA!';

    try {
      if (badgeImageUrl.isEmpty || routeImage.isEmpty) {
        throw Exception('Las URLs de las imágenes no pueden estar vacías');
      }

      final badgeResponse = await http.get(Uri.parse(badgeImageUrl));
      final routeResponse = await http.get(Uri.parse(routeImage));

      if (badgeResponse.statusCode == 200 && routeResponse.statusCode == 200) {
        final badgeBytes = badgeResponse.bodyBytes;
        final routeBytes = routeResponse.bodyBytes;

        final ByteData logoData =
            await rootBundle.load('lib/assets/images/logo.png');
        final Uint8List logoBytes = logoData.buffer.asUint8List();

        final badgeImage = await _loadImage(badgeBytes);
        final routeImage = await _loadImage(routeBytes);
        final logoImage = await _loadImage(logoBytes);

        final double squareSize = 512;
        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);

        // Draw route image as background
        canvas.drawImageRect(
          routeImage,
          Rect.fromLTWH(0, 0, routeImage.width.toDouble(), routeImage.height.toDouble()),
          Rect.fromLTWH(0, 0, squareSize, squareSize),
          Paint(),
        );

        // Dark overlay for text contrast
        canvas.drawRect(
          Rect.fromLTWH(0, 0, squareSize, squareSize),
          Paint()..color = Colors.black.withOpacity(0.5),
        );

        // Draw badge image in the center
        final double badgeSize = 150;
        final double badgeOffset = (squareSize - badgeSize) / 2;
        canvas.drawImageRect(
          badgeImage,
          Rect.fromLTWH(0, 0, badgeImage.width.toDouble(), badgeImage.height.toDouble()),
          Rect.fromLTWH(badgeOffset, badgeOffset, badgeSize, badgeSize),
          Paint(),
        );

        // Draw logo at the bottom right corner
        final double logoSize = 100;
        final double logoOffset = squareSize - logoSize - 10;
        canvas.drawImageRect(
          logoImage,
          Rect.fromLTWH(0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
          Rect.fromLTWH(logoOffset, logoOffset, logoSize, logoSize),
          Paint(),
        );

        // Draw route name below the badge
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
        textPainter.layout(minWidth: 0, maxWidth: squareSize);
        final double textOffsetY = badgeOffset + badgeSize + 20;
        final double textOffsetX = (squareSize - textPainter.width) / 2;
        textPainter.paint(canvas, Offset(textOffsetX, textOffsetY));

        final combinedImage = await pictureRecorder
            .endRecording()
            .toImage(squareSize.toInt(), squareSize.toInt());
        final byteData = await combinedImage.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/combined_image.png';
        final combinedImageFile = File(filePath);
        await combinedImageFile.writeAsBytes(pngBytes);

        await Share.shareXFiles([XFile(filePath)], text: text, subject: 'Mi insignia en Vive la UCA');
      } else {
        throw Exception(
            'Error al descargar las imágenes: badgeResponse: ${badgeResponse.statusCode}, routeResponse: ${routeResponse.statusCode}');
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              '¡Haz finalizado la ruta!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Felicidades, haz conseguido la insignia "$badgeName" en la ruta "$routeName".',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Image.network(
              badgeImageUrl,
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _shareBadge(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm(); // Llama al callback de confirmación
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
