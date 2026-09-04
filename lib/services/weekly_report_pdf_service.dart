import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'weekly_report_service.dart';

class WeeklyReportPdfService {
  static Future<String> downloadReport({
    required WeeklyReport report,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    debugPrint('PDF: Starting PDF creation...');

    final pdf = pw.Document();

    // ------------------------------------------------------------
    // PAGE 1 - HEADER + WEEK OVERVIEW
    // ------------------------------------------------------------

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColors.green700,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'HAPPY LIVER',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Weekly Health & Fitness Report',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 15,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              'Weekly Overview',
              style: pw.TextStyle(
                fontSize: 19,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            _buildOverviewTable(report),

            pw.SizedBox(height: 20),

            // ------------------------------------------------------------
            // DIET SUMMARY
            // ------------------------------------------------------------

            pw.Text(
              'Diet Summary',
              style: pw.TextStyle(
                fontSize: 19,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            _buildSummaryBox(
              title: 'Diet Performance',
              rows: [
                _row(
                  'Diet Followed Days',
                  '${report.dietFollowedDays} / 7',
                ),
                _row(
                  'Diet Percentage',
                  '${report.dietPercentage.toStringAsFixed(0)}%',
                ),
                _row(
                  'Healthy Choices',
                  '${report.healthyChoices}',
                ),
                _row(
                  'Average Calories',
                  '${report.averageCalories.toStringAsFixed(0)} kcal',
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ------------------------------------------------------------
            // WORKOUT SUMMARY
            // ------------------------------------------------------------

            pw.Text(
              'Workout Summary',
              style: pw.TextStyle(
                fontSize: 19,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            _buildSummaryBox(
              title: 'Workout Performance',
              rows: [
                _row(
                  'Workout Completed',
                  '${report.workoutCompletedDays} / 7 days',
                ),
                _row(
                  'Workout Percentage',
                  '${report.workoutPercentage.toStringAsFixed(0)}%',
                ),
                _row(
                  'Total Workouts',
                  '${report.totalWorkout}',
                ),
                _row(
                  'Total Duration',
                  '${report.totalDuration} min',
                ),
                _row(
                  'Total Calories Burned',
                  '${report.totalCalories.toStringAsFixed(0)} kcal',
                ),
                _row(
                  'Average Calories',
                  '${report.averageCalories.toStringAsFixed(0)} kcal',
                ),
                _row(
                  'Average Intensity',
                  report.intensityText,
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ------------------------------------------------------------
            // WEEKLY PROGRESS
            // ------------------------------------------------------------

            pw.Text(
              'Weekly Progress',
              style: pw.TextStyle(
                fontSize: 19,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            _buildProgressBox(report),

            pw.SizedBox(height: 20),

            // ------------------------------------------------------------
            // TIP OF THE WEEK
            // ------------------------------------------------------------

            pw.Text(
              'Tip of the Week',
              style: pw.TextStyle(
                fontSize: 19,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(
                  color: PdfColors.green300,
                ),
              ),
              child: pw.Text(
                report.tipOfWeek,
                style: const pw.TextStyle(
                  fontSize: 12,
                  lineSpacing: 4,
                ),
              ),
            ),

            pw.SizedBox(height: 25),

            // Footer
            pw.Center(
              child: pw.Text(
                'Generated by Happy Liver App',
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 9,
                ),
              ),
            ),
          ];
        },
      ),
    );

    // ------------------------------------------------------------
    // CREATE PDF BYTES
    // ------------------------------------------------------------

    debugPrint('PDF: Creating PDF bytes...');

    final Uint8List bytes = await pdf.save();

    debugPrint(
      'PDF: PDF bytes created successfully. Size: ${bytes.length}',
    );

    // ------------------------------------------------------------
    // SAVE PDF DIRECTLY
    // ------------------------------------------------------------

    debugPrint(
      'PDF: Getting application documents directory...',
    );

    final directory = await getApplicationDocumentsDirectory();

    debugPrint(
      'PDF: Directory = ${directory.path}',
    );

    final fileName =
        'weekly_report_${_fileDate(weekStart)}.pdf';

    final file = File(
      '${directory.path}/$fileName',
    );

    debugPrint(
      'PDF: Saving file...',
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    debugPrint(
      'PDF: File saved successfully: ${file.path}',
    );

    return file.path;
  }

  // ============================================================
  // WEEK OVERVIEW TABLE
  // ============================================================

  static pw.Widget _buildOverviewTable(
      WeeklyReport report,
      ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
        columnWidths: const {
          0: pw.FlexColumnWidth(1.2),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              color: PdfColors.green700,
            ),
            children: [
              _tableHeader('Day'),
              _tableHeader('Diet'),
              _tableHeader('Workout'),
              _tableHeader('Status'),
            ],
          ),

          ...report.days.map(
                (day) {
              return pw.TableRow(
                children: [
                  _tableCell(
                    _dayName(day.date),
                  ),
                  _tableCell(
                    day.dietFollowed
                        ? 'Followed'
                        : 'Not Followed',
                  ),
                  _tableCell(
                    day.workoutCompleted
                        ? 'Completed'
                        : 'Not Done',
                  ),
                  _tableCell(
                    _getDayStatus(day),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY BOX
  // ============================================================

  static pw.Widget _buildSummaryBox({
    required String title,
    required List<pw.Widget> rows,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS BOX
  // ============================================================

  static pw.Widget _buildProgressBox(
      WeeklyReport report,
      ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Comparison with Previous Week',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            report.progressComparedToLastWeek.toString(),
            style: const pw.TextStyle(
              fontSize: 12,
              lineSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROW
  // ============================================================

  static pw.Widget _row(
      String title,
      String value,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: pw.Row(
        mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 11,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  static pw.Widget _tableHeader(
      String text,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // TABLE CELL
  // ============================================================

  static pw.Widget _tableCell(
      String text,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 9,
        ),
      ),
    );
  }

  // ============================================================
  // DAY STATUS
  // ============================================================

  static String _getDayStatus(
      DailyReport day,
      ) {
    if (day.dietFollowed && day.workoutCompleted) {
      return 'Excellent';
    }

    if (day.dietFollowed || day.workoutCompleted) {
      return 'Good';
    }

    return 'Needs Improvement';
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  static String _formatDate(
      DateTime date,
      ) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // FILE DATE
  // ============================================================

  static String _fileDate(
      DateTime date,
      ) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '${year}_${month}_$day';
  }

  // ============================================================
  // DAY NAME
  // ============================================================

  static String _dayName(
      DateTime date,
      ) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }
}