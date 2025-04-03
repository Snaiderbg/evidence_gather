import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/template.dart';

/// Service for managing templates
class TemplateService {
  /// List of available templates
  List<Template> _templates = [];

  /// Get all available templates
  List<Template> get templates => _templates;

  /// Initialize the service and load templates
  Future<void> initialize() async {
    await _loadPredefinedTemplates();
  }

  /// Load predefined templates from assets
  Future<void> _loadPredefinedTemplates() async {
    _templates = [
      Template(
        id: 'preventive',
        name: 'Preventive Maintenance',
        filePath: 'assets/templates/preventive_maintenance.md',
        description: 'Template for routine preventive maintenance activities',
        type: 'preventive',
      ),
      Template(
        id: 'repair',
        name: 'Repair Report',
        filePath: 'assets/templates/repair_report.md',
        description: 'Template for equipment repair documentation',
        type: 'repair',
      ),
      Template(
        id: 'inspection',
        name: 'Inspection Report',
        filePath: 'assets/templates/inspection_report.md',
        description: 'Template for equipment inspection and compliance',
        type: 'inspection',
      ),
    ];
  }

  /// Load a template file content
  Future<String> loadTemplateContent(String filePath) async {
    try {
      return await rootBundle.loadString(filePath);
    } catch (e) {
      throw Exception('Failed to load template: $e');
    }
  }

  /// Get a template by ID
  Template? getTemplateById(String id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
} 