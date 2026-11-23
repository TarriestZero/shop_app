import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/foundation.dart';
import 'package:shop_app/ui_kit/ui_kit.dart';

import '../support/image_test_support.dart';

void main() {
  testWidgets(
    'Обновление повторяет ошибку фото и сохраняет уже загруженное фото',
    (tester) async {
      final rebuild = ValueNotifier(0);
      addTearDown(rebuild.dispose);
      try {
        final client = await _pumpImage(
          tester,
          source: const Size(80, 40),
          box: const Size(100, 100),
          ratio: 1,
          rebuild: rebuild,
          failRequests: true,
        );
        await tester.pumpAndSettle();
        expect(client.requests, 1);
        expect(find.byIcon(Icons.image_outlined), findsOneWidget);

        client.failRequests = false;
        rebuild.value++;
        await tester.pump();
        final image = await waitForDecodedImage(tester);
        expect(client.requests, 2);
        expect(find.byIcon(Icons.image_outlined), findsNothing);

        rebuild.value++;
        await tester.pumpAndSettle();
        expect(await waitForDecodedImage(tester), same(image));
        expect(client.requests, 2);
        expect(tester.takeException(), isNull);
      } finally {
        debugNetworkImageHttpClientProvider = null;
        debugInvertOversizedImages = false;
      }
    },
  );

  for (final scenario in [
    (
      source: const Size(472, 529),
      box: const Size(130, 74),
      ratio: 2.625,
      decoded: const Size(173, 195),
    ),
    (
      source: const Size(600, 300),
      box: const Size(100, 100),
      ratio: 1.0,
      decoded: const Size(100, 50),
    ),
    (
      source: const Size(600, 300),
      box: const Size(100, 100),
      ratio: 2.0,
      decoded: const Size(200, 100),
    ),
    (
      source: const Size(80, 40),
      box: const Size(100, 100),
      ratio: 2.0,
      decoded: const Size(80, 40),
    ),
  ]) {
    testWidgets(
      'Декодирование ${scenario.source} в ${scenario.box} при DPR ${scenario.ratio}',
      (tester) async {
        try {
          await _pumpImage(
            tester,
            source: scenario.source,
            box: scenario.box,
            ratio: scenario.ratio,
          );
          final image = await waitForDecodedImage(tester);
          expect(image.width, scenario.decoded.width.toInt());
          expect(image.height, scenario.decoded.height.toInt());
          expect(tester.takeException(), isNull);
        } finally {
          debugNetworkImageHttpClientProvider = null;
          debugInvertOversizedImages = false;
        }
      },
    );
  }

  testWidgets('Изображение нулевого размера не загружается', (tester) async {
    try {
      final client = await _pumpImage(
        tester,
        source: const Size(80, 40),
        box: Size.zero,
        ratio: 2,
      );
      await tester.pumpAndSettle();
      expect(client.requests, 0);
      expect(tester.takeException(), isNull);
    } finally {
      debugNetworkImageHttpClientProvider = null;
      debugInvertOversizedImages = false;
    }
  });
}

Future<TestImageClient> _pumpImage(
  WidgetTester tester, {
  required Size source,
  required Size box,
  required double ratio,
  ValueNotifier<int>? rebuild,
  bool failRequests = false,
}) async {
  final bytes = (await tester.runAsync(() => createTestPng(source)))!;
  final client = TestImageClient(bytes)..failRequests = failRequests;
  final previousClient = debugNetworkImageHttpClientProvider;
  final previousOversizedCheck = debugInvertOversizedImages;
  debugNetworkImageHttpClientProvider = () => client;
  debugInvertOversizedImages = true;
  tester.view.devicePixelRatio = ratio;
  tester.view.physicalSize = Size(800 * ratio, 600 * ratio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    debugNetworkImageHttpClientProvider = previousClient;
    debugInvertOversizedImages = previousOversizedCheck;
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
  Widget image() => SizedBox(
    width: box.width,
    height: box.height,
    child: AppProductImage(imageUrl: 'https://example.test/product.png'),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: createAppLightTheme(),
      home: Scaffold(
        body: Center(
          child: rebuild == null
              ? image()
              : ValueListenableBuilder<int>(
                  valueListenable: rebuild,
                  builder: (context, value, child) => image(),
                ),
        ),
      ),
    ),
  );
  return client;
}
