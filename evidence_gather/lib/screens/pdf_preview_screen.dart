import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';
import '../models/maintenance_data.dart';
import '../providers/providers.dart';
import '../services/photo_service.dart';

/// Screen for previewing and sharing a generated PDF
class PdfPreviewScreen extends ConsumerStatefulWidget {
  /// Constructor
  const PdfPreviewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  late final String _fileName;
  
  @override
  void initState() {
    super.initState();
    // Generate a filename based on template type and date
    final template = ref.read(selectedTemplateProvider);
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);
    _fileName = '${template?.type ?? 'report'}_$dateStr.pdf';
  }

  @override
  Widget build(BuildContext context) {
    final pdfAsync = ref.watch(pdfGenerationProvider(_fileName));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          pdfAsync.maybeWhen(
            data: (file) => IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _sharePdf(file),
              tooltip: 'Share PDF',
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          pdfAsync.maybeWhen(
            data: (file) => IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadPdf(file),
              tooltip: 'Download PDF',
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: pdfAsync.when(
        data: (file) => _buildPdfPreview(file),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error generating PDF: $error'),
        ),
      ),
    );
  }

  Widget _buildPdfPreview(File pdfFile) {
    // In a real app, you would use a PDF viewer here
    // For simplicity, we'll just show a success message
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.picture_as_pdf,
            size: 72,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'PDF Generated',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'File: $_fileName',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Size: ${(pdfFile.lengthSync() / 1024).toStringAsFixed(2)} KB',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share PDF'),
                onPressed: () => _sharePdf(pdfFile),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download PDF'),
                onPressed: () => _downloadPdf(pdfFile),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Discard and Start Over'),
            onPressed: _discardAndStartOver,
          ),
        ],
      ),
    );
  }

  Future<void> _sharePdf(File file) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Maintenance Report',
        text: 'Sharing maintenance report: $_fileName',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDF: $e')),
      );
    }
  }

  Future<void> _downloadPdf(File file) async {
    try {
      // Read file as bytes
      final bytes = await file.readAsBytes();
      
      // Save file
      await FileSaver.instance.saveFile(
        name: _fileName.split('.').first,
        bytes: bytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
    }
  }

  void _discardAndStartOver() {
    // Clean up photos
    ref.read(photoServiceProvider).cleanupTempFiles();
    
    // Clear maintenance data
    ref.read(maintenanceDataProvider.notifier).state = MaintenanceData();
    
    // Clear selected template
    ref.read(selectedTemplateProvider.notifier).state = null;
    
    // Navigate back to the home screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
} 