/// Represents a maintenance report template stored in the app
class Template {
  /// Unique identifier for the template
  final String id;
  
  /// Display name of the template
  final String name;
  
  /// Path to the template file in assets or local storage
  final String filePath;
  
  /// Brief description of what the template is used for
  final String description;
  
  /// Type of maintenance this template is for (preventive, repair, inspection, etc.)
  final String type;

  /// Constructor
  Template({
    required this.id,
    required this.name,
    required this.filePath,
    required this.description,
    required this.type,
  });

  /// Create a Template from a map (useful for predefined templates)
  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      id: map['id'],
      name: map['name'],
      filePath: map['filePath'],
      description: map['description'],
      type: map['type'],
    );
  }

  /// Convert Template to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'description': description,
      'type': type,
    };
  }
} 