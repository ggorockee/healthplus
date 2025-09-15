import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/medication_history_widgets.dart';

/// 복용 기록 화면
class MedicationHistoryScreen extends ConsumerStatefulWidget {
  const MedicationHistoryScreen({super.key});

  @override
  ConsumerState<MedicationHistoryScreen> createState() => _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState extends ConsumerState<MedicationHistoryScreen> {
  DateTime _selectedDate = DateTime(2025, 9, 15);
  DateTime _currentMonth = DateTime(2025, 9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '복용 기록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 달력 섹션
            const MedicationCalendarWidget(),
            
            const SizedBox(height: 16),
            
            // 일별 상세 섹션
            DailyMedicationDetailWidget(selectedDate: _selectedDate),
            
            const SizedBox(height: 16),
            
            // 월간 통계 섹션
            MonthlyStatisticsWidget(month: _currentMonth),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
