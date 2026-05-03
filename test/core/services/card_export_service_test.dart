import 'package:flutter_test/flutter_test.dart';
import 'package:uzme/core/services/card_export_service.dart';

void main() {
  group('CardExportFormat', () {
    test('story has correct dimensions', () {
      expect(CardExportFormat.story.width, 1080);
      expect(CardExportFormat.story.height, 1920);
      expect(CardExportFormat.story.label, 'Story');
    });

    test('post has correct dimensions', () {
      expect(CardExportFormat.post.width, 1080);
      expect(CardExportFormat.post.height, 1080);
      expect(CardExportFormat.post.label, 'Post');
    });

    test('landscape has correct dimensions', () {
      expect(CardExportFormat.landscape.width, 1920);
      expect(CardExportFormat.landscape.height, 1080);
      expect(CardExportFormat.landscape.label, 'Paysage');
    });

    test('story aspect ratio is 9:16', () {
      final ratio = CardExportFormat.story.aspectRatio;
      expect(ratio, closeTo(9 / 16, 0.01));
    });

    test('post aspect ratio is 1:1', () {
      expect(CardExportFormat.post.aspectRatio, 1.0);
    });

    test('landscape aspect ratio is 16:9', () {
      final ratio = CardExportFormat.landscape.aspectRatio;
      expect(ratio, closeTo(16 / 9, 0.01));
    });

    test('all formats have unique labels', () {
      final labels = CardExportFormat.values.map((f) => f.label).toSet();
      expect(labels.length, CardExportFormat.values.length);
    });
  });
}
