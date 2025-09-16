import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/medication.dart';

/// 스와이프 가능한 약물 카드 위젯
class SwipeableMedicationCard extends StatefulWidget {
  final Medication medication;
  final bool isTaken;
  final VoidCallback onToggleTaken;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SwipeableMedicationCard({
    super.key,
    required this.medication,
    required this.isTaken,
    required this.onToggleTaken,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<SwipeableMedicationCard> createState() => _SwipeableMedicationCardState();
}

class _SwipeableMedicationCardState extends State<SwipeableMedicationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Stack(
        children: [
          // 배경 액션 버튼들
          _buildBackgroundActions(),
          // 메인 카드
          _buildMainCard(),
        ],
      ),
    );
  }

  /// 배경 액션 버튼들
  Widget _buildBackgroundActions() {
    return Positioned.fill(
      child: Row(
        children: [
          // 복용 체크 버튼
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isTaken 
                    ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
                    : [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.onToggleTaken,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isTaken ? Icons.undo : Icons.check_circle,
                          color: AppColors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isTaken ? '취소' : '복용',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 편집 버튼
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.onEdit,
                  child: const Center(
                    child: Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 삭제 버튼
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.onDelete,
                  child: const Center(
                    child: Icon(
                      Icons.delete,
                      color: AppColors.white,
                      size: 24,
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

  /// 메인 카드
  Widget _buildMainCard() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_dragOffset + _slideAnimation.value, 0),
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              decoration: BoxDecoration(
                color: widget.isTaken ? AppColors.accentLight : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: widget.isTaken ? AppColors.accent : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 약물 아이콘
                    _buildMedicationIcon(),
                    const SizedBox(width: 16),
                    // 약물 정보
                    Expanded(child: _buildMedicationInfo()),
                    // 상태 표시
                    _buildStatusIndicator(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 약물 아이콘
  Widget _buildMedicationIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isTaken 
            ? [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)]
            : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (widget.isTaken ? AppColors.accent : AppColors.primary).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.isTaken ? Icons.check_circle : Icons.medication,
        color: AppColors.white,
        size: 24,
      ),
    );
  }

  /// 약물 정보
  Widget _buildMedicationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.medication.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '복용량: ${widget.medication.dosage}',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '시간: ${widget.medication.notificationTime.format(context)}',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 상태 표시
  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isTaken ? AppColors.accent : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.isTaken ? '완료' : '대기',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: widget.isTaken ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _animationController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _dragOffset += details.delta.dx;
        // 최대 드래그 거리 제한
        _dragOffset = _dragOffset.clamp(-200.0, 0.0);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    
    // 드래그 거리에 따라 액션 결정
    if (_dragOffset < -100) {
      // 충분히 드래그했으면 복용 체크
      widget.onToggleTaken();
      _resetPosition();
    } else {
      // 원래 위치로 돌아가기
      _resetPosition();
    }
  }

  void _resetPosition() {
    _slideAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward(from: 0);
    _dragOffset = 0.0;
  }
}
