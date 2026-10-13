import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_x/main.dart';

void main() {
  testWidgets('dashboard renders', (tester) async {
    await tester.pumpWidget(const NexusXApp());
    expect(find.text('NEXUS X'), findsOneWidget);
    expect(find.text('حوّل فكرتك إلى تطبيق'), findsOneWidget);
  });
  testWidgets('projects page has live repository lookup', (tester) async {
    await tester.pumpWidget(const NexusXApp());
    await tester.tap(find.text('المشاريع').last);
    await tester.pumpAndSettle();
    expect(find.text('مستودعات GitHub'), findsOneWidget);
    expect(find.text('جلب المستودعات'), findsOneWidget);
    expect(find.text('hlab37850-jpg'), findsOneWidget);
  });
  testWidgets('cloud page has live Actions lookup', (tester) async {
    await tester.pumpWidget(const NexusXApp());
    await tester.tap(find.text('البناء السحابي').last);
    await tester.pumpAndSettle();
    expect(find.text('فحص آخر بناء'), findsOneWidget);
    expect(find.text('NEXUS-X'), findsOneWidget);
  });
}
