import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'location_details_bottomsheet.dart';

class PlaceCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;

  const PlaceCard(
      {Key? key,
      required this.title,
      required this.imageUrl,
      required this.description})
      : super(key: key);

  void _showLocationDetails(BuildContext context) {
    final location = {
      'name': title,
      'imageUrl': imageUrl,
      'description': description
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => LocationDetailsBottomSheet(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLocationDetails(context),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Skeletonizer(
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                  ),
                ),
                fadeInDuration: const Duration(milliseconds: 500),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
