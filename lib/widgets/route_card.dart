import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RouteCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String distance;
  final String redirect;
  final String uid;
  final bool? hasBadge;

  const RouteCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.distance,
    this.redirect = "/",
    required this.uid,
    this.hasBadge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).push(redirect);
      },
      child: Container(
        color: Colors.white,
        width: 330,
        child: Card(
          color: Colors.white,
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: imagePath,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Skeletonizer(
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasBadge != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD9D9D9).withOpacity(0.71),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: SvgPicture.asset(
                      'lib/assets/images/has_badge.svg',
                      width: 25,
                      height: 25,
                      colorFilter: ColorFilter.mode(
                        hasBadge! ? Colors.orange : const Color(0xFF515151),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
