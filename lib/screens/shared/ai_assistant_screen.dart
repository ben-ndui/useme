import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:uzme/core/models/ai_message.dart';
import 'package:uzme/core/services/ai_conversation_service.dart';
import 'package:uzme/core/services/ai_local_response_helper.dart';
import 'package:uzme/core/services/chat_assistant_service.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/chat/chat_widgets_exports.dart';

/// Ecran de conversation avec l'assistant IA personnel
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final bool _isLoading = false;
  bool _isTyping = false;
  List<AIMessage> _messages = [];
  String? _conversationId;
  late AILocalResponseHelper _responseHelper;
  late AIConversationService _conversationService;

  @override
  void initState() {
    super.initState();
    _initServices(null);
    _initConversation();
  }

  void _initServices(BaseUserRole? role) {
    _responseHelper = AILocalResponseHelper(
      aiService: ChatAssistantService(),
      userRole: role,
    );
    _conversationService = AIConversationService(
      responseHelper: _responseHelper,
    );
  }

  Future<void> _initConversation() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      _initServices(authState.user.role);
    }

    _conversationId = 'ai_assistant_$userId';
    final loaded = await _conversationService.loadMessages(_conversationId!);

    setState(() {
      _messages = loaded.isNotEmpty
          ? loaded
          : [
              AIMessage(
                id: 'welcome',
                content: _responseHelper.getWelcomeMessage(),
                isFromAI: true,
                timestamp: DateTime.now(),
                suggestions: _responseHelper.getInitialSuggestions(),
              ),
            ];
    });

    _scrollToBottom(animate: false);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (FirebaseAuth.instance.currentUser?.uid == null) return;

    final l10n = AppLocalizations.of(context)!;
    _messageController.clear();

    final userMessage = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isFromAI: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });
    _scrollToBottom();

    if (_conversationId != null) {
      await _conversationService.saveMessage(_conversationId!, userMessage);
    }

    try {
      final response = await _conversationService.generateResponse(
        text, _messages,
      );
      final suggestions = response.suggestions.isNotEmpty
          ? response.suggestions
          : _responseHelper.generateFollowUpSuggestions(response.intent);
      final aiMessage = AIMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response.content,
        isFromAI: true,
        timestamp: DateTime.now(),
        suggestions: suggestions,
        actions: response.actions,
      );
      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });
      if (_conversationId != null) {
        await _conversationService.saveMessage(_conversationId!, aiMessage);
      }
      _scrollToBottom();
    } catch (_) {
      setState(() {
        _isTyping = false;
        _messages.add(AIMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: l10n.aiErrorMessage,
          isFromAI: true,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(max,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      } else {
        _scrollController.jumpTo(max);
      }
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
      appBar: const AIAssistantAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Responsive.maxContentWidth,
          ),
          child: Column(
            children: [
              Expanded(child: _buildMessageList()),
              if (_isTyping) const AITypingIndicator(),
              AIInputArea(
                controller: _messageController,
                isLoading: _isLoading,
                onSend: () => _sendMessage(_messageController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return AIMessageBubble(
          message: _messages[index],
          onSuggestionTap: _sendMessage,
        );
      },
    );
  }
}
