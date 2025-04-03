import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/template.dart';
import '../providers/providers.dart';
import 'data_entry_screen.dart';

/// Screen for selecting a template
class TemplateSelectionScreen extends ConsumerWidget {
  /// Constructor
  const TemplateSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the templates provider
    final templatesAsync = ref.watch(templatesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Template'),
      ),
      body: templatesAsync.when(
        data: (templates) => _buildTemplateList(context, ref, templates),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading templates: $error'),
        ),
      ),
    );
  }
  
  Widget _buildTemplateList(BuildContext context, WidgetRef ref, List<Template> templates) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _selectTemplate(context, ref, template),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text(template.type.toUpperCase()),
                    backgroundColor: _getTypeColor(template.type),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _selectTemplate(BuildContext context, WidgetRef ref, Template template) {
    // Set the selected template
    ref.read(selectedTemplateProvider.notifier).state = template;
    
    // Navigate to data entry screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DataEntryScreen(),
      ),
    );
  }
  
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'preventive':
        return Colors.green.shade100;
      case 'repair':
        return Colors.orange.shade100;
      case 'inspection':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
} 