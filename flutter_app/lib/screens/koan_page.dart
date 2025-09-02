import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chanbaner/models/session.dart';
import 'package:chanbaner/services/database_service.dart';
import 'package:chanbaner/services/koan_service.dart';

class KoanPage extends StatefulWidget {
  final String? sessionId;
  
  const KoanPage({Key? key, this.sessionId}) : super(key: key);

  @override
  State<KoanPage> createState() => _KoanPageState();
}

class _KoanPageState extends State<KoanPage> {
  final TextEditingController _journalController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  
  KoanResponse? _currentResponse;
  bool _isLoading = false;
  String _userInput = '';

  @override
  void dispose() {
    _journalController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _generateKoan() async {
    if (_userInput.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final koanService = Provider.of<KoanService>(context, listen: false);
      
      // Use local NLU first
      final nluResult = KoanNLU.analyze(_userInput);
      
      // Call API with hints
      final response = await koanService.generateKoan(
        _userInput,
        hints: nluResult.hints,
      );
      
      setState(() {
        _currentResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    }
  }

  Future<void> _saveReflection() async {
    if (_currentResponse == null || widget.sessionId == null) return;

    final reflection = Reflection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: widget.sessionId!,
      mirror: _currentResponse!.mirror,
      koan: _currentResponse!.koan,
      microPractice: _currentResponse!.microPractice,
      userJournal: _journalController.text.trim().isEmpty 
          ? null 
          : _journalController.text.trim(),
      createdAt: DateTime.now(),
    );

    final dbService = Provider.of<DatabaseService>(context, listen: false);
    await dbService.insertReflection(reflection);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存到日记')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('机锋照见'),
        backgroundColor: Colors.brown[100],
        actions: [
          if (_currentResponse != null)
            IconButton(
              onPressed: _saveReflection,
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '请描述你的觉察或困惑：',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: '1-3句话即可...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _userInput = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _userInput.trim().isEmpty || _isLoading 
                          ? null 
                          : _generateKoan,
                      child: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('获得引导'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Response section
            if (_currentResponse != null) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildResponseSection('镜照', _currentResponse!.mirror),
                          if (_currentResponse!.koan.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildResponseSection('机锋', _currentResponse!.koan),
                          ],
                          const SizedBox(height: 16),
                          _buildResponseSection('微练习', _currentResponse!.microPractice),
                          if (_currentResponse!.quote != null && _currentResponse!.quote!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildResponseSection('拈提', _currentResponse!.quote!),
                          ],
                          const SizedBox(height: 20),
                          const Text(
                            '你的日记（可选）：',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _journalController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: '记录你的感受或领悟...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentResponse!.policyNote,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.brown[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.brown[200]!),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
      ],
    );
  }
}