import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';
// lib/pages/weekly_planner_pg/weekly_planner_pg_widget.dart
import '/auth/firebase_auth/auth_util.dart'; // For currentUserReference, currentUserUid
import '/backend/backend.dart'; // For Firestore query functions if any were used directly (not in this version)
import '/components/search_pop_up_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// import '/flutter_flow/custom_functions.dart' as functions; // Not used in this version
// For Firestore direct access
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// For DateFormat
import 'package:flutter/foundation.dart' show kIsWeb;

export '/pages/weekly_planner_pg/weekly_planner_pg_model.dart';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// Add this class definition within your lib/flutter_flow/nav/nav.dart file
// Ensure you have these imports at the top of nav.dart:
// import 'dart:async';
// import 'package:flutter/material.dart';
// import '/auth/base_auth_user_provider.dart'; // Or your specific auth user provider path
// import '/flutter_flow/flutter_flow_util.dart'; // For FFAppState if used directly, though often not

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._(); // Private constructor

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

const kTransitionInfoKey = '__transition_info__';

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey:
          appNavigatorKey, // Ensure appNavigatorKey is defined globally in this file or imported
      errorBuilder: (context, state) {
        if (appStateNotifier.loggedIn) {
          if (FFAppState.instance.hasCompletedInitialSetup) {
            return const WeeklyPlannerPgWidget();
          } else {
            return const SelectDietPrefPgWidget();
          }
        } else {
          return const AuthenticationPgWidget();
        }
      },
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) {
            if (appStateNotifier.loggedIn) {
              if (FFAppState.instance.hasCompletedInitialSetup) {
                return const WeeklyPlannerPgWidget();
              } else {
                return const SelectDietPrefPgWidget();
              }
            } else {
              return const AuthenticationPgWidget();
            }
          },
        ),
        FFRoute(
          name: SelectDietPrefPgWidget.routeName,
          path: SelectDietPrefPgWidget.routePath,
          builder: (context, params) => const SelectDietPrefPgWidget(),
          requireAuth: true, // Usually, pages after auth are protected
        ),
        FFRoute(
          name: AuthenticationPgWidget.routeName,
          path: AuthenticationPgWidget.routePath,
          builder: (context, params) => const AuthenticationPgWidget(),
        ),
        FFRoute(
          name: ProfilePgWidget.routeName,
          path: ProfilePgWidget.routePath,
          builder: (context, params) => const ProfilePgWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: MealSelectionPgWidget.routeName,
          path: MealSelectionPgWidget.routePath,
          builder: (context, params) => const MealSelectionPgWidget(),
          requireAuth: true,
        ),
        FFRoute(
          name: WeeklyPlannerPgWidget.routeName,
          path: WeeklyPlannerPgWidget.routePath,
          builder: (context, params) => const WeeklyPlannerPgWidget(),
          requireAuth: true,
        ),
        // Add other FFRoute definitions for your pages here
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

// ENSURE THESE EXTENSIONS AND CLASSES ARE ALSO PRESENT IN NAV.DART
// (They are part of the standard FlutterFlow nav setup)

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    if (GoRouter.of(this).canPop()) {
      // Use GoRouter.of(this).canPop()
      GoRouter.of(this).pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier
      .instance; // Assumes AppStateNotifier.instance is accessible
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.setRedirectLocationIfUnset(location);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParametersAll)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(
                    param.value as String) // Ensure param.value is String
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (state.pathParameters.containsKey(paramName)) {
      return deserializeParam<T>(
        state.pathParameters[paramName],
        type,
        isList,
        collectionNamePath: collectionNamePath,
      );
    }
    if (state.uri.queryParametersAll.containsKey(paramName)) {
      final paramValue = state.uri.queryParametersAll[paramName];
      return deserializeParam<T>(
        paramValue?.firstOrNull,
        type,
        isList,
        collectionNamePath: collectionNamePath,
      );
    }
    if (state.extraMap.containsKey(paramName)) {
      final param = state.extraMap[paramName];
      if (param is String && type != ParamType.String) {
        // Avoid re-deserializing if already a string and type is string
        return deserializeParam<T>(
          param,
          type,
          isList,
          collectionNamePath: collectionNamePath,
        );
      }
      return param;
    }
    return null;
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return AuthenticationPgWidget
                .routePath; // Use static routePath for safety
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder<bool>(
                  // Added type for FutureBuilder
                  future: ffParams.completeFutures(),
                  builder: (context, snapshot) {
                    // Added snapshot
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        ffParams.hasFutures) {
                      return Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary),
                      ));
                    }
                    return builder(context, ffParams);
                  },
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading && name == '_initialize'
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() =>
      const TransitionInfo(hasTransition: false);
}

// fixStatusBarOniOS16AndBelow should be defined or imported if used.
// It's usually part of flutter_flow_util.dart, ensure that's correctly imported.
// If not, here's a common implementation:
void fixStatusBarOniOS16AndBelow(BuildContext context) {
  if (!kIsWeb && Theme.of(context).platform == TargetPlatform.iOS) {
    // Specific iOS 16 and below logic might be more complex,
    // Often this is handled by SystemChrome.setSystemUIOverlayStyle
    // This is a placeholder if it's missing from your flutter_flow_util.dart
    // For full functionality, ensure flutter_flow_util.dart has this.
  }
}
