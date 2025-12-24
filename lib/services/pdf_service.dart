import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/care_plan.dart';

class PdfService {
  Future<void> generateCarePlanPdf(CarePlan carePlan, String patientName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Care Plan',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Patient: $patientName', style: const pw.TextStyle(fontSize: 16)),
              pw.Text(
                'Date: ${carePlan.createdAt.toString().split(' ')[0]}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Medications:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ...carePlan.medications.map(
                (med) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ${med.name}', style: const pw.TextStyle(fontSize: 14)),
                      pw.Text('  Dosage: ${med.dosage}', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('  Frequency: ${med.frequency}', style: const pw.TextStyle(fontSize: 12)),
                      if (med.instructions != null)
                        pw.Text('  Instructions: ${med.instructions}',
                            style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Exercises:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ...carePlan.exercises.map(
                (ex) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ${ex.name}', style: const pw.TextStyle(fontSize: 14)),
                      pw.Text('  Duration: ${ex.duration}', style: const pw.TextStyle(fontSize: 12)),
                      if (ex.description != null)
                        pw.Text('  ${ex.description}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Instructions:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ...carePlan.instructions.map(
                (instruction) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('• $instruction', style: const pw.TextStyle(fontSize: 14)),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
