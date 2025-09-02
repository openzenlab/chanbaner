import 'dart:convert';
import 'package:http/http.dart' as http;

class KoanNLU {
  static const Map<String, List<String>> intentKeywords = {
    'seeking': ['想要', '希望', '求', '得到', '获得', '需要'],
    'clinging_form': ['看到', '听到', '感觉', '境界', '现象', '相'],
    'scattered': ['乱', '散乱', '分心', '杂念', '思绪'],
    'emptiness_fixation': ['空', '无', '虚无', '什么都没有'],
    'ego_focus': ['我', '自己', '我的', '个人'],
  };
  
  static KoanNLUResult analyze(String userText) {
    // Remove judgment words
    List<String> judgmentWords = ['好', '坏', '对', '错', '应该', '不应该', '必须', '糟糕', '完美'];
    String cleanText = userText;
    for (String word in judgmentWords) {
      cleanText = cleanText.replaceAll(word, '');
    }
    
    // Create neutral mirror
    String mirror = cleanText.length > 20 
        ? '你说：${cleanText.substring(0, 17)}...'
        : '你说：$cleanText';
    
    // Detect intent
    String intent = 'scattered'; // default
    for (String intentKey in intentKeywords.keys) {
      List<String> keywords = intentKeywords[intentKey]!;
      if (keywords.any((keyword) => userText.contains(keyword))) {
        intent = intentKey;
        break;
      }
    }
    
    return KoanNLUResult(mirror: mirror, hints: [intent]);
  }
}

class KoanNLUResult {
  final String mirror;
  final List<String> hints;
  
  KoanNLUResult({required this.mirror, required this.hints});
}

class KoanResponse {
  final String mirror;
  final String koan;
  final String microPractice;
  final String? quote;
  final String policyNote;
  
  KoanResponse({
    required this.mirror,
    required this.koan,
    required this.microPractice,
    this.quote,
    required this.policyNote,
  });
  
  factory KoanResponse.fromJson(Map<String, dynamic> json) {
    return KoanResponse(
      mirror: json['mirror'],
      koan: json['koan'],
      microPractice: json['micro_practice'],
      quote: json['quote'],
      policyNote: json['policy_note'],
    );
  }
}

class KoanService {
  static const String baseUrl = 'http://localhost:8000'; // Change for production
  
  // Fallback templates for offline mode
  static const Map<String, Map<String, String>> fallbackTemplates = {
    'seeking': {
      'koan': '未起求心前，谁在要？',
      'practice': '只数三息；起评判即从一再来。',
      'quote': '念起即觉。'
    },
    'scattered': {
      'koan': '念与念间，谁在知？',
      'practice': '数息至三，失数即从一。',
      'quote': ''
    },
  };
  
  Future<KoanResponse> generateKoan(String userText, {List<String>? hints}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/koan/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_text': userText,
          'hints': hints ?? [],
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return KoanResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to local template
      return _getFallbackResponse(hints?.first ?? 'scattered');
    }
  }
  
  KoanResponse _getFallbackResponse(String intent) {
    final template = fallbackTemplates[intent] ?? fallbackTemplates['scattered']!;
    
    return KoanResponse(
      mirror: '网络不可用，使用本地引导。',
      koan: template['koan']!,
      microPractice: template['practice']!,
      quote: template['quote'],
      policyNote: '离线模式，此为引导练习。',
    );
  }
}