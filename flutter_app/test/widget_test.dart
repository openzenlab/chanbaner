import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chanbaner/services/koan_service.dart';

void main() {
  group('KoanNLU Tests', () {
    test('should detect seeking intent', () {
      final result = KoanNLU.analyze('我想要得到更多的东西');
      expect(result.hints, contains('seeking'));
    });

    test('should detect clinging_form intent', () {
      final result = KoanNLU.analyze('我看到了美丽的境界');
      expect(result.hints, contains('clinging_form'));
    });

    test('should detect scattered intent', () {
      final result = KoanNLU.analyze('我的思绪很乱很散乱');
      expect(result.hints, contains('scattered'));
    });

    test('should create neutral mirror', () {
      final result = KoanNLU.analyze('这个很好，那个很坏');
      expect(result.mirror, isNot(contains('好')));
      expect(result.mirror, isNot(contains('坏')));
    });

    test('should truncate long mirror', () {
      final longText = '这是一个很长很长的文本' * 10;
      final result = KoanNLU.analyze(longText);
      expect(result.mirror.length, lessThan(25));
    });
  });

  group('KoanService Tests', () {
    test('should provide fallback response', () {
      final service = KoanService();
      final response = service._getFallbackResponse('seeking');
      
      expect(response.koan, isNotEmpty);
      expect(response.microPractice, isNotEmpty);
      expect(response.policyNote, contains('离线'));
    });
  });
}