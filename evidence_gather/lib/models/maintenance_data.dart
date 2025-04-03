import 'dart:io';

/// Represents maintenance data entered by the user
/// This data is ephemeral and only stored in memory during the current session
class MaintenanceData {
  /// Equipment identifier
  String? equipmentId;
  
  /// Equipment serial number
  String? serialNumber;
  
  /// Location of the equipment
  String? location;
  
  /// Manufacturer of the equipment
  String? manufacturer;
  
  /// Model of the equipment
  String? model;
  
  /// Department where the equipment is located
  String? department;
  
  /// Type of equipment
  String? equipmentType;
  
  /// Name of the technician performing the maintenance
  String? technicianName;
  
  /// Date of the maintenance activity
  DateTime? date;
  
  /// Time of the maintenance activity
  String? time;
  
  /// Type of inspection (for inspection reports)
  String? inspectionType;
  
  /// Tasks performed during maintenance
  String? tasks;
  
  /// General notes about the maintenance
  String? notes;
  
  /// Recommendations for future maintenance
  String? recommendations;
  
  /// Date when issue was reported (for repair reports)
  DateTime? reportedDate;
  
  /// Person who reported the issue (for repair reports)
  String? reportedBy;
  
  /// Description of the issue (for repair reports)
  String? issueDescription;
  
  /// Parts replaced during repair (for repair reports)
  String? partsReplaced;
  
  /// Labor hours spent on repair (for repair reports)
  String? laborHours;
  
  /// Whether follow-up is needed (for repair reports)
  bool followupNeeded = false;
  
  /// Date for follow-up (for repair reports)
  DateTime? followupDate;
  
  /// Notes for follow-up (for repair reports)
  String? followupNotes;
  
  /// Compliance status (for inspection reports)
  bool isCompliant = true;
  
  /// Details of non-compliance (for inspection reports)
  String? nonComplianceDetails;
  
  /// Next inspection date (for inspection reports)
  DateTime? nextInspectionDate;
  
  /// Critical items for next inspection (for inspection reports)
  String? criticalItemsForNextInspection;
  
  /// Checklist items (for inspection reports)
  List<Map<String, String>> checklistItems = [];
  
  /// Photos taken during maintenance
  List<File> photos = [];
  
  /// Photos taken before repair (for repair reports)
  List<File> beforePhotos = [];
  
  /// Photos taken after repair (for repair reports)
  List<File> afterPhotos = [];

  /// Default constructor
  MaintenanceData();

  /// Convert data to a map for template substitution
  Map<String, String> toTemplateMap() {
    final map = <String, String>{};
    
    // Add all non-null fields to the map
    if (equipmentId != null) map['equipmentId'] = equipmentId!;
    if (serialNumber != null) map['serialNumber'] = serialNumber!;
    if (location != null) map['location'] = location!;
    if (manufacturer != null) map['manufacturer'] = manufacturer!;
    if (model != null) map['model'] = model!;
    if (department != null) map['department'] = department!;
    if (equipmentType != null) map['equipmentType'] = equipmentType!;
    if (technicianName != null) map['technicianName'] = technicianName!;
    if (date != null) map['date'] = _formatDate(date!);
    if (time != null) map['time'] = time!;
    if (inspectionType != null) map['inspectionType'] = inspectionType!;
    if (tasks != null) map['tasks'] = tasks!;
    if (notes != null) map['notes'] = notes!;
    if (recommendations != null) map['recommendations'] = recommendations!;
    if (reportedDate != null) map['reportedDate'] = _formatDate(reportedDate!);
    if (reportedBy != null) map['reportedBy'] = reportedBy!;
    if (issueDescription != null) map['issueDescription'] = issueDescription!;
    if (partsReplaced != null) map['partsReplaced'] = partsReplaced!;
    if (laborHours != null) map['laborHours'] = laborHours!;
    
    map['followupNeeded'] = followupNeeded ? 'Yes' : 'No';
    
    if (followupDate != null) map['followupDate'] = _formatDate(followupDate!);
    if (followupNotes != null) map['followupNotes'] = followupNotes!;
    
    map['isCompliant'] = isCompliant ? 'Yes' : 'No';
    
    if (nonComplianceDetails != null) map['nonComplianceDetails'] = nonComplianceDetails!;
    if (nextInspectionDate != null) map['nextInspectionDate'] = _formatDate(nextInspectionDate!);
    if (criticalItemsForNextInspection != null) map['criticalItemsForNextInspection'] = criticalItemsForNextInspection!;
    
    // Generate checklist items table if needed
    if (checklistItems.isNotEmpty) {
      final buffer = StringBuffer();
      for (final item in checklistItems) {
        buffer.writeln('| ${item['item'] ?? ''} | ${item['status'] ?? ''} | ${item['notes'] ?? ''} |');
      }
      map['checklistItems'] = buffer.toString();
    }
    
    // Add generation date
    map['generatedDate'] = _formatDate(DateTime.now());
    
    return map;
  }
  
  /// Format a date as a string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 