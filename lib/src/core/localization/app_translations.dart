import 'dart:ui';

import 'package:get/get.dart';

// GetX translations for multi-language support.
class AppTranslations extends Translations {
  static const Locale locale = Locale('en', 'US');
  static const Locale fallbackLocale = Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _enUS,
        'tr_TR': _trTR,
      };

  static const Map<String, String> _enUS = {
    'app_title': 'ImageFlow',
    'face_processed': 'Face Processed',
    'document_scan': 'Document Scan',
    'delete': 'Delete',
    'view_result': 'View Result',
    'no_history_items': 'No history items yet',
    'new_capture': 'New Capture',
    'choose_source': 'Choose Source',
    'camera': 'Camera',
    'gallery': 'Gallery',
    'processing': 'Processing...',
    'detecting_faces': 'Detecting faces...',
    'scanning_document': 'Scanning document...',
  };

  static const Map<String, String> _trTR = {
    'app_title': 'ImageFlow',
    'face_processed': 'Yüz İşlendi',
    'document_scan': 'Doküman Tarandı',
    'delete': 'Sil',
    'view_result': 'Sonucu Gör',
    'no_history_items': 'Henüz geçmiş yok',
    'new_capture': 'Yeni Çekim',
    'choose_source': 'Kaynak Seç',
    'camera': 'Kamera',
    'gallery': 'Galeri',
    'processing': 'İşleniyor...',
    'detecting_faces': 'Yüzler tespit ediliyor...',
    'scanning_document': 'Doküman taranıyor...',
  };
}
