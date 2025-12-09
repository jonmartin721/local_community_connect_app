import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder profile provider - can be expanded to fetch real user data
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Simulate async data fetch
  await Future.delayed(const Duration(milliseconds: 300));

  return {
    'name': 'Jane Doe',
    'email': 'jane.doe@example.com',
    'bio': 'Passionate about community engagement and local events. Always exploring new resources and connecting with neighbors.',
    'avatar': 'JD',
    'favoriteCount': 12,
    'followingCount': 8,
    'savedPlacesCount': 5,
    'interests': ['Community', 'Events', 'Volunteering', 'Local News', 'Networking'],
    'notificationsEnabled': true,
    'privateProfile': false,
    'emailDigestEnabled': true,
  };
});
