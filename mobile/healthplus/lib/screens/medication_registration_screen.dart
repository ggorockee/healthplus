import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medication_registration_provider.dart';
import '../widgets/medication_registration_widgets.dart';
import '../services/admob_service.dart';

/// 약 등록 화면
class MedicationRegistrationScreen extends ConsumerWidget {
  const MedicationRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isValid = ref.watch(medicationRegistrationValidProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '새 약 추가',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 약품 정보 섹션
            _buildMedicationInfoSection(context, ref),
            
            const SizedBox(height: 24),
            
            // 복용 설정 섹션
            _buildDosageSettingsSection(context, ref),
            
            const SizedBox(height: 24),
            
            // 복용 시간 섹션
            const DosageTimeWidget(),
            
            const SizedBox(height: 24),
            
            // 1회 복용량 섹션
            const DosageAmountWidget(),
            
            const SizedBox(height: 24),
            
            // 추가 옵션 섹션
            const AdditionalOptionsWidget(),
            
            const SizedBox(height: 40),
            
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isValid ? () => _saveMedication(context, ref) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '약 등록하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 약품 정보 섹션
  Widget _buildMedicationInfoSection(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(medicationRegistrationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '약품 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // 약품명 입력
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  '약품명',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => notifier.updateName(value),
              decoration: const InputDecoration(
                hintText: '타이레놀, 게보린 등',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 약 사진 등록
        const MedicationImageUploadWidget(),
      ],
    );
  }

  /// 복용 설정 섹션
  Widget _buildDosageSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '복용 설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // 약 형태 선택
        const MedicationFormSelectorWidget(),
      ],
    );
  }

  /// 약 저장 처리
  Future<void> _saveMedication(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(medicationRegistrationProvider.notifier);
    
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // 약 저장
      final success = await notifier.saveMedication(ref);
      
      // 로딩 닫기
      Navigator.of(context).pop();
      
      if (success) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('약이 성공적으로 등록되었습니다!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        
        // 전면 광고 표시 (약 등록 완료 후) - 임시 비활성화
        // await AdMobService.showInterstitialAd();
        
        // 홈 화면으로 돌아가기
        Navigator.of(context).pop();
      } else {
        // 실패 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('약 등록에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 로딩 닫기
      Navigator.of(context).pop();
      
      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
