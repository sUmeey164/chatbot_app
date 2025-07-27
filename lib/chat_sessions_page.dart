// lib/chat_sessions_page.dart
import 'package:flutter/material.dart';
import 'package:chatbot_app/history_manager.dart';
import 'package:chatbot_app/chat_session.dart';
import 'package:chatbot_app/chat_history_page.dart';
import 'package:intl/intl.dart'; // Add this import for DateFormat

class ChatSessionsPage extends StatefulWidget {
  final String? selectedModel;

  const ChatSessionsPage({Key? key, this.selectedModel}) : super(key: key);

  @override
  _ChatSessionsPageState createState() => _ChatSessionsPageState();
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  Map<String, List<ChatSession>> _groupedSessions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    final allSessions = await HistoryManager.getAllSessions();

    List<ChatSession> sessionsToGroup = [];
    if (widget.selectedModel != null) {
      sessionsToGroup = allSessions
          .where((session) => session.model == widget.selectedModel)
          .toList();
    } else {
      sessionsToGroup = allSessions;
    }

    _groupedSessions.clear();
    for (var session in sessionsToGroup) {
      final model = session.model ?? 'Chatbot';
      if (!_groupedSessions.containsKey(model)) {
        _groupedSessions[model] = [];
      }
      _groupedSessions[model]!.add(session);
    }

    _groupedSessions.forEach((key, value) {
      value.sort((a, b) => b.id.compareTo(a.id));
    });

    setState(() {
      _isLoading = false;
    });
  }

  Color getSessionColor(String? model) {
    switch (model) {
      case 'Gemini':
        return Colors.blue;
      case 'ChatGPT':
        return Colors.pink;
      case 'DeepSeek':
        return Colors.amber;
      case 'Chatbot':
      default:
        return Colors.deepPurple;
    }
  }

  IconData getModelIcon(String model) {
    switch (model) {
      case 'Chatbot':
        return Icons.smart_toy;
      case 'ChatGPT':
        return Icons.chat_bubble_outline;
      case 'Gemini':
        return Icons.auto_awesome;
      case 'DeepSeek':
        return Icons.search;
      default:
        return Icons.smart_toy;
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.selectedModel != null
        ? '${widget.selectedModel} Sessions'
        : 'All Chat Sessions';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(appBarTitle, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : _groupedSessions.isEmpty
          ? Center(
              child: Text(
                widget.selectedModel != null
                    ? 'No sessions found for ${widget.selectedModel}.'
                    : 'No chat sessions found yet.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _groupedSessions.keys.length,
              itemBuilder: (context, index) {
                final modelName = _groupedSessions.keys.elementAt(index);
                final sessionsForModel = _groupedSessions[modelName]!;
                final modelColor = getSessionColor(modelName);

                if (widget.selectedModel != null &&
                    modelName != widget.selectedModel) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sessionsForModel.length,
                      itemBuilder: (context, sessionIndex) {
                        final session = sessionsForModel[sessionIndex];
                        final sessionCardColor = getSessionColor(session.model);

                        // Convert session ID to DateTime and format it
                        final sessionDateTime =
                            DateTime.fromMillisecondsSinceEpoch(
                              int.parse(session.id),
                            );
                        final formattedDate = DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(sessionDateTime); // e.g., "27 Tem 2025, 20:17"

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 4.0,
                          ),
                          color: sessionCardColor.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: sessionCardColor,
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              color: sessionCardColor,
                            ),
                            // Use a Column to stack date and session title
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate, // Display formatted date/time here
                                  style: const TextStyle(
                                    color: Colors
                                        .white54, // Lighter color for date
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  session.title.isNotEmpty
                                      ? session.title
                                      : 'Untitled Chat Session',
                                  style: TextStyle(
                                    color: sessionCardColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${session.messages.length} messages',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade300,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Delete Session',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      'Are you sure you want to delete this chat session?',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    backgroundColor: Colors.grey[850],
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await HistoryManager.deleteSession(
                                    session.id,
                                  );
                                  _loadSessions();
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatHistoryPage(
                                    deviceId: session.deviceId,
                                    sessionId: session.id,
                                  ),
                                ),
                              ).then((_) {
                                _loadSessions();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
