import 'package:ezsports/core/widgets/coach_shell.dart';
import 'package:ezsports/core/widgets/player_shell.dart';
import 'package:ezsports/features/attendance/presentation/screens/student_attendance_screen.dart';
import 'package:ezsports/features/auth/presentation/screens/login_screen.dart';
import 'package:ezsports/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:ezsports/features/auth/presentation/screens/player_signup_screen.dart';
import 'package:ezsports/features/classes/presentation/screens/classes_screen.dart';
import 'package:ezsports/features/home/presentation/screens/home_screen.dart';
import 'package:ezsports/features/player/presentation/screens/player_batches_screen.dart';
import 'package:ezsports/features/player/presentation/screens/player_details_screen.dart';
import 'package:ezsports/features/player/presentation/screens/player_home_screen.dart';
import 'package:ezsports/features/player/presentation/screens/player_profile_screen.dart';
import 'package:ezsports/features/player/presentation/screens/player_schedule_screen.dart';
import 'package:ezsports/features/profile/presentation/screens/coach_details_screen.dart';
import 'package:ezsports/features/profile/presentation/screens/profile_screen.dart';
import 'package:ezsports/features/students/presentation/screens/batch_roster_screen.dart';
import 'package:ezsports/features/students/presentation/screens/player_profile_screen.dart';
import 'package:ezsports/features/students/presentation/screens/players_screen.dart';
import 'package:ezsports/features/students/presentation/screens/students_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/login',
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) => const PlayerSignupScreen(),
      ),
      GoRoute(
        path: '/signup/otp',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final Map<String, String> data = extra is Map<String, String>
              ? extra
              : <String, String>{};
          return OtpVerifyScreen(
            mobile: data['mobile'] ?? '',
            purpose: data['purpose'] ?? 'signup',
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
          return CoachShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: '/home', builder: (BuildContext context, GoRouterState state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/batches',
                builder: (BuildContext context, GoRouterState state) => const StudentsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':batchId',
                    builder: (BuildContext context, GoRouterState state) => BatchRosterScreen(
                      batchId: int.parse(state.pathParameters['batchId']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/players',
                builder: (BuildContext context, GoRouterState state) => const PlayersScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':playerId',
                    builder: (BuildContext context, GoRouterState state) => PlayerProfileScreen(
                      playerId: int.parse(state.pathParameters['playerId']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/sessions',
                builder: (BuildContext context, GoRouterState state) => const ClassesScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id/attendance',
                    builder: (BuildContext context, GoRouterState state) => StudentAttendanceScreen(
                      sessionId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details',
                    parentNavigatorKey: rootKey,
                    builder: (BuildContext context, GoRouterState state) => const CoachDetailsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
          return PlayerShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/player/home',
                builder: (BuildContext context, GoRouterState state) => const PlayerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/player/batches',
                builder: (BuildContext context, GoRouterState state) => const PlayerBatchesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/player/schedule',
                builder: (BuildContext context, GoRouterState state) => const PlayerScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/player/profile',
                builder: (BuildContext context, GoRouterState state) => const PlayerAccountScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'details',
                    parentNavigatorKey: rootKey,
                    builder: (BuildContext context, GoRouterState state) => const PlayerDetailsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
