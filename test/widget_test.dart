import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/main.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/dashboard_screen.dart';
import 'package:my_app/screens/getting_started_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('shows the E-Dumper welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('E-DUMPER'), findsOneWidget);
    expect(find.text('TURN DEAD TECH INTO CASH'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('opens onboarding directly from the welcome screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byType(GettingStartedScreen), findsOneWidget);
    expect(find.text('Got a broken phone?'), findsOneWidget);
  });

  testWidgets('continues through onboarding into the dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue as Guest →'));
    await tester.tap(find.text('Continue as Guest →'));
    await tester.pumpAndSettle();

    expect(find.text('Good afternoon,'), findsOneWidget);
    expect(find.text('We’re Buying Now'), findsOneWidget);
  });

  testWidgets('renders correctly on a narrow phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(GettingStartedScreen), findsOneWidget);
    expect(find.text('Got a broken phone?'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Continue as Guest →'));
    await tester.tap(find.text('Continue as Guest →'));
    await tester.pumpAndSettle();
    expect(find.text('Good afternoon,'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the dashboard on a tablet viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('We’re Buying Now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the dashboard on a narrow phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Good afternoon,'), findsOneWidget);
    expect(find.text('LIVE OFFERS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens Sell from the bottom navigation and goes back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    await tester.tap(find.text('Sell'));
    await tester.pumpAndSettle();
    expect(find.text('Select brand'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Good afternoon,'), findsOneWidget);
  });

  testWidgets('Orders and Profile back buttons return to Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('My Orders'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Good afternoon,'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Guest'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Good afternoon,'), findsOneWidget);
  });

  testWidgets('shows notifications from the Home header', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.byTooltip('Notifications'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Pickup scheduled'), findsOneWidget);
  });

  testWidgets('logout returns to the login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log Out'));
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
  });

  testWidgets('login screen shows forgot password action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen(createAccount: false)),
    );

    expect(find.text('Forgot password?'), findsOneWidget);
    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    expect(find.text('Enter a valid email address first.'), findsOneWidget);
  });

  testWidgets('password field can show and hide password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen(createAccount: false)),
    );

    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
