import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_x/main.dart';

void main() {
  testWidgets('NEXUS X home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusXApp());

    expect(find.text('NEXUS X'), findsOneWidget);
    expect(find.text('حوّل فكرتك إلى تطبيق'), findsOneWidget);
    expect(find.text('المشاريع'), findsWidgets);
  });

  testWidgets('bottom navigation opens AI section', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusXApp());

    await tester.tap(find.text('الذكاء الاصطناعي').last);
    await tester.pumpAndSettle();

    expect(find.text('لم يتم إعداد مزود الذكاء الاصطناعي'), findsOneWidget);
  });

  testWidgets('cloud build section shows honest disconnected state',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NexusXApp());

    await tester.tap(find.text('البناء السحابي').last);
    await tester.pumpAndSettle();

    expect(find.text('لا توجد نتائج بناء مسجلة'), findsOneWidget);
    expect(find.text('حالة البناء غير متصلة بعد'), findsOneWidget);
  });
}
