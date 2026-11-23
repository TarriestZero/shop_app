import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/foundation.dart';

/// Изображение товара с общей заглушкой при отсутствии сети или изображения.
/// Декодирует фото под размер виджета с учётом плотности пикселей экрана.
class AppProductImage extends StatefulWidget {
  const AppProductImage({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  State<AppProductImage> createState() => _AppProductImageState();
}

class _AppProductImageState extends State<AppProductImage> {
  bool _failed = false;
  int _attempt = 0;

  @override
  void didUpdateWidget(covariant AppProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_failed || oldWidget.imageUrl != widget.imageUrl) {
      _failed = false;
      _attempt++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Center(
      child: Icon(Icons.image_outlined, size: 40, color: context.colors.border),
    );
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) return placeholder;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
          return const SizedBox.shrink();
        }
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = constraints.hasBoundedWidth
            ? (constraints.maxWidth * pixelRatio).ceil()
            : null;
        final cacheHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight * pixelRatio).ceil()
            : null;
        final provider = NetworkImage(url);

        return Image(
          key: ValueKey(_attempt),
          image: cacheWidth == null && cacheHeight == null
              ? provider
              : ResizeImage(
                  provider,
                  width: cacheWidth,
                  height: cacheHeight,
                  policy: ResizeImagePolicy.fit,
                ),
          fit: BoxFit.contain,
          excludeFromSemantics: true,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : placeholder,
          errorBuilder: (context, error, stackTrace) {
            _failed = true;
            return placeholder;
          },
        );
      },
    );
  }
}
