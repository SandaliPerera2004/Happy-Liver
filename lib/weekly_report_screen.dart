import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/weekly_report_service.dart';
import 'services/weekly_report_pdf_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/services/theme_controller.dart';

class WeeklyReportScreen extends StatefulWidget {
  final WeeklyReportService service;

  const WeeklyReportScreen({
    super.key,
    required this.service,
  });

  @override
  State<WeeklyReportScreen> createState() =>
      _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  late DateTime _selectedDate;

  WeeklyReport? _report;
  bool _isLoading = true;
  String? _error;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF20C55A);
  static const Color headerGreen = Color(0xFFDDF7D2);
  static const Color darkGreen = Color(0xFF123D22);
  static const Color lightGreen = Color(0xFFE7F9E8);
  static const Color softGreen = Color(0xFFF3FBF2);
  static const Color darkText = Color(0xFF111811);
  static const Color greyText = Color(0xFF6F776F);
  static const Color orange = Color(0xFFFFA726);

  // DARK MODE COLORS
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkCardLight = Color(0xFF252A26);
  static const Color darkHeader = Color(0xFF1B3B1F);
  static const Color darkSecondaryText = Color(0xFFB8C0B9);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();

    _loadReport();
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  DateTime _getWeekStart(DateTime date) {
    final dateOnly = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final daysFromMonday =
        dateOnly.weekday - DateTime.monday;

    return dateOnly.subtract(
      Duration(days: daysFromMonday),
    );
  }

  DateTime _getWeekEnd(DateTime date) {
    return _getWeekStart(date).add(
      const Duration(days: 6),
    );
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatWeekRange() {
    final start = _getWeekStart(_selectedDate);
    final end = _getWeekEnd(_selectedDate);

    return '${_formatShortDate(start)} – ${_formatShortDate(end)}';
  }

  // ============================================================
  // BACKEND CONNECTION
  // ============================================================

  Future<void> _loadReport() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final startDate = _getWeekStart(_selectedDate);
      final endDate = _getWeekEnd(_selectedDate);

      final report = await widget.service.getWeeklyReport(
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // PDF DOWNLOAD
  // ============================================================

  Future<void> _downloadReport() async {
    if (_report == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Weekly report is not available yet.',
          ),
        ),
      );

      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Creating weekly report...',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final weekStart = _getWeekStart(_selectedDate);
      final weekEnd = _getWeekEnd(_selectedDate);

      final filePath =
      await WeeklyReportPdfService.downloadReport(
        report: _report!,
        weekStart: weekStart,
        weekEnd: weekEnd,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Weekly report downloaded successfully!',
          ),
          duration: Duration(seconds: 3),
        ),
      );

      debugPrint('PDF saved at: $filePath');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Download failed: $e',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final isDarkMode = ThemeController.isDarkMode.value;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (
          context,
          child,
          ) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: darkCard,
              onSurface: Colors.white,
            )
                : const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });

    await _loadReport();
  }

  void _changeWeek(int amount) {
    setState(() {
      _selectedDate = _selectedDate.add(
        Duration(days: amount * 7),
      );
    });

    _loadReport();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (
          context,
          isDarkMode,
          child,
          ) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: isDarkMode
                ? darkBackground
                : Colors.white,
            statusBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: isDarkMode
                ? darkBackground
                : softGreen,

            body: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  _buildAppBar(
                    context,
                    isDarkMode,
                  ),

                  Expanded(
                    child: _buildBody(
                      isDarkMode,
                    ),
                  ),
                ],
              ),
            ),

            bottomNavigationBar:
            _buildBottomNavigationBar(
              isDarkMode,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  Widget _buildAppBar(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkHeader
            : headerGreen,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
              colorFilter: isDarkMode
                  ? const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'Weekly Report',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          GestureDetector(
            onTap: _downloadReport,
            child: Icon(
              Icons.file_download_outlined,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
          strokeWidth: 3,
        ),
      );
    }

    if (_error != null) {
      return _buildError(isDarkMode);
    }

    if (_report == null) {
      return Center(
        child: Text(
          'No weekly report available.',
          style: TextStyle(
            color: isDarkMode
                ? darkSecondaryText
                : greyText,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final report = _report!;

    return RefreshIndicator(
      color: primaryGreen,
      backgroundColor: isDarkMode
          ? darkCard
          : Colors.white,
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          4,
          4,
          4,
          15,
        ),
        child: Column(
          children: [
            _buildWeekSelector(
              isDarkMode,
            ),

            const SizedBox(height: 2),

            _buildWeekOverview(
              report,
              isDarkMode,
            ),

            const SizedBox(height: 9),

            _buildSummaryCards(
              report,
              isDarkMode,
            ),

            const SizedBox(height: 9),

            _buildWeeklyProgress(
              report,
              isDarkMode,
            ),

            const SizedBox(height: 7),

            _buildTipCard(
              report,
              isDarkMode,
            ),

            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WEEK SELECTOR
  // ============================================================

  Widget _buildWeekSelector(
      bool isDarkMode,
      ) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: GestureDetector(
              onTap: () => _changeWeek(-1),
              child: Center(
                child: Text(
                  '<',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: _selectDate,
              child: Center(
                child: Text(
                  _formatWeekRange(),
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            width: 54,
            child: GestureDetector(
              onTap: () => _changeWeek(1),
              child: Center(
                child: Text(
                  '>',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEK OVERVIEW
  // ============================================================

  Widget _buildWeekOverview(
      WeeklyReport report,
      bool isDarkMode,
      ) {
    final weekStart =
    _getWeekStart(_selectedDate);

    const names = [
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
      'SUN',
    ];

    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkCard
            : Colors.white,
        borderRadius:
        BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? 0.25 : 0.035,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 157,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: const Text(
                  'Week Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 6,
            right: 6,
            top: 31,
            bottom: 7,
            child: Row(
              children: List.generate(
                7,
                    (index) {
                  final date =
                  weekStart.add(
                    Duration(days: index),
                  );

                  DailyReport? daily;

                  if (index <
                      report.days.length) {
                    daily =
                    report.days[index];
                  }

                  return Expanded(
                    child: _dayItem(
                      name: names[index],
                      date: date,
                      daily: daily,
                      isDarkMode: isDarkMode,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayItem({
    required String name,
    required DateTime date,
    required DailyReport? daily,
    required bool isDarkMode,
  }) {
    final dietDone =
        daily?.dietFollowed ?? false;

    final workoutDone =
        daily?.workoutCompleted ?? false;

    final textColor = isDarkMode
        ? Colors.white
        : darkText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          '${date.day}',
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),

        const SizedBox(height: 3),

        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 14,
              color: dietDone
                  ? textColor
                  : Colors.grey.shade500,
            ),

            const SizedBox(width: 2),

            Icon(
              Icons.fitness_center,
              size: 14,
              color: workoutDone
                  ? textColor
                  : Colors.grey.shade500,
            ),
          ],
        ),

        const SizedBox(height: 2),

        _tinyColorMark(
          active:
          dietDone || workoutDone,
        ),
      ],
    );
  }

  Widget _tinyColorMark({
    required bool active,
  }) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _TinyMarkPainter(
          active: active,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards(
      WeeklyReport report,
      bool isDarkMode,
      ) {
    return Column(
      children: [
        _buildDietCard(
          report,
          isDarkMode,
        ),

        const SizedBox(height: 8),

        _buildWorkoutCard(
          report,
          isDarkMode,
        ),
      ],
    );
  }

  // ============================================================
  // DIET CARD
  // ============================================================

  Widget _buildDietCard(
      WeeklyReport report,
      bool isDarkMode,
      ) {
    final percentage = report.dietPercentage
        .toDouble()
        .clamp(0.0, 100.0);

    return Container(
      width: double.infinity,
      height: 350,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkCard
            : Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? 0.25 : 0.08,
            ),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryHeader(
            icon: Icons.restaurant,
            title: 'Diet Summary',
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 7),

          _progressMetric(
            title: 'Diet Plan Followed',
            value:
            '${report.dietFollowedDays}/7 days',
            percentage: percentage,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 6),

          _healthyChoices(
            report.healthyChoices.round(),
            isDarkMode,
          ),

          const SizedBox(height: 8),

          _averageCalories(
            report.averageCalories,
            report.dailyCalories,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORKOUT CARD
  // ============================================================

  Widget _buildWorkoutCard(
      WeeklyReport report,
      bool isDarkMode,
      ) {
    final percentage =
    report.workoutPercentage
        .toDouble()
        .clamp(0.0, 100.0);

    return Container(
      width: double.infinity,
      height: 350,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkCard
            : Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? 0.25 : 0.08,
            ),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryHeader(
            icon: Icons.fitness_center,
            title: 'Workout Summary',
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 6),

          _progressMetric(
            title: 'Workouts Completed',
            value:
            '${report.workoutCompletedDays}/7 days',
            percentage: percentage,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: _workoutStat(
                  'Total workout',
                  report.workoutCompletedDays
                      .toString()
                      .padLeft(2, '0'),
                  isDarkMode,
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: _workoutStat(
                  'Total Duration',
                  '${report.totalDuration}min',
                  isDarkMode,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Expanded(
                child: _workoutStat(
                  'Total calories',
                  '${report.totalCalories}',
                  isDarkMode,
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: _workoutStat(
                  'Avg. Intensity',
                  report.intensityText,
                  isDarkMode,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 130,
            width: double.infinity,
            child: _workoutChart(report),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY HEADER
  // ============================================================

  Widget _summaryHeader({
    required IconData icon,
    required String title,
    required bool isDarkMode,
  }) {
    return Container(
      height: 34,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF136319),
        borderRadius:
        BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration:
            const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: darkGreen,
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _progressMetric({
    required String title,
    required String value,
    required double percentage,
    required bool isDarkMode,
  }) {
    final safe =
    percentage.clamp(0.0, 100.0);

    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(
        8,
        5,
        5,
        5,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkCardLight
            : const Color(0xFFF3F7F3),
        borderRadius:
        BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : darkText,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    color: isDarkMode
                        ? darkSecondaryText
                        : darkText,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 3),

          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: safe / 100,
                  strokeWidth: 4.5,
                  backgroundColor:
                  isDarkMode
                      ? const Color(0xFF39423B)
                      : const Color(
                    0xFFDCE3DC,
                  ),
                  valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                    primaryGreen,
                  ),
                ),

                Text(
                  '${safe.round()}%',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : darkGreen,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTHY CHOICES
  // ============================================================

  Widget _healthyChoices(
      int percentage,
      bool isDarkMode,
      ) {
    final safe =
    percentage.clamp(0, 100).toDouble();

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkCardLight
            : Colors.white,
        borderRadius:
        BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Healthy Choices',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : darkText,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const Spacer(),

              Text(
                '$percentage%',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : darkText,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: safe / 100,
              minHeight: 5,
              backgroundColor:
              isDarkMode
                  ? const Color(0xFF39423B)
                  : const Color(0xFFE1E6E1),
              valueColor:
              const AlwaysStoppedAnimation<
                  Color>(
                primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORKOUT STAT
  // ============================================================

  Widget _workoutStat(
      String title,
      String value,
      bool isDarkMode,
      ) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkCardLight
            : const Color(0xFFF3F7F3),
        borderRadius:
        BorderRadius.circular(9),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode
                  ? darkSecondaryText
                  : greyText,
              fontSize: 8,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white
                  : darkText,
              fontSize: 10,
              fontWeight:
              FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVERAGE CALORIES
  // ============================================================

  Widget _averageCalories(
      int averageCalories,
      List<double> dailyCalories,
      bool isDarkMode,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 2,
        right: 2,
        top: 1,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Average Calories',
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white
                  : darkText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Row(
            children: [
              Text(
                '$averageCalories',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : darkText,
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(width: 2),

              Text(
                'kcal/day',
                style: TextStyle(
                  color: isDarkMode
                      ? darkSecondaryText
                      : greyText,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(width: 2),

              const Text(
                '🔥',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          SizedBox(
            height: 125,
            width: double.infinity,
            child: CustomPaint(
              painter: _CaloriesChartPainter(
                values: dailyCalories,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORKOUT CHART
  // ============================================================

  Widget _workoutChart(
      WeeklyReport report,
      ) {
    final List<double> values = [];

    for (final day in report.days) {
      values.add(
        day.workoutDuration.toDouble(),
      );
    }

    while (values.length < 7) {
      values.add(0.0);
    }

    if (values.length > 7) {
      values.removeRange(
        7,
        values.length,
      );
    }

    return CustomPaint(
      painter: _WorkoutChartPainter(
        values: values,
      ),
      child: const SizedBox.expand(),
    );
  }

  // ============================================================
  // WEEKLY PROGRESS
  // ============================================================

  Widget _buildWeeklyProgress(
      WeeklyReport report,
      bool isDarkMode,
      ) {
    final progress =
        report.progressComparedToLastWeek;

    final positive = progress >= 0;

    return Container(
      width: double.infinity,
      height: 75,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkCard
            : Colors.white,
        borderRadius:
        BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? .25 : .06,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CustomPaint(
              painter:
              _ProgressIconPainter(
                positive: positive,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Progress',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : darkText,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  positive
                      ? 'You improved +$progress% Compared to last week'
                      : 'Your activity was lower than last week',
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDarkMode
                        ? darkSecondaryText
                        : darkText,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIP
  // ============================================================

  Widget _buildTipCard(
      WeeklyReport report,
      bool isDarkMode,
      ) {
    return Container(
      width: double.infinity,
      constraints:
      const BoxConstraints(
        minHeight: 85,
      ),
      padding: const EdgeInsets.fromLTRB(
        11,
        9,
        10,
        9,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? darkCard
            : Colors.white,
        borderRadius:
        BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? .25 : .06,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 31,
            height: 31,
            child: CustomPaint(
              painter: _TipIconPainter(),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Week',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : darkText,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  report.tipOfWeek,
                  maxLines: 3,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDarkMode
                        ? darkSecondaryText
                        : darkText,
                    fontSize: 10,
                    height: 1.35,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar(
      bool isDarkMode,
      ) {
    return SafeArea(
      top: false,
      child: Container(
        height: 69,
        decoration: BoxDecoration(
          color: isDarkMode
              ? darkCard
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDarkMode ? .3 : .09,
              ),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            _bottomItem(
              icon: Icons.home_outlined,
              activeIcon:
              Icons.home_rounded,
              label: 'Home',
              active: true,
              isDarkMode: isDarkMode,
            ),

            _bottomItem(
              icon:
              Icons.calendar_today_outlined,
              activeIcon:
              Icons.calendar_today_rounded,
              label: 'Daily Routine',
              active: false,
              isDarkMode: isDarkMode,
            ),

            _bottomItem(
              icon:
              Icons.person_outline_rounded,
              activeIcon:
              Icons.person_rounded,
              label: 'Profile',
              active: false,
              isDarkMode: isDarkMode,
            ),

            _bottomItem(
              icon:
              Icons.settings_outlined,
              activeIcon:
              Icons.settings_rounded,
              label: 'Settings',
              active: false,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool active,
    required bool isDarkMode,
  }) {
    final Color color = active
        ? primaryGreen
        : isDarkMode
        ? const Color(0xFFB8C0B9)
        : const Color(0xFF667068);

    return Expanded(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            active ? activeIcon : icon,
            size: 20,
            color: color,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: active
                  ? FontWeight.w800
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      bool isDarkMode,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration:
              BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF351F1F)
                    : const Color(0xFFFFEEEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 34,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Unable to load weekly report',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white
                    : darkText,
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode
                    ? darkSecondaryText
                    : greyText,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 43,
              child: ElevatedButton(
                onPressed: _loadReport,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryGreen,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TINY ACTIVITY MARK
// ============================================================================

class _TinyMarkPainter extends CustomPainter {
  final bool active;

  _TinyMarkPainter({
    required this.active,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint greenPaint = Paint()
      ..color = active
          ? const Color(0xFF20C55A)
          : Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final Paint yellowPaint = Paint()
      ..color = active
          ? const Color(0xFFFFC107)
          : Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final Paint bluePaint = Paint()
      ..color = active
          ? const Color(0xFF42A5F5)
          : Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      4.5,
      greenPaint,
    );

    canvas.drawLine(
      Offset(cx - 6, cy + 5),
      Offset(cx - 1, cy + 1),
      yellowPaint,
    );

    canvas.drawLine(
      Offset(cx + 1, cy + 1),
      Offset(cx + 6, cy + 5),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _TinyMarkPainter oldDelegate,
      ) {
    return oldDelegate.active != active;
  }
}

// ============================================================================
// CALORIES CHART
// ============================================================================

class _CaloriesChartPainter
    extends CustomPainter {
  final List<double> values;

  _CaloriesChartPainter({
    required this.values,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final double left = 18;
    final double right = size.width - 3;
    final double top = 5;
    final double bottom = size.height - 13;

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE7EBE7)
      ..strokeWidth = 0.7;

    for (int i = 0; i < 4; i++) {
      final double y =
          top + ((bottom - top) / 3) * i;

      canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        gridPaint,
      );
    }

    final List<double> chartValues =
    List<double>.from(values);

    while (chartValues.length < 7) {
      chartValues.add(0);
    }

    if (chartValues.length > 7) {
      chartValues.removeRange(
        7,
        chartValues.length,
      );
    }

    final nonZeroValues = chartValues
        .where((value) => value > 0)
        .toList();

    if (nonZeroValues.isEmpty) {
      _drawLabels(
        canvas,
        size,
        left,
        right,
        bottom,
      );

      return;
    }

    double minValue =
        nonZeroValues.first;

    double maxValue =
        nonZeroValues.first;

    for (final value in nonZeroValues) {
      if (value < minValue) {
        minValue = value;
      }

      if (value > maxValue) {
        maxValue = value;
      }
    }

    final double range =
    (maxValue - minValue).abs();

    if (range < 100) {
      minValue -= 100;
      maxValue += 100;
    } else {
      minValue -= range * 0.15;
      maxValue += range * 0.15;
    }

    final List<Offset> points = [];

    for (int i = 0; i < 7; i++) {
      final double x =
          left + ((right - left) / 6) * i;

      final double value =
      chartValues[i];

      double normalized = 0;

      if (value > 0) {
        normalized =
            (value - minValue) /
                (maxValue - minValue);
      }

      normalized =
          normalized.clamp(0.0, 1.0);

      final double y =
          bottom -
              normalized *
                  (bottom - top);

      points.add(
        Offset(x, y),
      );
    }

    final Paint linePaint = Paint()
      ..color = const Color(0xFF48BE69)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path();

    bool started = false;

    for (int i = 0;
    i < points.length;
    i++) {
      if (chartValues[i] <= 0) {
        continue;
      }

      if (!started) {
        path.moveTo(
          points[i].dx,
          points[i].dy,
        );

        started = true;
      } else {
        path.lineTo(
          points[i].dx,
          points[i].dy,
        );
      }
    }

    if (started) {
      canvas.drawPath(
        path,
        linePaint,
      );
    }

    final Paint dotPaint = Paint()
      ..color = const Color(0xFF48BE69);

    for (int i = 0;
    i < points.length;
    i++) {
      if (chartValues[i] <= 0) {
        continue;
      }

      canvas.drawCircle(
        points[i],
        1.8,
        dotPaint,
      );
    }

    _drawLabels(
      canvas,
      size,
      left,
      right,
      bottom,
    );
  }

  void _drawLabels(
      Canvas canvas,
      Size size,
      double left,
      double right,
      double bottom,
      ) {
    const List<String> labels = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    const TextStyle style = TextStyle(
      color: Color(0xFF929A93),
      fontSize: 7,
    );

    for (int i = 0;
    i < labels.length;
    i++) {
      final double x =
          left + ((right - left) / 6) * i;

      final TextPainter painter =
      TextPainter(
        text: TextSpan(
          text: labels[i],
          style: style,
        ),
        textDirection:
        TextDirection.ltr,
      );

      painter.layout();

      painter.paint(
        canvas,
        Offset(
          x - painter.width / 2,
          bottom + 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _CaloriesChartPainter oldDelegate,
      ) {
    return oldDelegate.values.toString() !=
        values.toString();
  }
}

// ============================================================================
// WORKOUT CHART
// ============================================================================

class _WorkoutChartPainter
    extends CustomPainter {
  final List<double> values;

  _WorkoutChartPainter({
    required this.values,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final double left = 7;
    final double right = size.width - 3;
    final double top = 4;
    final double bottom = size.height - 13;

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE8ECE8)
      ..strokeWidth = 0.7;

    for (int i = 0; i < 3; i++) {
      final double y =
          top + ((bottom - top) / 2) * i;

      canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        gridPaint,
      );
    }

    double maxValue = 0;

    for (final double value in values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 0) {
      maxValue = 10;
    }

    maxValue *= 1.15;

    const List<String> labels = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    const TextStyle labelStyle =
    TextStyle(
      color: Color(0xFF8C958D),
      fontSize: 5.5,
    );

    for (int i = 0; i < 7; i++) {
      final double centerX =
          left +
              ((right - left) / 6) * i;

      final double value =
      i < values.length
          ? values[i]
          : 0;

      double barHeight = 3;

      if (value > 0) {
        barHeight =
            (value / maxValue) *
                (bottom - top);

        if (barHeight < 3) {
          barHeight = 3;
        }

        if (barHeight >
            bottom - top) {
          barHeight =
              bottom - top;
        }
      }

      double barWidth =
          size.width / 12;

      if (barWidth < 5) {
        barWidth = 5;
      }

      final Rect rect =
      Rect.fromLTWH(
        centerX - barWidth / 2,
        bottom - barHeight,
        barWidth,
        barHeight,
      );

      final Paint barPaint = Paint()
        ..color = value > 0
            ? (i == 6
            ? const Color(
          0xFF20A84F,
        )
            : const Color(
          0xFFB8E8C4,
        ))
            : const Color(
          0xFFE3E8E3,
        );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(3),
        ),
        barPaint,
      );

      final TextPainter painter =
      TextPainter(
        text: TextSpan(
          text: labels[i],
          style: labelStyle,
        ),
        textDirection:
        TextDirection.ltr,
      );

      painter.layout();

      painter.paint(
        canvas,
        Offset(
          centerX -
              painter.width / 2,
          bottom + 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _WorkoutChartPainter oldDelegate,
      ) {
    return true;
  }
}

// ============================================================================
// WEEKLY PROGRESS ICON
// ============================================================================

class _ProgressIconPainter
    extends CustomPainter {
  final bool positive;

  _ProgressIconPainter({
    required this.positive,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final Paint background = Paint()
      ..color = const Color(0xFFFFF4E5);

    canvas.drawCircle(
      center,
      size.width / 2,
      background,
    );

    final Paint green = Paint()
      ..color = const Color(0xFF20B85A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path()
      ..moveTo(8, 26)
      ..lineTo(15, 19)
      ..lineTo(20, 21)
      ..lineTo(29, 10)
      ..moveTo(24, 10)
      ..lineTo(29, 10)
      ..lineTo(29, 15);

    canvas.drawPath(
      path,
      green,
    );

    final Paint orange = Paint()
      ..color = const Color(0xFFFFA726)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(11, 28),
      const Offset(11, 19),
      orange,
    );

    canvas.drawLine(
      const Offset(17, 28),
      const Offset(17, 15),
      orange,
    );

    canvas.drawLine(
      const Offset(23, 28),
      const Offset(23, 12),
      orange,
    );
  }

  @override
  bool shouldRepaint(
      covariant _ProgressIconPainter oldDelegate,
      ) {
    return oldDelegate.positive !=
        positive;
  }
}

// ============================================================================
// TIP ICON
// ============================================================================

class _TipIconPainter
    extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint orange = Paint()
      ..color =
      const Color(0xFFFFA726);

    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    canvas.drawCircle(
      center,
      11,
      orange,
    );

    final Paint white = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(
        center.dx,
        7,
      ),
      Offset(
        center.dx,
        21,
      ),
      white,
    );

    canvas.drawLine(
      Offset(
        7,
        center.dy,
      ),
      Offset(
        21,
        center.dy,
      ),
      white,
    );

    canvas.drawCircle(
      center,
      3,
      white,
    );
  }

  @override
  bool shouldRepaint(
      covariant _TipIconPainter oldDelegate,
      ) {
    return false;
  }
}