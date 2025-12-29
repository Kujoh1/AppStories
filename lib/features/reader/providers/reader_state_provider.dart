import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/story_page.dart';
import '../../../core/constants/app_constants.dart';

/// State for the reader screen
class ReaderState {
  final String currentPageId;
  final StoryPage? currentPage;
  final bool isLoading;
  final String? error;
  final double textScale;
  final double zoom;
  final String fontFamily;

  const ReaderState({
    required this.currentPageId,
    this.currentPage,
    this.isLoading = false,
    this.error,
    this.textScale = AppConstants.defaultTextScale,
    this.zoom = AppConstants.defaultZoom,
    this.fontFamily = 'default',
  });

  ReaderState copyWith({
    String? currentPageId,
    StoryPage? currentPage,
    bool? isLoading,
    String? error,
    double? textScale,
    double? zoom,
    String? fontFamily,
  }) {
    return ReaderState(
      currentPageId: currentPageId ?? this.currentPageId,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      textScale: textScale ?? this.textScale,
      zoom: zoom ?? this.zoom,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

/// Notifier for managing reader state
class ReaderStateNotifier extends StateNotifier<ReaderState> {
  ReaderStateNotifier(String initialPageId)
      : super(ReaderState(currentPageId: initialPageId));

  void setCurrentPage(StoryPage page) {
    state = state.copyWith(
      currentPageId: page.id,
      currentPage: page,
      isLoading: false,
      error: null,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void setTextScale(double scale) {
    final clampedScale = scale.clamp(
      AppConstants.minTextScale,
      AppConstants.maxTextScale,
    );
    state = state.copyWith(textScale: clampedScale);
  }

  void increaseTextScale() {
    setTextScale(state.textScale + AppConstants.textScaleStep);
  }

  void decreaseTextScale() {
    setTextScale(state.textScale - AppConstants.textScaleStep);
  }

  void resetTextScale() {
    state = state.copyWith(textScale: AppConstants.defaultTextScale);
  }

  void setZoom(double zoom) {
    final clampedZoom = zoom.clamp(
      AppConstants.minZoom,
      AppConstants.maxZoom,
    );
    state = state.copyWith(zoom: clampedZoom);
  }

  void resetZoom() {
    state = state.copyWith(zoom: AppConstants.defaultZoom);
  }

  void setFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }
}

/// Provider for reader state
final readerStateProvider =
    StateNotifierProvider.family<ReaderStateNotifier, ReaderState, String>(
  (ref, initialPageId) => ReaderStateNotifier(initialPageId),
);


