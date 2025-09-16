import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/medication.dart';

/// 약물 카드 위젯 (토글 버튼 포함)
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

class _SwipeableMedicationCardState extends State<SwipeableMedicationCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isTaken ? AppColors.tertiaryLight : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: widget.isTaken ? AppColors.tertiary : AppColors.borderLight,
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
              // 토글 버튼과 액션 버튼들
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// 액션 버튼들 (토글 버튼 + 편집/삭제)
  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 토글 버튼
        _buildToggleButton(),
        const SizedBox(width: 12),
        // 편집 버튼
        _buildSmallActionButton(
          icon: Icons.edit,
          color: AppColors.primary,
          onTap: widget.onEdit,
        ),
        const SizedBox(width: 8),
        // 삭제 버튼
        _buildSmallActionButton(
          icon: Icons.delete,
          color: AppColors.error,
          onTap: widget.onDelete,
        ),
      ],
    );
  }

  /// 토글 버튼
  Widget _buildToggleButton() {
    return Container(
      width: 60,
      height: 36,
      decoration: BoxDecoration(
        color: widget.isTaken ? AppColors.tertiary : AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (widget.isTaken ? AppColors.tertiary : AppColors.primary).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onToggleTaken,
          child: Center(
            child: Icon(
              widget.isTaken ? Icons.check : Icons.radio_button_unchecked,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// 작은 액션 버튼
  Widget _buildSmallActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
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
            ? [AppColors.tertiary, AppColors.tertiary.withValues(alpha: 0.8)]
            : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (widget.isTaken ? AppColors.tertiary : AppColors.primary).withValues(alpha: 0.3),
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
            color: widget.isTaken ? AppColors.textSecondary : AppColors.textPrimary,
            decoration: widget.isTaken ? TextDecoration.lineThrough : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '복용량: ${widget.medication.dosage}',
          style: TextStyle(
            fontSize: 14,
            color: widget.isTaken ? AppColors.textSecondary : AppColors.textSecondary,
            decoration: widget.isTaken ? TextDecoration.lineThrough : null,
          ),
        ),
        Text(
          '시간: ${widget.medication.notificationTime.format(context)}',
          style: TextStyle(
            fontSize: 14,
            color: widget.isTaken ? AppColors.textSecondary : AppColors.textSecondary,
            decoration: widget.isTaken ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

}
