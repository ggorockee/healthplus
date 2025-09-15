import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';

/// 구독 관리 화면
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '구독 관리',
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
            // 현재 구독 상태 카드
            _buildCurrentSubscriptionCard(context, ref, subscription),
            
            const SizedBox(height: 24),
            
            // 구독 혜택 섹션
            _buildSubscriptionBenefitsSection(),
            
            const SizedBox(height: 24),
            
            // 구독 플랜 섹션
            _buildSubscriptionPlansSection(context, ref),
            
            const SizedBox(height: 24),
            
            // FAQ 섹션
            _buildFAQSection(),
          ],
        ),
      ),
    );
  }

  /// 현재 구독 상태 카드
  Widget _buildCurrentSubscriptionCard(BuildContext context, WidgetRef ref, SubscriptionInfo subscription) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSubscriptionIcon(subscription.status),
                color: _getSubscriptionColor(subscription.status),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.status.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subscription.status.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (subscription.expiryDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '만료일: ${_formatDate(subscription.expiryDate!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (subscription.status == SubscriptionStatus.free) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showUpgradeDialog(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '프리미엄으로 업그레이드',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 구독 혜택 섹션
  Widget _buildSubscriptionBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '프리미엄 혜택',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildBenefitItem(
          icon: Icons.block,
          title: '광고 제거',
          description: '모든 광고를 제거하고 깔끔한 사용 경험',
        ),
        _buildBenefitItem(
          icon: Icons.analytics,
          title: '상세 통계',
          description: '복용 패턴 분석 및 건강 리포트',
        ),
        _buildBenefitItem(
          icon: Icons.cloud_sync,
          title: '클라우드 백업',
          description: '데이터 자동 백업 및 복원',
        ),
        _buildBenefitItem(
          icon: Icons.priority_high,
          title: '우선 지원',
          description: '24시간 내 고객 지원 응답',
        ),
      ],
    );
  }

  /// 구독 플랜 섹션
  Widget _buildSubscriptionPlansSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '구독 플랜',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // 월간 구독
        _buildPlanCard(
          context: context,
          ref: ref,
          title: '월간 구독',
          price: '₩4,900',
          period: '/월',
          features: ['광고 제거', '상세 통계', '클라우드 백업'],
          onTap: () => _startSubscription(context, ref, 30, '월간'),
        ),
        
        const SizedBox(height: 12),
        
        // 연간 구독 (인기)
        _buildPlanCard(
          context: context,
          ref: ref,
          title: '연간 구독',
          price: '₩39,900',
          period: '/년',
          features: ['광고 제거', '상세 통계', '클라우드 백업', '우선 지원'],
          isPopular: true,
          onTap: () => _startSubscription(context, ref, 365, '연간'),
        ),
      ],
    );
  }

  /// FAQ 섹션
  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '자주 묻는 질문',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildFAQItem(
          question: '구독을 취소할 수 있나요?',
          answer: '언제든지 구독을 취소할 수 있습니다. 취소 후에도 구독 기간이 끝날 때까지 모든 혜택을 이용하실 수 있습니다.',
        ),
        _buildFAQItem(
          question: '환불이 가능한가요?',
          answer: '구독 후 7일 이내에는 전액 환불이 가능합니다. 그 이후에는 남은 기간에 대한 비례 환불이 가능합니다.',
        ),
        _buildFAQItem(
          question: '데이터는 안전한가요?',
          answer: '모든 데이터는 암호화되어 안전하게 저장되며, 개인정보는 제3자와 공유되지 않습니다.',
        ),
      ],
    );
  }

  /// 혜택 아이템
  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 플랜 카드
  Widget _buildPlanCard({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required VoidCallback onTap,
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPopular ? Border.all(color: const Color(0xFF4CAF50), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '인기',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? const Color(0xFF4CAF50) : Colors.grey[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isPopular ? '인기 플랜 선택' : '플랜 선택',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FAQ 아이템
  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 구독 아이콘 가져오기
  IconData _getSubscriptionIcon(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return Icons.person;
      case SubscriptionStatus.premium:
        return Icons.star;
      case SubscriptionStatus.trial:
        return Icons.schedule;
    }
  }

  /// 구독 색상 가져오기
  Color _getSubscriptionColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return Colors.grey;
      case SubscriptionStatus.premium:
        return const Color(0xFF4CAF50);
      case SubscriptionStatus.trial:
        return Colors.orange;
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 업그레이드 다이얼로그 표시
  void _showUpgradeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리미엄 업그레이드'),
        content: const Text('프리미엄 구독을 시작하시겠습니까?\n\n광고가 제거되고 모든 기능을 이용하실 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startSubscription(context, ref, 30, '월간');
            },
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }

  /// 구독 시작
  void _startSubscription(BuildContext context, WidgetRef ref, int days, String planName) {
    final notifier = ref.read(subscriptionProvider.notifier);
    
    if (planName == '월간') {
      notifier.startPremium(subscriptionDays: days, planName: planName);
    } else {
      notifier.startPremium(subscriptionDays: days, planName: planName);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$planName 구독이 시작되었습니다!'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
