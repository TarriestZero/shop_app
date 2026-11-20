import 'package:material_ui/material_ui.dart';
import 'package:shop_app/foundation/foundation.dart';

/// Изображение товара с общей заглушкой при отсутствии сети или изображения.
class AppProductImage extends StatelessWidget {
  const AppProductImage({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final placeholder = Center(
      child: Icon(Icons.image_outlined, size: 40, color: context.colors.border),
    );
    final url = imageUrl;
    if (url == null || url.isEmpty) return placeholder;

    return Image.network(
      url,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
