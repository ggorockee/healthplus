import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_input.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';

/// 약물 추가 화면
class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  final List<int> _selectedDays = []; // 0=일요일, 1=월요일, ...

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: AppText.titleLarge('약 추가하기'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 약 이름 입력
              AppText.bodyLarge('약 이름'),
              const SizedBox(height: 8),
              AppInput(
                hintText: '예: 아스피린, 비타민D',
                controller: _nameController,
              ),
              const SizedBox(height: 24),
              
              // 복용량 입력
              AppText.bodyLarge('복용량'),
              const SizedBox(height: 8),
              AppInput(
                hintText: '예: 1정, 1포, 2알',
                controller: _dosageController,
              ),
              const SizedBox(height: 24),
              
              // 알림 시간 선택
              AppText.bodyLarge('알림 시간'),
              const SizedBox(height: 8),
              _buildTimeSelector(),
              const SizedBox(height: 24),
              
              // 반복 요일 선택
              AppText.bodyLarge('반복 요일'),
              const SizedBox(height: 8),
              _buildDaySelector(),
              const SizedBox(height: 32),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: '저장하기',
                  onPressed: _saveMedication,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 시간 선택 위젯
  Widget _buildTimeSelector() {
    return InkWell(
      onTap: _selectTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            AppText.bodyMedium(_selectedTime.format(context)),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// 요일 선택 위젯
  Widget _buildDaySelector() {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isSelected = _selectedDays.contains(index);
        return GestureDetector(
          onTap: () => _toggleDay(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: AppText.bodyMedium(
                weekdays[index],
                style: TextStyle(
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 시간 선택
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// 요일 토글
  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  /// 약물 저장
  void _saveMedication() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약 이름을 입력해주세요')),
      );
      return;
    }
    
    if (_dosageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('복용량을 입력해주세요')),
      );
      return;
    }

    final medication = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      notificationTime: _selectedTime,
      repeatDays: _selectedDays,
      createdAt: DateTime.now(),
    );

    ref.read(medicationProvider.notifier).addMedication(medication);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('약이 추가되었습니다')),
    );
    
    Navigator.pop(context);
  }
}
