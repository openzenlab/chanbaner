import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chanbaner/models/session.dart';
import 'package:chanbaner/services/database_service.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<Session> _sessions = [];
  List<Reflection> _reflections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    
    final sessions = await dbService.getSessions();
    final reflections = await dbService.getReflections();
    
    setState(() {
      _sessions = sessions;
      _reflections = reflections;
      _isLoading = false;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else {
      return '${minutes}分钟';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<Reflection> _getReflectionsForSession(String sessionId) {
    return _reflections.where((r) => r.sessionId == sessionId).toList();
  }

  Widget _buildTrendIndicator() {
    if (_sessions.length < 2) return const SizedBox.shrink();
    
    // Simple trend calculation based on recent sessions
    final recentSessions = _sessions.take(7).toList();
    final avgDuration = recentSessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.duration,
    ) ~/ recentSessions.length;
    
    final previousSessions = _sessions.skip(7).take(7).toList();
    if (previousSessions.isEmpty) return const SizedBox.shrink();
    
    final prevAvgDuration = previousSessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.duration,
    ) ~/ previousSessions.length;
    
    final isImproving = avgDuration > prevAvgDuration;
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isImproving ? Icons.trending_up : Icons.trending_down,
              color: isImproving ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '本周趋势',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isImproving ? '定课时长有所增长' : '保持稳定练习',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('觉察日记'),
        backgroundColor: Colors.brown[100],
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _sessions.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '还没有定课记录',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '开始你的第一次定课吧',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTrendIndicator(),
                  const SizedBox(height: 16),
                  ..._sessions.map((session) => _buildSessionCard(session)),
                ],
              ),
      ),
    );
  }

  Widget _buildSessionCard(Session session) {
    final sessionReflections = _getReflectionsForSession(session.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.timer, color: Colors.brown),
        title: Text(
          '定课 ${_formatDuration(session.duration)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatDate(session.startedAt)),
        children: [
          if (sessionReflections.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '本次定课没有记录',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...sessionReflections.map((reflection) => _buildReflectionCard(reflection)),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(Reflection reflection) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown[25],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reflection.mirror.isNotEmpty) ...[
            _buildReflectionSection('镜照', reflection.mirror),
            const SizedBox(height: 12),
          ],
          if (reflection.koan.isNotEmpty) ...[
            _buildReflectionSection('机锋', reflection.koan),
            const SizedBox(height: 12),
          ],
          _buildReflectionSection('微练习', reflection.microPractice),
          if (reflection.userJournal != null && reflection.userJournal!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildReflectionSection('我的日记', reflection.userJournal!),
          ],
          const SizedBox(height: 8),
          Text(
            _formatDate(reflection.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.3),
        ),
      ],
    );
  }
}