import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _box(width: 140, height: 14),
                  const SizedBox(height: 8),
                  _box(width: 180, height: 10),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [_statBox(), _statBox(), _statBox()],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ///  SECTION
            _section(),

            _tile(),
            _tile(),
            _tile(),
            _tile(),

            const SizedBox(height: 20),

            _section(),

            _tile(),
            _tile(),
            _tile(),

            const SizedBox(height: 20),

            _section(),

            _tile(),
            _tile(),
            _tile(),
          ],
        ),
      ),
    );
  }

  Widget _box({double width = double.infinity, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _statBox() {
    return Column(
      children: [
        _box(width: 40, height: 14),
        const SizedBox(height: 6),
        _box(width: 50, height: 10),
      ],
    );
  }

  Widget _section() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _box(width: 120, height: 12),
    );
  }

  Widget _tile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(width: double.infinity, height: 12),
                  const SizedBox(height: 6),
                  _box(width: 120, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
