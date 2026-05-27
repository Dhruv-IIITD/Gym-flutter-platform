import 'package:go_router/go_router.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/widgets/call_screen.dart';
import 'package:shared/widgets/pre_join_screen.dart';

import 'screens/chat_wrappers.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/members_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/sessions_wrapper_screen.dart';

final trainerRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final loggedIn = await AuthService().isLoggedIn();
    final location = state.matchedLocation;
    if (!loggedIn && location != '/login') {
      return '/login';
    }
    if (loggedIn && location == '/login') {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/members', builder: (_, __) => const MembersScreen()),
    GoRoute(
      path: '/members/:memberId',
      builder: (_, state) => MemberDetailScreen(
        memberId: state.pathParameters['memberId']!,
      ),
    ),
    GoRoute(path: '/chat', builder: (_, __) => const TrainerChatListWrapper()),
    GoRoute(
      path: '/chat/:chatId',
      builder: (_, state) => TrainerConversationWrapper(
        chatId: state.pathParameters['chatId']!,
      ),
    ),
    GoRoute(path: '/requests', builder: (_, __) => const RequestsScreen()),
    GoRoute(
      path: '/call/pre-join/:roomCode',
      builder: (_, state) => PreJoinScreen(
        roomCode: state.pathParameters['roomCode']!,
        userName: 'Aarav',
      ),
    ),
    GoRoute(
      path: '/call/:roomCode',
      builder: (_, state) => CallScreen(
        roomCode: state.pathParameters['roomCode']!,
      ),
    ),
    GoRoute(
      path: '/sessions',
      builder: (_, __) => const TrainerSessionsWrapper(),
    ),
  ],
);
