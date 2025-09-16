import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../widgets/app_text.dart';
import '../widgets/app_card.dart';

/// 통계 화면 - 복용률 및 리포트
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedPeriod = 'week'; // 'week', 'month'
  
  // 모의데이터
  final List<Map<String, dynamic>> _mockWeeklyData = [
    {'day': '월', 'taken': 8, 'missed': 2, 'total': 10},
    {'day': '화', 'taken': 9, 'missed': 1, 'total': 10},
    {'day': '수', 'taken': 7, 'missed': 3, 'total': 10},
    {'day': '목', 'taken': 10, 'missed': 0, 'total': 10},
    {'day': '금', 'taken': 8, 'missed': 2, 'total': 10},
    {'day': '토', 'taken': 6, 'missed': 4, 'total': 10},
    {'day': '일', 'taken': 9, 'missed': 1, 'total': 10},
  ];
  
  final List<Map<String, dynamic>> _mockMonthlyData = [
    {'week': '1주차', 'adherence': 85.0},
    {'week': '2주차', 'adherence': 92.0},
    {'week': '3주차', 'adherence': 78.0},
    {'week': '4주차', 'adherence': 88.0},
  ];
  
  final List<Map<String, dynamic>> _mockMedicationStats = [
    {'name': '아스피린', 'adherence': 95.0, 'totalDoses': 28, 'missedDoses': 2},
    {'name': '비타민D', 'adherence': 88.0, 'totalDoses': 30, 'missedDoses': 4},
    {'name': '오메가3', 'adherence': 92.0, 'totalDoses': 30, 'missedDoses': 2},
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: _buildWeeklyCalendar(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기간 선택 탭
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            
            // 주요 지표 카드들
            _buildKeyMetricsCards(),
            const SizedBox(height: 20),
            
            // 복용률 추이 차트
            _buildAdherenceTrendChart(),
            const SizedBox(height: 20),
            
            // 일별 복용 현황 차트
            _buildDailyAdherenceChart(),
            const SizedBox(height: 20),
            
            // 약물별 상세 통계
            _buildMedicationDetailedStats(),
            const SizedBox(height: 20),
            
            // 복용 패턴 분석
            _buildAdherencePatternAnalysis(),
            const SizedBox(height: 20),
            
            // 인사이트 카드
            _buildInsightsCard(),
          ],
        ),
      ),
    );
  }

  /// 주간 달력 빌드
  Widget _buildWeeklyCalendar() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
          
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 요일 약어
                Text(
                  weekdays[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isToday ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                // 날짜
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isToday ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// 기간 선택 탭
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = 'week'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedPeriod == 'week' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '1주일',
                    style: TextStyle(
                      color: _selectedPeriod == 'week' ? AppColors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = 'month'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedPeriod == 'month' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '1개월',
                    style: TextStyle(
                      color: _selectedPeriod == 'month' ? AppColors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 주요 지표 카드들
  Widget _buildKeyMetricsCards() {
    final data = _selectedPeriod == 'week' ? _mockWeeklyData : _mockMonthlyData;
    final totalTaken = data.fold<int>(0, (sum, item) => sum + ((item['taken'] ?? item['adherence']) as num).toInt());
    final totalMissed = data.fold<int>(0, (sum, item) => sum + ((item['missed'] ?? 0) as num).toInt());
    final adherenceRate = totalTaken / (totalTaken + totalMissed) * 100;
    
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            '전체 복용률',
            '${adherenceRate.toStringAsFixed(1)}%',
            Icons.trending_up,
            adherenceRate >= 80 ? AppColors.success : adherenceRate >= 60 ? AppColors.warning : AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            '복용 횟수',
            '$totalTaken회',
            Icons.medication,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            '미복용 횟수',
            '$totalMissed회',
            Icons.warning,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  /// 개별 지표 카드
  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 복용률 추이 차트
  Widget _buildAdherenceTrendChart() {
    final data = _selectedPeriod == 'week' ? _mockWeeklyData : _mockMonthlyData;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleMedium('복용률 추이'),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderLight,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.borderLight,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%', 
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary, // 더 진한 색상으로 변경
                            fontFamily: AppTypography.fontFamily,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Text(
                            data[index]['day'] ?? data[index]['week'], 
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary, // 더 진한 색상으로 변경
                              fontFamily: AppTypography.fontFamily,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final index = barSpot.x.toInt();
                        if (index >= 0 && index < data.length) {
                          final day = data[index]['day'] ?? data[index]['week'];
                          final adherence = barSpot.y;
                          return LineTooltipItem(
                            '$day\n${adherence.toStringAsFixed(1)}%',
                            TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white, // 흰색 텍스트로 변경
                              fontFamily: AppTypography.fontFamily,
                              height: 1.3,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      final adherence = _selectedPeriod == 'week' 
                          ? (entry.value['taken'] / entry.value['total'] * 100)
                          : entry.value['adherence'];
                      return FlSpot(entry.key.toDouble(), adherence);
                    }).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 일별 복용 현황 차트
  Widget _buildDailyAdherenceChart() {
    final data = _selectedPeriod == 'week' ? _mockWeeklyData : _mockMonthlyData;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleMedium('일별 복용 현황'),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%', 
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary, // 더 진한 색상으로 변경
                            fontFamily: AppTypography.fontFamily,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Text(
                            data[index]['day'] ?? data[index]['week'], 
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary, // 더 진한 색상으로 변경
                              fontFamily: AppTypography.fontFamily,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final index = group.x.toInt();
                      if (index >= 0 && index < data.length) {
                        final day = data[index]['day'] ?? data[index]['week'];
                        final adherence = rod.toY;
                        final status = adherence >= 80 ? '우수' : adherence >= 60 ? '보통' : '주의';
                        
                        return BarTooltipItem(
                          '$day\n${adherence.toStringAsFixed(1)}% ($status)',
                          TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white, // 흰색 텍스트로 변경
                            fontFamily: AppTypography.fontFamily,
                            height: 1.3,
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                barGroups: data.asMap().entries.map((entry) {
                  final adherence = _selectedPeriod == 'week' 
                      ? (entry.value['taken'] / entry.value['total'] * 100)
                      : entry.value['adherence'];
                  final barColor = adherence >= 80 ? AppColors.success : 
                                 adherence >= 60 ? AppColors.warning : AppColors.error;
                  
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: adherence,
                        color: barColor,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: AppColors.surfaceAlt,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 약물별 상세 통계
  Widget _buildMedicationDetailedStats() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleMedium('약물별 상세 통계'),
          const SizedBox(height: 16),
          ..._mockMedicationStats.map((medication) => _buildMedicationStatItem(medication)),
        ],
      ),
    );
  }

  /// 개별 약물 통계 아이템
  Widget _buildMedicationStatItem(Map<String, dynamic> medication) {
    final adherenceColor = medication['adherence'] >= 90 ? AppColors.success : 
                          medication['adherence'] >= 80 ? AppColors.warning : AppColors.error;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: adherenceColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: adherenceColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: adherenceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: adherenceColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.medication,
              color: adherenceColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '총 ${medication['totalDoses']}회 중 ${medication['missedDoses']}회 미복용',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: adherenceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${medication['adherence']}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: adherenceColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '복용률',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 복용 패턴 분석
  Widget _buildAdherencePatternAnalysis() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleMedium('복용 패턴 분석'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPatternItem('최고 복용률', '100%', '목요일', AppColors.success),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPatternItem('최저 복용률', '60%', '토요일', AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPatternItem('평균 복용률', '85.7%', '전체 기간', AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPatternItem('연속 복용', '3일', '최장 기록', AppColors.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 패턴 분석 아이템
  Widget _buildPatternItem(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), // 투명도 증가로 배경색 강화
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3), // 테두리 추가로 구분감 향상
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color, // 원래 색상 유지하되 배경 대비 개선
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary, // 더 진한 색상으로 변경
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 인사이트 카드
  Widget _buildInsightsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.secondary, size: 24),
              const SizedBox(width: 8),
              AppText.titleMedium('복용 인사이트'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            '🎯 목표 달성',
            '이번 주 복용률이 목표인 80%를 달성했습니다!',
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            '📈 개선 포인트',
            '토요일 복용률이 낮습니다. 주말 알림을 설정해보세요.',
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            '💡 팁',
            '아침 복용률이 가장 높습니다. 다른 시간대도 이 패턴을 따라해보세요.',
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  /// 인사이트 아이템
  Widget _buildInsightItem(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), // 배경색 강화
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.25), // 테두리 추가
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500, // 가독성 향상을 위한 폰트 굵기 증가
              ),
            ),
          ),
        ],
      ),
    );
  }
}
