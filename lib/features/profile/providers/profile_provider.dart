import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/providers/hive_provider.dart';

part 'profile_provider.g.dart';

class ProfileData {
  final String name;
  final String email;
  final String avatarInitials;
  final String bio;
  final int favoritesCount;
  final List<String> interests;
  final bool notificationsEnabled;
  final bool privateProfile;
  final bool emailDigestEnabled;

  const ProfileData({
    required this.name,
    required this.email,
    required this.avatarInitials,
    required this.bio,
    required this.favoritesCount,
    required this.interests,
    required this.notificationsEnabled,
    required this.privateProfile,
    required this.emailDigestEnabled,
  });

  ProfileData copyWith({
    String? name,
    String? email,
    String? avatarInitials,
    String? bio,
    int? favoritesCount,
    List<String>? interests,
    bool? notificationsEnabled,
    bool? privateProfile,
    bool? emailDigestEnabled,
  }) {
    return ProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      bio: bio ?? this.bio,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      interests: interests ?? this.interests,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      privateProfile: privateProfile ?? this.privateProfile,
      emailDigestEnabled: emailDigestEnabled ?? this.emailDigestEnabled,
    );
  }
}

@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<ProfileData> build() async {
    final hive = await ref.watch(hiveServiceProvider.future);

    return ProfileData(
      // Demo user data (no auth in this app)
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      avatarInitials: 'JD',
      bio:
          'Passionate about community engagement and local events. Always exploring new resources and connecting with neighbors.',
      interests: const [
        'Community',
        'Events',
        'Volunteering',
        'Local News',
        'Networking'
      ],
      // Real data from Hive
      favoritesCount: hive.totalFavoritesCount,
      notificationsEnabled: hive.notificationsEnabled,
      privateProfile: hive.privateProfile,
      emailDigestEnabled: hive.emailDigestEnabled,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final hive = await ref.read(hiveServiceProvider.future);
    await hive.setNotificationsEnabled(value);
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current.copyWith(notificationsEnabled: value));
    }
  }

  Future<void> setPrivateProfile(bool value) async {
    final hive = await ref.read(hiveServiceProvider.future);
    await hive.setPrivateProfile(value);
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current.copyWith(privateProfile: value));
    }
  }

  Future<void> setEmailDigestEnabled(bool value) async {
    final hive = await ref.read(hiveServiceProvider.future);
    await hive.setEmailDigestEnabled(value);
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current.copyWith(emailDigestEnabled: value));
    }
  }
}
