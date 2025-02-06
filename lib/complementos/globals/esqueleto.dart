import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({Key? key, this.width = double.infinity, this.height = 24.0, this.borderRadius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}

class MenuSkeleton extends StatelessWidget {
  const MenuSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          5,
          (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SkeletonLoader(width: 60, height: 60, borderRadius: BorderRadius.circular(30)), // Icono
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader(height: 10, borderRadius: BorderRadius.circular(10)),
                          const SizedBox(height: 5),
                          SkeletonLoader(width: double.infinity / 2, height: 10, borderRadius: BorderRadius.circular(10)), // Descripción parcial
                        ],
                      ),
                    ),
                  ],
                ),
              )),
    );
  }
}
