import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_data.dart';
import '../models/template.dart';
import '../providers/providers.dart';
import '../services/photo_service.dart';
import 'pdf_preview_screen.dart';

/// Screen for entering maintenance data
class DataEntryScreen extends ConsumerStatefulWidget {
  /// Constructor
  const DataEntryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends ConsumerState<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final MaintenanceData _data;
  final List<TextEditingController> _checklistControllers = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Get the current maintenance data
    _data = ref.read(maintenanceDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTemplate = ref.watch(selectedTemplateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Data - ${selectedTemplate?.name ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _generatePDF,
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: selectedTemplate == null
          ? const Center(child: Text('No template selected. Please go back and select a template.'))
          : _buildForm(selectedTemplate),
    );
  }

  Widget _buildForm(Template template) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Equipment Information
            _buildSectionHeader('Equipment Information'),
            _buildTextField(
              label: 'Equipment ID',
              onSaved: (value) => _data.equipmentId = value,
              initialValue: _data.equipmentId,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            _buildTextField(
              label: 'Serial Number',
              onSaved: (value) => _data.serialNumber = value,
              initialValue: _data.serialNumber,
            ),
            _buildTextField(
              label: 'Location',
              onSaved: (value) => _data.location = value,
              initialValue: _data.location,
            ),
            
            // Show manufacturer and model for preventive reports
            if (template.type == 'preventive') ...[
              _buildTextField(
                label: 'Manufacturer',
                onSaved: (value) => _data.manufacturer = value,
                initialValue: _data.manufacturer,
              ),
              _buildTextField(
                label: 'Model',
                onSaved: (value) => _data.model = value,
                initialValue: _data.model,
              ),
            ],
            
            // Show department for repair reports
            if (template.type == 'repair') ...[
              _buildTextField(
                label: 'Department',
                onSaved: (value) => _data.department = value,
                initialValue: _data.department,
              ),
            ],
            
            // Show equipment type for inspection reports
            if (template.type == 'inspection') ...[
              _buildTextField(
                label: 'Equipment Type',
                onSaved: (value) => _data.equipmentType = value,
                initialValue: _data.equipmentType,
              ),
            ],
            
            // Maintenance Information
            _buildSectionHeader('Maintenance Information'),
            _buildTextField(
              label: 'Technician Name',
              onSaved: (value) => _data.technicianName = value,
              initialValue: _data.technicianName,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            
            // Date picker
            _buildDatePicker(
              label: 'Date',
              selectedDate: _data.date ?? DateTime.now(),
              onDateSelected: (date) {
                setState(() {
                  _data.date = date;
                });
              },
            ),
            
            // Time field
            _buildTextField(
              label: 'Time',
              onSaved: (value) => _data.time = value,
              initialValue: _data.time ?? TimeOfDay.now().format(context),
              keyboardType: TextInputType.datetime,
            ),
            
            // Show inspection type for inspection reports
            if (template.type == 'inspection') ...[
              _buildTextField(
                label: 'Inspection Type',
                onSaved: (value) => _data.inspectionType = value,
                initialValue: _data.inspectionType,
              ),
            ],
            
            // Template-specific fields
            if (template.type == 'preventive') ...[
              _buildSectionHeader('Preventive Maintenance'),
              _buildTextField(
                label: 'Tasks Performed',
                onSaved: (value) => _data.tasks = value,
                initialValue: _data.tasks,
                maxLines: 3,
              ),
              _buildTextField(
                label: 'Notes',
                onSaved: (value) => _data.notes = value,
                initialValue: _data.notes,
                maxLines: 3,
              ),
              _buildTextField(
                label: 'Recommendations',
                onSaved: (value) => _data.recommendations = value,
                initialValue: _data.recommendations,
                maxLines: 3,
              ),
              
              // Photos section
              _buildSectionHeader('Photos'),
              _buildPhotoSection(_data.photos),
            ],
            
            // Repair-specific fields
            if (template.type == 'repair') ...[
              _buildSectionHeader('Repair Information'),
              
              // Reported date picker
              _buildDatePicker(
                label: 'Reported Date',
                selectedDate: _data.reportedDate ?? DateTime.now(),
                onDateSelected: (date) {
                  setState(() {
                    _data.reportedDate = date;
                  });
                },
              ),
              
              _buildTextField(
                label: 'Reported By',
                onSaved: (value) => _data.reportedBy = value,
                initialValue: _data.reportedBy,
              ),
              
              _buildTextField(
                label: 'Issue Description',
                onSaved: (value) => _data.issueDescription = value,
                initialValue: _data.issueDescription,
                maxLines: 3,
              ),
              
              _buildTextField(
                label: 'Parts Replaced',
                onSaved: (value) => _data.partsReplaced = value,
                initialValue: _data.partsReplaced,
                maxLines: 2,
              ),
              
              _buildTextField(
                label: 'Labor Hours',
                onSaved: (value) => _data.laborHours = value,
                initialValue: _data.laborHours,
                keyboardType: TextInputType.number,
              ),
              
              _buildTextField(
                label: 'Repair Notes',
                onSaved: (value) => _data.notes = value,
                initialValue: _data.notes,
                maxLines: 3,
              ),
              
              // Follow-up section
              _buildSectionHeader('Follow-up'),
              
              SwitchListTile(
                title: const Text('Follow-up Needed'),
                value: _data.followupNeeded,
                onChanged: (value) {
                  setState(() {
                    _data.followupNeeded = value;
                  });
                },
              ),
              
              if (_data.followupNeeded) ...[
                // Follow-up date picker
                _buildDatePicker(
                  label: 'Follow-up Date',
                  selectedDate: _data.followupDate ?? DateTime.now().add(const Duration(days: 7)),
                  onDateSelected: (date) {
                    setState(() {
                      _data.followupDate = date;
                    });
                  },
                ),
                
                _buildTextField(
                  label: 'Follow-up Notes',
                  onSaved: (value) => _data.followupNotes = value,
                  initialValue: _data.followupNotes,
                  maxLines: 2,
                ),
              ],
              
              // Before/after photos
              _buildSectionHeader('Before Repair Photos'),
              _buildPhotoSection(_data.beforePhotos, isBeforePhotos: true),
              
              _buildSectionHeader('After Repair Photos'),
              _buildPhotoSection(_data.afterPhotos, isAfterPhotos: true),
            ],
            
            // Inspection-specific fields
            if (template.type == 'inspection') ...[
              _buildSectionHeader('Inspection Details'),
              
              // Checklist items
              ..._buildChecklistItems(),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Checklist Item'),
                onPressed: _addChecklistItem,
              ),
              
              const SizedBox(height: 16),
              
              // Compliance section
              _buildSectionHeader('Compliance'),
              
              SwitchListTile(
                title: const Text('Compliant'),
                value: _data.isCompliant,
                onChanged: (value) {
                  setState(() {
                    _data.isCompliant = value;
                  });
                },
              ),
              
              if (!_data.isCompliant) ...[
                _buildTextField(
                  label: 'Non-compliance Details',
                  onSaved: (value) => _data.nonComplianceDetails = value,
                  initialValue: _data.nonComplianceDetails,
                  maxLines: 3,
                ),
              ],
              
              _buildTextField(
                label: 'Recommendations',
                onSaved: (value) => _data.recommendations = value,
                initialValue: _data.recommendations,
                maxLines: 3,
              ),
              
              // Next inspection date picker
              _buildDatePicker(
                label: 'Next Inspection Due',
                selectedDate: _data.nextInspectionDate ?? DateTime.now().add(const Duration(days: 90)),
                onDateSelected: (date) {
                  setState(() {
                    _data.nextInspectionDate = date;
                  });
                },
              ),
              
              _buildTextField(
                label: 'Critical Items for Next Inspection',
                onSaved: (value) => _data.criticalItemsForNextInspection = value,
                initialValue: _data.criticalItemsForNextInspection,
                maxLines: 2,
              ),
              
              // Photos section
              _buildSectionHeader('Photos'),
              _buildPhotoSection(_data.photos),
            ],
            
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate PDF'),
                onPressed: _generatePDF,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String?) onSaved,
    String? initialValue,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        initialValue: initialValue,
        validator: validator,
        onSaved: onSaved,
        maxLines: maxLines,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                onDateSelected(pickedDate);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(List<File> photos, {bool isBeforePhotos = false, bool isAfterPhotos = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              onPressed: () => _takePhoto(photos, isBeforePhotos, isAfterPhotos),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Photo'),
              onPressed: () => _pickPhoto(photos, isBeforePhotos, isAfterPhotos),
            ),
          ],
        ),
        const SizedBox(height: 16),
        photos.isEmpty
            ? const Text('No photos added')
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          photos[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              photos.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ],
    );
  }

  List<Widget> _buildChecklistItems() {
    final widgets = <Widget>[];
    
    // Add controllers for existing checklist items
    while (_checklistControllers.length < _data.checklistItems.length * 3) {
      _checklistControllers.add(TextEditingController());
      _checklistControllers.add(TextEditingController());
      _checklistControllers.add(TextEditingController());
    }
    
    // Create UI for each checklist item
    for (int i = 0; i < _data.checklistItems.length; i++) {
      final item = _data.checklistItems[i];
      
      // Set controller values
      _checklistControllers[i * 3].text = item['item'] ?? '';
      _checklistControllers[i * 3 + 1].text = item['status'] ?? '';
      _checklistControllers[i * 3 + 2].text = item['notes'] ?? '';
      
      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Item ${i + 1}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeChecklistItem(i),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _checklistControllers[i * 3],
                  decoration: const InputDecoration(
                    labelText: 'Item',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _data.checklistItems[i]['item'] = value;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _checklistControllers[i * 3 + 1],
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _data.checklistItems[i]['status'] = value;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _checklistControllers[i * 3 + 2],
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _data.checklistItems[i]['notes'] = value;
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }

  void _addChecklistItem() {
    setState(() {
      _data.checklistItems.add({
        'item': '',
        'status': '',
        'notes': '',
      });
      
      // Add controllers for the new item
      _checklistControllers.add(TextEditingController());
      _checklistControllers.add(TextEditingController());
      _checklistControllers.add(TextEditingController());
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _data.checklistItems.removeAt(index);
      
      // Remove the controllers for this item
      _checklistControllers.removeAt(index * 3);
      _checklistControllers.removeAt(index * 3);
      _checklistControllers.removeAt(index * 3);
    });
  }

  Future<void> _takePhoto(List<File> targetList, bool isBeforePhotos, bool isAfterPhotos) async {
    final photoService = ref.read(photoServiceProvider);
    final photo = await photoService.takePhoto();
    
    if (photo != null) {
      setState(() {
        targetList.add(photo);
      });
    }
  }

  Future<void> _pickPhoto(List<File> targetList, bool isBeforePhotos, bool isAfterPhotos) async {
    final photoService = ref.read(photoServiceProvider);
    final photo = await photoService.pickPhotoFromGallery();
    
    if (photo != null) {
      setState(() {
        targetList.add(photo);
      });
    }
  }

  void _generatePDF() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Update the maintenance data in the provider
      ref.read(maintenanceDataProvider.notifier).state = _data;
      
      // Navigate to PDF preview screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PdfPreviewScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    for (final controller in _checklistControllers) {
      controller.dispose();
    }
    super.dispose();
  }
} 