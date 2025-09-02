import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私与伦理'),
        backgroundColor: Colors.brown[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ChanBaner 隐私承诺',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildSection(
              '数据本地化',
              '你的定课记录和日记完全存储在本地设备，我们不会上传或存储你的个人修行内容。',
            ),
            
            _buildSection(
              '机锋引导原则',
              '本应用提供的机锋问句仅为修行引导，不对任何悟境或证量进行评判。请以自己的觉察为准。',
            ),
            
            _buildSection(
              '网络使用',
              '仅在生成机锋引导时需要网络连接。你的原始文本会发送到服务器进行处理，但不会被持久化存储。',
            ),
            
            _buildSection(
              '危机处理',
              '如果检测到心理危机相关内容，应用会提供安抚建议并引导寻求专业帮助。',
            ),
            
            _buildSection(
              '开源透明',
              '本应用代码开源，你可以查看和验证我们的隐私实践。',
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '重要提醒',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '本应用不能替代专业的心理健康服务。如遇严重心理困扰，请及时寻求专业帮助。\n\n全国心理健康热线：400-161-9995',
                    style: TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('我已了解'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }
}