import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

Color getCategoryColor(String category) {
  switch (category) {
    case 'Community':
      return AppColors.primary;
    case 'Government':
      return const Color(0xFF5C7AEA);
    case 'Arts':
      return AppColors.tertiary;
    case 'Sports':
      return AppColors.secondary;
    case 'Health':
      return const Color(0xFFE07A9F);
    case 'Education':
      return const Color(0xFF7A9FE0);
    case 'Emergency':
      return const Color(0xFFE05C5C);
    case 'Recreation':
      return AppColors.secondary;
    default:
      return AppColors.primary;
  }
}

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Government':
      return Icons.account_balance_rounded;
    case 'Health':
      return Icons.local_hospital_rounded;
    case 'Education':
      return Icons.school_rounded;
    case 'Community':
      return Icons.groups_rounded;
    case 'Emergency':
      return Icons.emergency_rounded;
    case 'Recreation':
      return Icons.park_rounded;
    default:
      return Icons.business_rounded;
  }
}
