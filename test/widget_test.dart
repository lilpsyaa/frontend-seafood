import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seafood_planner/main.dart';
import 'package:seafood_planner/screens/profile_about_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app builds and shows splash content', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SeafoodPlannerApp());
    await tester.pump();

    expect(find.text('SEAFOOD PLANNER'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });

  testWidgets('profile details can be edited and saved locally', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'profile_local_name': 'Nadia',
      'profile_local_class': 'XII RPL',
      'profile_local_attendance': '7',
    });
    await tester.pumpWidget(const MaterialApp(home: ProfileAboutPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Nadia Putri');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Nadia Putri'), findsNWidgets(2));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('profile_local_name'), 'Nadia Putri');
  });
}
