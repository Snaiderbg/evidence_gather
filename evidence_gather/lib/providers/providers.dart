import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/maintenance_data.dart';
import '../models/template.dart';
import '../services/pdf_service.dart';
import '../services/photo_service.dart';
import '../services/template_service.dart';

/// Provider for TemplateService
final templateServiceProvider = Provider<TemplateService>((ref) {
  return TemplateService();
});

/// Provider for PhotoService
final photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService();
});

/// Provider for PDFService
final pdfServiceProvider = Provider<PDFService>((ref) {
  final templateService = ref.watch(templateServiceProvider);
  return PDFService(templateService);
});

/// Provider for templates list
final templatesProvider = FutureProvider<List<Template>>((ref) async {
  final templateService = ref.watch(templateServiceProvider);
  await templateService.initialize();
  return templateService.templates;
});

/// Provider for selected template
final selectedTemplateProvider = StateProvider<Template?>((ref) => null);

/// Provider for maintenance data
final maintenanceDataProvider = StateProvider<MaintenanceData>((ref) {
  return MaintenanceData();
});

/// Provider for PDF generation status
final pdfGenerationProvider = FutureProvider.autoDispose.family<File, String>((ref, fileName) async {
  final pdfService = ref.watch(pdfServiceProvider);
  final selectedTemplate = ref.watch(selectedTemplateProvider);
  final maintenanceData = ref.watch(maintenanceDataProvider);
  
  if (selectedTemplate == null) {
    throw Exception('No template selected');
  }
  
  final pdfBytes = await pdfService.generatePDF(selectedTemplate, maintenanceData);
  return pdfService.savePdfToTemp(pdfBytes, fileName);
}); 