import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';

Widget buildRouteCardSkeleton() {
  return Container(
    width: 330,
    child: Card(
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeletonizer(
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeletonizer(
                  child: Container(
                    height: 20,
                    width: 200,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 8),
                Skeletonizer(
                  child: Container(
                    height: 16,
                    width: 100,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 8),
                Skeletonizer(
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
