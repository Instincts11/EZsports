import 'package:ezsports/features/attendance/presentation/screens/coach_attendance_screen.dart';
import 'package:ezsports/features/attendance/presentation/screens/student_attendance_screen.dart';
import 'package:ezsports/features/auth/presentation/screens/login_screen.dart';
import 'package:ezsports/features/classes/presentation/screens/classes_screen.dart';
import 'package:ezsports/features/home/presentation/screens/home_screen.dart';
import 'package:ezsports/features/matches/presentation/screens/matches_screen.dart';
import 'package:ezsports/features/profile/presentation/screens/profile_screen.dart';
import 'package:ezsports/features/students/presentation/screens/students_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      GoRoute(path: '/login', builder: (BuildContext context, GoRouterState state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (BuildContext context, GoRouterState state) => const HomeScreen()),
      GoRoute(path: '/classes', builder: (BuildContext context, GoRouterState state) => const ClassesScreen()),
      GoRoute(path: '/students', builder: (BuildContext context, GoRouterState state) => const StudentsScreen()),
      GoRoute(path: '/matches', builder: (BuildContext context, GoRouterState state) => const MatchesScreen()),
      GoRoute(path: '/profile', builder: (BuildContext context, GoRouterState state) => const ProfileScreen()),
      GoRoute(
        path: '/sessions/:id/students',
        builder: (BuildContext context, GoRouterState state) => StudentAttendanceScreen(
          sessionId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/sessions/:id/coaches',
        builder: (BuildContext context, GoRouterState state) => CoachAttendanceScreen(
          sessionId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
}
