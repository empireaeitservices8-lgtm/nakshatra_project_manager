// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kanban_app/app_state.dart';
import 'package:kanban_app/main.dart';
import 'package:kanban_app/services/services.dart';
import 'package:kanban_app/viewmodels/viewmodels.dart';

void main() {
  testWidgets('NakshatraApp loads without errors', (WidgetTester tester) async {
    final apiService = ApiService();
    final taskManagerApi = TaskManagerApiService(apiService: apiService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiService>.value(value: apiService),
          Provider<TaskManagerApiService>.value(value: taskManagerApi),
          ChangeNotifierProvider<AuthViewModel>(
            create: (_) => AuthViewModel(api: taskManagerApi),
          ),
          ChangeNotifierProvider<BoardViewModel>(
            create: (_) => BoardViewModel(api: taskManagerApi),
          ),
          ChangeNotifierProvider<TaskViewModel>(
            create: (_) => TaskViewModel(api: taskManagerApi),
          ),
          ChangeNotifierProvider<NotificationViewModel>(
            create: (_) => NotificationViewModel(api: taskManagerApi),
          ),
          ChangeNotifierProvider<AppState>(
            create: (_) => AppState(),
          ),
        ],
        child: const NakshatraApp(),
      ),
    );

    expect(find.byType(NakshatraApp), findsOneWidget);
  });
}
