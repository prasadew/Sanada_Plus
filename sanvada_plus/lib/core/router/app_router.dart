import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/chat/screens/chats_list_screen.dart';
import '../../features/chat/screens/contacts_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/camera/screens/camera_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/profile_screen.dart';
import '../../features/settings/screens/account_screen.dart';
import '../../features/settings/screens/privacy_screen.dart';
import '../../features/settings/screens/chat_settings_screen.dart';
import '../../features/settings/screens/notifications_screen.dart';
import '../../features/settings/screens/storage_screen.dart';
import '../../features/settings/screens/help_screen.dart';
import '../../features/settings/screens/about_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final isLoggedIn = currentUser != null;
      final loc = state.matchedLocation;

      final isAuthRoute =
          loc == '/welcome' || loc == '/register' || loc == '/otp';

      // Not logged in → must be on auth route
      if (!isLoggedIn && !isAuthRoute) {
        return '/welcome';
      }

      // Logged in and on welcome → go to chats
      if (isLoggedIn && loc == '/welcome') {
        return '/chats';
      }

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return OTPScreen(registrationData: data);
        },
      ),

      // ── Main ──────────────────────────────────────────
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatsListScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatScreen(chatId: id);
        },
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),

      // ── Settings ──────────────────────────────────────
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/settings/chat-settings',
        builder: (context, state) => const ChatSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings/storage',
        builder: (context, state) => const StorageScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
});
