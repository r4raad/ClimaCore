import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ai_message.dart';
import '../models/user.dart';
import '../services/ai_service.dart';
import '../widgets/ai_message_bubble.dart';

class AIChatScreen extends StatefulWidget {
  final AppUser user;
  
  const AIChatScreen({
    Key? key,
    required this.user,
  }) : super(key: key);
  
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIMessage> _messages = [];
  bool _isLoading = false;
  String _conversationId = '';

  @override
  void initState() {
    super.initState();
    _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Hello! I\'m ClimaAI, your climate and environmental science assistant. How can I help you today?',
      type: MessageType.ai,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      conversationId: _conversationId,
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              
              Expanded(
                child: _buildChatArea(),
              ),
              
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: Text(
              'Clima AI',
              style: GoogleFonts.questrial(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          GestureDetector(
            onTap: () {
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.settings,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.displayName,
                            style: GoogleFonts.questrial(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Welcome',
                            style: GoogleFonts.questrial(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white),
                        ),
                        child: Text('Chat AI'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return AIMessageBubble(
                    message: message,
                    onCopy: () => _copyMessage(message.content),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Send a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                onSubmitted: (text) => _sendMessage(text),
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.send,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.mic,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      conversationId: _conversationId,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    AIService.sendMessage(text, conversationId: _conversationId).then((response) {
      final aiMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response.content,
        type: MessageType.ai,
        timestamp: DateTime.now(),
        status: response.isError ? MessageStatus.error : MessageStatus.sent,
        conversationId: _conversationId,
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    }).catchError((error) {
      final errorMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        type: MessageType.ai,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
        conversationId: _conversationId,
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  String _getUserFirstName() {
    return widget.user.displayName;
  }
} 