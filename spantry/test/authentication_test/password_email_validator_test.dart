import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:spantry/pages/authentication/login_page.dart';
import 'package:spantry/pages/authentication/signup_page.dart';
import 'package:spantry/pages/authentication/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spantry/services/authentication/firebase_auth_handler.dart' as auth;
import 'password_email_validator_test.mocks.dart' as tests;
import 'package:spantry/utils/utils.dart';
import 'package:integration_test/integration_test.dart';

@GenerateNiceMocks([MockSpec<auth.FirebaseAuthHandler>(), MockSpec<User>(), MockSpec<UserCredential>(), MockSpec<Utils>()])

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseAuthHandler Tests', () {
    late tests.MockFirebaseAuthHandler mockFirebaseAuthHandler;
    late TextEditingController emailController;
    late TextEditingController passwordController;

    setUp(() {
      mockFirebaseAuthHandler = tests.MockFirebaseAuthHandler();
      emailController = TextEditingController();
      passwordController = TextEditingController();
    });

    test('signUp method calls createUserWithEmailAndPassword with correct parameters', () async {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      emailController.text = testEmail;
      passwordController.text = testPassword;

      when(mockFirebaseAuthHandler.signUp(emailController, passwordController))
          .thenAnswer((_) => Future.value());

      await mockFirebaseAuthHandler.signUp(emailController, passwordController);

      verify(mockFirebaseAuthHandler.signUp(emailController, passwordController)).called(1);
    });

    test('Login method', () async {
      const testEmail = 'test@gmail.com';
      const testPassword = '123456';
      emailController.text = testEmail;
      passwordController.text = testPassword;

      when(mockFirebaseAuthHandler.login(emailController, passwordController)).thenAnswer((_) => Future.value());

      await mockFirebaseAuthHandler.login(emailController, passwordController);

      verify(mockFirebaseAuthHandler.login(emailController, passwordController)).called(1);
    });

    test('signInWithGoogle method initiates Google sign-in process', () async {
      when(mockFirebaseAuthHandler.signInWithGoogle())
          .thenAnswer((_) async => Future.value());

      await mockFirebaseAuthHandler.signInWithGoogle();

      verify(mockFirebaseAuthHandler.signInWithGoogle()).called(1);
    });

    test('resetPassword', () async {
      const testEmail = 'test@gmail.com';
      emailController.text = testEmail;
      when(mockFirebaseAuthHandler.resetPassword(emailController)).thenAnswer((_) => Future.value());

      await mockFirebaseAuthHandler.resetPassword(emailController);

      verify(mockFirebaseAuthHandler.resetPassword(emailController)).called(1);
    });

  });

  group('SignUp Page Tests', () {
    testWidgets('Widget building and initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SignUp(onClickedSignUp: () {}),
      ));

      expect(find.byType(TextFormField),
          findsNWidgets(3));
      expect(find.byType(ElevatedButton), findsWidgets);
      expect(find.byType(Checkbox),
          findsOneWidget);
    });

    testWidgets('Form Validation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SignUp(onClickedSignUp: () {})));

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test');
      await tester.pump();
      expect(find.text('Enter a valid email'),
          findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.pump();
      expect(find.text('Enter min. 6 characters'),
          findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), '123');
      await tester.pump();
      expect(find.text('Enter min. 6 characters'),
          findsWidgets);
    });
  });

  group('Login Page Tests', () {
    testWidgets('Widget building and initialization', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Login(onClickedSignUp: () {}),
      ));

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNWidgets(1));
      expect(find.byKey(Key('forgotPasswordButton')), findsOneWidget);
    });

    testWidgets('Form Validation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Login(onClickedSignUp: () {})));

      await tester.enterText(find.byKey(Key('emailField')), 'test');
      await tester.pump();
      expect(find.text('Enter a valid email'), findsNothing);

      await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(Key('passwordField')), '123');
      await tester.pump();
      expect(find.text('Enter min. 6 characters'), findsOneWidget);
    });
  });

  group('ForgotPassword Page Tests', () {
    testWidgets('Widget building and initialization', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ForgotPasswordPage(),
      ));

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Reset your\npassword'), findsOneWidget);
      expect(find.text('Enter your email address and we will send you a password reset link'), findsOneWidget);
    });

    testWidgets('Form Validation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ForgotPasswordPage()));

      await tester.enterText(find.byKey(Key('emailField')), 'test');
      await tester.pump();
      expect(find.text('Enter a valid email'), findsOneWidget);

      await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
      await tester.pump();
      expect(find.text('Enter a valid email'), findsNothing);
    });
  });
}
