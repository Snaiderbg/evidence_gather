# Evidence Gather

A Flutter application that allows maintenance technicians to collect temporary data, take photos, and generate PDF reports using pre-saved Markdown templates.

## Features

- **Template Selection**: Choose from several pre-built maintenance report templates
- **Data Collection**: Enter equipment details, maintenance information, and notes
- **Photo Capture**: Take photos with the device camera or choose from the gallery
- **PDF Generation**: Merge data and photos with the selected template
- **Export**: Download PDFs to the device or share via the OS share sheet
- **Ephemeral Data**: All maintenance data is kept only in memory during the current session
- **Cross-Platform**: Works on both Android and iOS

## Templates

The app comes with three built-in templates:

1. **Preventive Maintenance**: For routine preventive maintenance activities
2. **Repair Report**: For documenting equipment repairs
3. **Inspection Report**: For equipment inspection and compliance checks

## Usage

1. Launch the app and tap "Create New Report"
2. Select a template for your maintenance report
3. Fill in the maintenance data and take photos as needed
4. Generate a PDF preview
5. Download or share the PDF
6. Start over for a new report (all previous data is discarded)

## Technical Details

- **State Management**: Flutter Riverpod for state management
- **PDF Generation**: Converts Markdown templates to PDF using the dart `pdf` package
- **Data Storage**: No persistent storage of user-entered maintenance data
- **Photo Handling**: Photos stored temporarily and cleaned up after PDF generation
- **Template Storage**: Templates stored as Markdown files in the app's assets

## Requirements

- Flutter 3.0.0 or higher
- iOS 12.0+ or Android 5.0+
- Camera and Storage permissions for the full experience

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Getting Started

To run this app locally:

```bash
git clone https://github.com/your-username/evidence_gather.git
cd evidence_gather
flutter pub get
flutter run
```

## Credits

- PDF generation using [pdf](https://pub.dev/packages/pdf)
- Image picking with [image_picker](https://pub.dev/packages/image_picker)
- State management using [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
