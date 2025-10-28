import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../db_art_painting/data.dart';
import '../../db_art_painting/db_art_painting_entity.dart';

class ArtPaintingDetailLogic extends GetxController {
  final ArtPaintingDatabase _db = Get.find<ArtPaintingDatabase>();

  final Rx<ArtworkEntity?> currentArtwork = Rx<ArtworkEntity?>(null);
  final isLoading = true.obs;

  final RxList<ArtworkEntity> sectionArtworks = <ArtworkEntity>[].obs;
  final currentArtworkIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArtwork();
  }

  Future<void> _loadArtwork() async {
    try {
      isLoading.value = true;

      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments == null || !arguments.containsKey('artwork_id')) {
        Get.snackbar(
          'Error',
          'Artwork ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final artworkId = arguments['artwork_id'] as int;

      final artwork = await _db.getArtworkById(artworkId);

      if (artwork == null) {
        Get.snackbar(
          'Error',
          'Artwork not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      currentArtwork.value = artwork;

      await _loadSectionArtworks(artwork.sectionId);
    } catch (e) {
      print('Error loading artwork: $e');
      Get.snackbar(
        'Error',
        'Failed to load artwork. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSectionArtworks(int sectionId) async {
    try {
      final artworks = await _db.getArtworksBySectionId(sectionId);
      sectionArtworks.value = artworks;

      if (currentArtwork.value != null) {
        final index = artworks.indexWhere(
          (artwork) => artwork.id == currentArtwork.value!.id,
        );
        if (index != -1) {
          currentArtworkIndex.value = index;
        }
      }
    } catch (e) {
      print('Error loading section artworks: $e');
      sectionArtworks.value = [];
    }
  }

  Future<void> onNextArtworkTap() async {
    if (sectionArtworks.isEmpty) return;

    if (currentArtworkIndex.value >= sectionArtworks.length - 1) {
      Get.snackbar(
        'End of Gallery',
        'You\'ve reached the end',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isLoading.value = true;

      currentArtworkIndex.value++;
      final nextArtwork = sectionArtworks[currentArtworkIndex.value];

      currentArtwork.value = nextArtwork;
    } catch (e) {
      print('Error loading next artwork: $e');
      Get.snackbar(
        'Error',
        'Failed to load next artwork. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      if (currentArtworkIndex.value > 0) {
        currentArtworkIndex.value--;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onBackTap() {
    Get.back();
  }

  String formatDimensions(double? width, double? height, String? unit) {
    if (width == null || height == null || unit == null) {
      return 'Dimensions Unknown';
    }

    String w = width.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    String h = height.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

    return '$w x $h $unit';
  }

  String getArtworkTitle() {
    return currentArtwork.value?.title ?? 'Untitled';
  }

  String getArtistName() {
    return currentArtwork.value?.artist ?? 'Unknown Artist';
  }

  String getYear() {
    final year = currentArtwork.value?.year;
    return year != null ? year.toString() : 'Year Unknown';
  }

  String getMedium() {
    return currentArtwork.value?.medium ?? 'Medium Unknown';
  }

  String getDimensions() {
    final artwork = currentArtwork.value;
    if (artwork == null) return 'Dimensions Unknown';

    return formatDimensions(
      artwork.dimensionWidth,
      artwork.dimensionHeight,
      artwork.dimensionUnit,
    );
  }

  String getDescription() {
    return currentArtwork.value?.description ?? 'No description available.';
  }

  String getImageUrl() {
    return currentArtwork.value?.imageUrl ?? '';
  }
}
