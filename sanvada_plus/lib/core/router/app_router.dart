import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/chat/screens/chats_list_screen.dart';
import '../../features/chat/screens/contacts_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/camera/screens/camera_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/otp';
      
      if (!isAuth && !isLoggingIn) {
        return '/login';
      }
      
      if (isAuth && isLoggingIn) {
        return '/chats';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OTPScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatsListScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
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
    ],
  );
});
