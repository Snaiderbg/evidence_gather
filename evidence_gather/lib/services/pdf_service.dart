import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:intl/intl.dart';
import '../models/maintenance_data.dart';
import '../models/template.dart';
import 'template_service.dart';

/// Service for generating PDFs from templates and maintenance data
class PDFService {
  final TemplateService _templateService;

  /// Constructor
  PDFService(this._templateService);

  /// Generate a PDF from a template and maintenance data
  Future<Uint8List> generatePDF(Template template, MaintenanceData data) async {
    // Load template content
    final templateContent = await _templateService.loadTemplateContent(template.filePath);
    
    // Apply data to template
    final filledTemplate = _applyDataToTemplate(templateContent, data);
    
    // Create PDF document
    final pdf = pw.Document();
    
    // Convert markdown to PDF widgets
    final widgets = await _convertMarkdownToPdfWidgets(filledTemplate, data);
    
    // Add page to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context, template),
        footer: (context) => _buildFooter(context),
        build: (context) => widgets,
      ),
    );
    
    // Return PDF as bytes
    return pdf.save();
  }
  
  /// Apply maintenance data to template content
  String _applyDataToTemplate(String templateContent, MaintenanceData data) {
    final dataMap = data.toTemplateMap();
    String filledTemplate = templateContent;
    
    // Replace all placeholders with actual data
    dataMap.forEach((key, value) {
      filledTemplate = filledTemplate.replaceAll('{{$key}}', value);
    });
    
    // Handle photos
    if (data.photos.isNotEmpty) {
      final photosMarkdown = _generatePhotosMarkdown(data.photos);
      filledTemplate = filledTemplate.replaceAll('{{photos}}', photosMarkdown);
    } else {
      filledTemplate = filledTemplate.replaceAll('{{photos}}', 'No photos provided.');
    }
    
    // Handle before/after photos for repair reports
    if (data.beforePhotos.isNotEmpty) {
      final beforePhotosMarkdown = _generatePhotosMarkdown(data.beforePhotos);
      filledTemplate = filledTemplate.replaceAll('{{beforePhotos}}', beforePhotosMarkdown);
    } else {
      filledTemplate = filledTemplate.replaceAll('{{beforePhotos}}', 'No before photos provided.');
    }
    
    if (data.afterPhotos.isNotEmpty) {
      final afterPhotosMarkdown = _generatePhotosMarkdown(data.afterPhotos);
      filledTemplate = filledTemplate.replaceAll('{{afterPhotos}}', afterPhotosMarkdown);
    } else {
      filledTemplate = filledTemplate.replaceAll('{{afterPhotos}}', 'No after photos provided.');
    }
    
    return filledTemplate;
  }
  
  /// Generate Markdown for photos
  String _generatePhotosMarkdown(List<File> photos) {
    // In real Markdown, we'd use ![Image](path) syntax, but for PDF generation
    // we'll need a different approach. We'll use a placeholder that we'll replace
    // with actual images during PDF generation.
    final buffer = StringBuffer();
    for (int i = 0; i < photos.length; i++) {
      buffer.writeln('![Photo ${i + 1}](${photos[i].path})');
      buffer.writeln();
    }
    return buffer.toString();
  }
  
  /// Convert Markdown to PDF widgets
  Future<List<pw.Widget>> _convertMarkdownToPdfWidgets(String markdown, MaintenanceData data) async {
    final widgets = <pw.Widget>[];
    
    // Parse Markdown
    final lines = markdown.split('\n');
    
    // Simple Markdown parser - in a real app, you would use a proper Markdown parser
    for (final line in lines) {
      if (line.startsWith('# ')) {
        // Heading 1
        widgets.add(
          pw.Header(
            level: 0,
            child: pw.Text(
              line.substring(2),
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // Heading 2
        widgets.add(
          pw.Header(
            level: 1,
            child: pw.Text(
              line.substring(3),
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        // Bullet point
        widgets.add(
          pw.Bullet(
            text: line.substring(2),
            style: const pw.TextStyle(
              fontSize: 12,
            ),
          ),
        );
      } else if (line.startsWith('![')) {
        // Image - extract path from ![Alt text](path) format
        final pathStart = line.indexOf('(') + 1;
        final pathEnd = line.indexOf(')', pathStart);
        if (pathStart > 0 && pathEnd > pathStart) {
          final imagePath = line.substring(pathStart, pathEnd);
          try {
            final imageFile = File(imagePath);
            if (await imageFile.exists()) {
              final imageBytes = await imageFile.readAsBytes();
              final image = pw.MemoryImage(imageBytes);
              widgets.add(
                pw.Center(
                  child: pw.Image(image, height: 200),
                ),
              );
              widgets.add(pw.SizedBox(height: 10));
            }
          } catch (e) {
            widgets.add(pw.Text('Failed to load image: $imagePath'));
          }
        }
      } else if (line.trim().startsWith('|')) {
        // Table row - we'll skip table handling for simplicity
        // In a real app, you would parse and create proper tables
      } else if (line.trim().startsWith('---')) {
        // Horizontal rule
        widgets.add(pw.Divider());
      } else if (line.trim().isNotEmpty) {
        // Regular text
        widgets.add(
          pw.Paragraph(
            text: line,
            style: const pw.TextStyle(
              fontSize: 12,
            ),
          ),
        );
      } else {
        // Empty line - add some spacing
        widgets.add(pw.SizedBox(height: 5));
      }
    }
    
    return widgets;
  }
  
  /// Build PDF header
  pw.Widget _buildHeader(pw.Context context, Template template) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 20, top: 20),
      child: pw.Text(
        template.name,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey700,
        ),
      ),
    );
  }
  
  /// Build PDF footer
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 12,
          color: PdfColors.grey700,
        ),
      ),
    );
  }
  
  /// Save PDF to temporary file and return the file
  Future<File> savePdfToTemp(Uint8List pdfBytes, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(pdfBytes);
    return file;
  }
} 