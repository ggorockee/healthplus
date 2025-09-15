import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_registration_model.dart';
import '../providers/medication_registration_provider.dart';

/// 약 사진 등록 위젯
class MedicationImageUploadWidget extends ConsumerWidget {
  const MedicationImageUploadWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(medicationRegistrationProvider);
    final notifier = ref.read(medicationRegistrationProvider.notifier);

    return GestureDetector(
      onTap: () {
        // 이미지 선택 다이얼로그
        _showImageSourceDialog(context, notifier);
      },
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: registration.imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  registration.imagePath!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '약 사진 등록하기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, MedicationRegistrationNotifier notifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                // 카메라 기능 구현
                notifier.updateImagePath('assets/images/sample_medication.jpg');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                // 갤러리 기능 구현
                notifier.updateImagePath('assets/images/sample_medication.jpg');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 약 형태 선택 위젯
class MedicationFormSelectorWidget extends ConsumerWidget {
  const MedicationFormSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(medicationRegistrationProvider);
    final notifier = ref.read(medicationRegistrationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '약 형태',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: MedicationForm.values.map((form) {
            final isSelected = registration.form == form;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => notifier.updateForm(form),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getFormIcon(form),
                          color: isSelected ? Colors.white : const Color(0xFF4CAF50),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          form.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getFormIcon(MedicationForm form) {
    switch (form) {
      case MedicationForm.tablet:
        return Icons.medication;
      case MedicationForm.capsule:
        return Icons.medication_liquid;
      case MedicationForm.syrup:
        return Icons.local_drink;
      case MedicationForm.other:
        return Icons.help_outline;
    }
  }
}

/// 복용 시간 설정 위젯
class DosageTimeWidget extends ConsumerWidget {
  const DosageTimeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(medicationRegistrationProvider);
    final notifier = ref.read(medicationRegistrationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '복용 시간',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 하루 복용 횟수
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '하루 복용 횟수',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${registration.dailyDosageCount}회',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 복용 시간 목록
        ...registration.dosageTimes.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, ref, index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                if (registration.dosageTimes.length > 1)
                  IconButton(
                    onPressed: () => notifier.removeDosageTime(index),
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  ),
              ],
            ),
          );
        }).toList(),
        // 시간 추가 버튼
        TextButton.icon(
          onPressed: () => _selectTime(context, ref, -1),
          icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
          label: const Text(
            '시간 추가',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, WidgetRef ref, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      
      if (index == -1) {
        // 새 시간 추가
        ref.read(medicationRegistrationProvider.notifier).addDosageTime(timeString);
      } else {
        // 기존 시간 수정
        ref.read(medicationRegistrationProvider.notifier).updateDosageTime(index, timeString);
      }
    }
  }
}

/// 복용량 설정 위젯
class DosageAmountWidget extends ConsumerWidget {
  const DosageAmountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(medicationRegistrationProvider);
    final notifier = ref.read(medicationRegistrationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1회 복용량',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 수량 조절
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (registration.singleDosageAmount > 1) {
                          notifier.updateSingleDosageAmount(registration.singleDosageAmount - 1);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: registration.singleDosageAmount > 1 ? Colors.grey.shade200 : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Text(
                      '${registration.singleDosageAmount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        notifier.updateSingleDosageAmount(registration.singleDosageAmount + 1);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 단위 선택
            Expanded(
              child: GestureDetector(
                onTap: () => _showUnitDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        registration.dosageUnit.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showUnitDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DosageUnit.values.map((unit) {
            return ListTile(
              title: Text(unit.displayName),
              subtitle: Text(unit.description),
              onTap: () {
                ref.read(medicationRegistrationProvider.notifier).updateDosageUnit(unit);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 추가 옵션 위젯
class AdditionalOptionsWidget extends ConsumerWidget {
  const AdditionalOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(medicationRegistrationProvider);
    final notifier = ref.read(medicationRegistrationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '추가 옵션',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // 식사와의 관계
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '식사와의 관계',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: MealRelation.values.map((relation) {
                      final isSelected = registration.mealRelation == relation;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => notifier.updateMealRelation(relation),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                relation.displayName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch(
              value: registration.hasMealRelation,
              onChanged: (value) => notifier.toggleMealRelation(),
              activeColor: const Color(0xFF4CAF50),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 지속 복용
        Row(
          children: [
            const Expanded(
              child: Text(
                '지속 복용',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            Switch(
              value: registration.isContinuous,
              onChanged: (value) => notifier.toggleContinuous(),
              activeColor: const Color(0xFF4CAF50),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 메모
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '메모',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => notifier.updateMemo(value.isEmpty ? null : value),
              decoration: const InputDecoration(
                hintText: '메모를 입력하세요',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ],
    );
  }
}
