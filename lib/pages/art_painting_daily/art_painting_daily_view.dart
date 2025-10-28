import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'art_painting_daily_logic.dart';

class ArtPaintingDailyView extends GetView<ArtPaintingDailyLogic> {
  const ArtPaintingDailyView({super.key});

  @override
  Widget build(BuildContext context) {
    
    if (!Get.isRegistered<ArtPaintingDailyLogic>()) {
      Get.put(ArtPaintingDailyLogic());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                
                if (controller.isLoading.value) {
                  return _buildLoadingState();
                }

                if (controller.hasError.value) {
                  return _buildErrorState();
                }

                return _buildContent();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/icon_palette.png', width: 32.w, height: 32.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Daily Recommendation',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 42.h),
            _buildArtworkImage(),
            SizedBox(height: 24.h),
            _buildArtworkInfo(),
            SizedBox(height: 48.h),
            _buildViewDetailsButton(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
          SizedBox(height: 16.h),
          Text(
            'Loading daily recommendation...',
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.black54),
            SizedBox(height: 16.h),
            Obx(
              () => Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.black87),
              ),
            ),
            SizedBox(height: 24.h),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: controller.onRetry,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          'Retry',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkImage() {
    return Obx(() {
      final artwork = controller.dailyArtwork.value;
      if (artwork == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: controller.onArtworkImageTap,
        child: Hero(
          tag: 'artwork_${artwork.id}',
          child: Container(
            width: double.infinity,
            height: 400.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(12.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: _buildImage(artwork.imageUrl),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildImage(String imageUrl) {
    
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }

    final file = File(imageUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64.w,
            color: Colors.black38,
          ),
          SizedBox(height: 8.h),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkInfo() {
    return Obx(() {
      final artwork = controller.dailyArtwork.value;
      if (artwork == null) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artwork.artist,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              artwork.title,
              style: TextStyle(fontSize: 18.sp, color: Colors.black),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildViewDetailsButton() {
    return Obx(() {
      final artwork = controller.dailyArtwork.value;
      final isEnabled = artwork != null;

      return GestureDetector(
        onTap: isEnabled ? controller.onViewDetailsTap : null,
        child: AnimatedScale(
          scale: isEnabled ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: isEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              height: 56.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.w),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Image.asset(
                    'assets/icon_arrow_right_black.png',
                    width: 20.w,
                    height: 20.w,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
