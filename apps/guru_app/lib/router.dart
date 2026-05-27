import 'package:go_router/go_router.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/widgets/call_screen.dart';
import 'package:shared/widgets/pre_join_screen.dart';

import 'screens/chat_wrappers.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/sessions_wrapper_screen.dart';

final guruRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final onboarded = await AuthService().isOnboarded();
    final location = state.matchedLocation;
    final inSetup = location == '/onboarding' || location == '/profile-setup';
    if (!onboarded && !inSetup) {
      return '/onboarding';
    }
    if (onboarded && inSetup) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(
      path: '/profile-setup',
      builder: (_, __) => const ProfileSetupScreen(),
    ),
    GoRoute(path: '/chat', builder: (_, __) => const GuruChatListWrapper()),
    GoRoute(
      path: '/chat/:chatId',
      builder: (_, state) => GuruConversationWrapper(
        chatId: state.pathParameters['chatId']!,
      ),
    ),
    GoRoute(path: '/schedule', builder: (_, __) => const ScheduleScreen()),
    GoRoute(path: '/requests', builder: (_, __) => const MyRequestsScreen()),
    GoRoute(
      path: '/call/pre-join/:roomCode',
      builder: (_, state) => PreJoinScreen(
        roomCode: state.pathParameters['roomCode']!,
        userName: 'DK',
      ),
    ),
    GoRoute(
      path: '/call/:roomCode',
      builder: (_, state) => CallScreen(
        roomCode: state.pathParameters['roomCode']!,
      ),
    ),
    GoRoute(path: '/sessions', builder: (_, __) => const GuruSessionsWrapper()),
  ],
);
