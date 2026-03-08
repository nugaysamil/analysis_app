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
    'done': 'Done',
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
    'face_result': 'Face Result',
    'before': 'Before',
    'after': 'After',
    'original': 'Original',
    'black_and_white': 'B&W',
    'pdf_created': 'PDF Created',
    'document_title': 'Document Title',
    'open_pdf': 'Open PDF',
    'date': 'Date',
    'type': 'Type',
    'file_size': 'File Size',
    'processing_error': 'Processing Failed',
    'detecting_content': 'Detecting content...',
    'go_back': 'Go Back',
    'batch_processing': 'Batch Processing',
    'batch_gallery': 'Batch Gallery',
    'processing_image_of': 'Processing image @current of @total',
    'batch_complete': 'Batch Complete',
    'batch_summary': 'Batch Summary',
    'success_count': '@count Successful',
    'failed_count': '@count Failed',
    'view_details': 'View Details',
    'failed': 'Failed',
    'back_to_home': 'Back to Home',
  };

  static const Map<String, String> _trTR = {
    'app_title': 'ImageFlow',
    'done': 'Tamam',
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
    'face_result': 'Yüz Sonucu',
    'before': 'Önce',
    'after': 'Sonra',
    'original': 'Orijinal',
    'black_and_white': 'S&B',
    'pdf_created': 'PDF Oluşturuldu',
    'document_title': 'Doküman Başlığı',
    'open_pdf': 'PDF Aç',
    'date': 'Tarih',
    'type': 'Tür',
    'file_size': 'Dosya Boyutu',
    'processing_error': 'İşlem Başarısız',
    'detecting_content': 'İçerik tespit ediliyor...',
    'go_back': 'Geri Dön',
    'batch_processing': 'Toplu İşlem',
    'batch_gallery': 'Toplu Galeri',
    'processing_image_of': '@current / @total görsel işleniyor',
    'batch_complete': 'Toplu İşlem Tamamlandı',
    'batch_summary': 'Toplu Özet',
    'success_count': '@count Başarılı',
    'failed_count': '@count Başarısız',
    'view_details': 'Detayları Gör',
    'failed': 'Başarısız',
    'back_to_home': 'Ana Sayfaya Dön',
  };
}
