import 'package:flutter_test/flutter_test.dart';
import 'package:lost_signal/app/lost_signal_app.dart';

void main() {
  testWidgets('Lost Signal chat screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const LostSignalApp());

    expect(find.text('Unknown Student'), findsOneWidget);
    expect(find.text('Signal unstable'), findsOneWidget);
    expect(find.text('Incoming connection detected.'), findsOneWidget);
    expect(find.text('Ask where exactly they are'), findsOneWidget);
  });
}
