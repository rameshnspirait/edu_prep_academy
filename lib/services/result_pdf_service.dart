import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ResultPdfService {
  static Future<void> generate(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColor.fromInt(0xff4B5563),
                width: 2,
              ),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "EduPrep Academy",
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xff1F2937),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "Mock Test Result Certificate",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xff2563EB),
                  ),
                ),
                pw.Divider(thickness: 2, color: PdfColor.fromInt(0xff2563EB)),
                pw.SizedBox(height: 30),

                // ---------------- USER INFO ----------------
                pw.Text(
                  "Test: ${data['testName']}",
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 16),

                // ---------------- SCORE DETAILS ----------------
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xffE0F2FE),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _row(
                        "Score",
                        "${data['obtainedMarks']} / ${data['totalMarks']}",
                      ),
                      _row(
                        "Correct Answers",
                        data['correctAnswered'].toString(),
                      ),
                      _row("Attempts", data['attempts'].toString()),
                      _row("Rank", data['rank'].toString()),
                      _row(
                        "Percentile",
                        "${data['percentile']?.toStringAsFixed(1) ?? '--'}%",
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 40),

                pw.Text(
                  "Congratulations!",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xff16A34A),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  "Keep practicing to improve your score and percentile.",
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColor.fromInt(0xff4B5563),
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.Spacer(),

                // ---------------- FOOTER ----------------
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "EduPrep Academy ©",
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColor.fromInt(0xff6B7280),
                      ),
                    ),
                    pw.Text(
                      "Generated on: ${DateTime.now().toLocal().toString().split(' ')[0]}",
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColor.fromInt(0xff6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
