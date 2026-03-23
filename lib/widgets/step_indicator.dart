import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final isActive = index == currentStep;
            final isDone = index < currentStep;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < steps.length - 1 ? 6 : 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : isDone
                            ? AppColors.gold
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: isActive || isDone
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive || isDone
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.border,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            color: isActive || isDone ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          steps[index],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive || isDone ? Colors.white : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: (currentStep + 1) / steps.length,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

