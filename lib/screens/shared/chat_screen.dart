import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/snackbar/app_snackbar.dart';
import '../../widgets/messaging/messaging_widgets_exports.dart';
import '../../core/blocs/session/session_bloc.dart';
import '../../core/blocs/booking/booking_exports.dart';

/// Écran de chat pour une conversation.
class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MessagingBloc _messagingBloc;
  final MessagingStorageService _storageService = MessagingStorageService();

  // Audio recording
  final AudioRecordService _audioService = AudioRecordService();
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  String? _recordedAudioPath;
  bool _showAudioPreview = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _messagingBloc = context.read<MessagingBloc>();
    _messagingBloc.add(OpenConversationEvent(conversationId: widget.conversationId));
  }

  @override
  void dispose() {
    _messagingBloc.add(const CloseConversationEvent());
    _recordingTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  String get _currentUserId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticatedState ? authState.user.id : '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagingBloc, MessagingState>(
      builder: (context, state) {
        if (state is MessagingLoadingState) {
          return _buildLoadingScaffold();
        }
        if (state is MessagingErrorState) {
          return _buildErrorScaffold(state.message);
        }
        if (state is ChatOpenState) {
          return _buildChatScaffold(state);
        }
        return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
      },
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('Chargement...')),
      body: const AppLoader(),
    );
  }

  Widget _buildErrorScaffold(String message) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.circleExclamation, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  Widget _buildChatScaffold(ChatOpenState state) {
    return Scaffold(
      appBar: _buildAppBar(state.conversation),
      body: ChatView(
        conversation: state.conversation,
        messages: state.messages,
        currentUserId: _currentUserId,
        isLoadingMore: state.isLoadingMore,
        hasMoreMessages: state.hasMoreMessages,
        isSending: state.isSending,
        isRecording: _isRecording,
        showAudioPreview: _showAudioPreview,
        audioPreviewWidget: _showAudioPreview && _recordedAudioPath != null
            ? AudioPreviewWidget(
                audioPath: _recordedAudioPath!,
                duration: _recordingDuration,
                onSend: _sendAudioMessage,
                onDelete: _cancelAudioPreview,
              )
            : null,
        recordingOverlay: AudioRecordingOverlay(duration: _recordingDuration),
        onSendText: (text) => context.read<MessagingBloc>().add(SendTextMessageEvent(text: text)),
        onLoadMore: () => context.read<MessagingBloc>().add(const LoadMoreMessagesEvent()),
        onMessageLongPress: (message) => _showMessageOptions(message, state),
        onAttachmentTap: _handleAttachmentTap,
        onMicLongPressStart: _startRecording,
        onMicLongPressEnd: _stopRecording,
        businessObjectBuilder: _buildBusinessObjectCard,
        reactionBuilder: (reactions, userId) => ReactionDisplay(
          reactions: reactions,
          currentUserId: userId,
          onReactionTap: (emoji) {
            final message = state.messages.firstWhere(
              (m) => m.reactions == reactions,
              orElse: () => state.messages.first,
            );
            context.read<MessagingBloc>().add(ToggleReactionEvent(messageId: message.id, emoji: emoji));
          },
        ),
        onReactionTap: (message, emoji) {
          context.read<MessagingBloc>().add(ToggleReactionEvent(messageId: message.id, emoji: emoji));
        },
      ),
    );
  }

  AppBar _buildAppBar(BaseConversation conversation) {
    final theme = Theme.of(context);
    final displayName = conversation.getDisplayName(_currentUserId);
    final avatarUrl = conversation.getAvatarUrl(_currentUserId);

    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          _buildAvatar(displayName, avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (conversation.type == ConversationType.group)
                  Text(
                    '${conversation.participantIds.length} participants',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/conversations/${conversation.id}/settings'),
          icon: const FaIcon(FontAwesomeIcons.circleInfo, size: 20),
        ),
      ],
    );
  }

  Widget _buildAvatar(String name, String? avatarUrl) {
    final theme = Theme.of(context);
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl));
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(initial, style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
    );
  }

  void _showMessageOptions(BaseMessage message, ChatOpenState state) {
    MessageOptionsSheet.show(
      context: context,
      message: message,
      isMe: message.senderId == _currentUserId,
      currentUserId: _currentUserId,
      onReactionTap: (emoji) {
        context.read<MessagingBloc>().add(ToggleReactionEvent(messageId: message.id, emoji: emoji));
      },
      onCopy: message.text != null && message.text!.isNotEmpty ? () {} : null,
      onDelete: message.senderId == _currentUserId && !message.isDeleted
          ? () => context.read<MessagingBloc>().add(DeleteMessageEvent(messageId: message.id))
          : null,
    );
  }

  void _handleAttachmentTap() {
    AttachmentOptionsSheet.show(
      context: context,
      onFilePickerTap: _showFilePicker,
      onBusinessObjectTap: _showBusinessObjectSelector,
    );
  }

  void _showFilePicker() {
    FilePickerBottomSheet.show(
      context,
      onFilePicked: (result) async {
        setState(() => _isUploading = true);
        try {
          final uploadResult = await _storageService.uploadFile(
            file: result.file,
            conversationId: widget.conversationId,
          );
          if (!mounted) return;
          if (uploadResult.isSuccess && uploadResult.data != null) {
            context.read<MessagingBloc>().add(SendAttachmentMessageEvent(attachment: uploadResult.data!));
          } else {
            AppSnackBar.error(context, uploadResult.message);
          }
        } finally {
          if (mounted) setState(() => _isUploading = false);
        }
      },
    );
  }

  void _showBusinessObjectSelector() {
    final sessions = context.read<SessionBloc>().state.sessions;
    final bookings = context.read<BookingBloc>().state.bookings;

    BusinessObjectSelectorBottomSheet.show(
      context,
      sessions: sessions,
      bookings: bookings,
      onSelected: (attachment) {
        context.read<MessagingBloc>().add(SendBusinessObjectMessageEvent(businessObject: attachment));
      },
    );
  }

  Widget _buildBusinessObjectCard(BusinessObjectAttachment bo, bool isMe) {
    switch (bo.objectType) {
      case 'session':
        return SessionMessageCard(businessObject: bo, isMe: isMe);
      case 'booking':
        return BookingMessageCard(businessObject: bo, isMe: isMe);
      default:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(bo.title),
        );
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _audioService.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        AppSnackBar.error(context, 'Permission microphone refusée');
      }
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioService.startRecording(filePath);

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() => _recordingDuration++);
      });
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Erreur enregistrement: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    _recordingTimer?.cancel();

    try {
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordedAudioPath = path;
        _showAudioPreview = path != null && _recordingDuration >= 1;
      });

      if (_recordingDuration < 1) {
        _cancelAudioPreview();
        if (mounted) {
          AppSnackBar.warning(context, 'Enregistrement trop court');
        }
      }
    } catch (e) {
      setState(() => _isRecording = false);
      if (mounted) {
        AppSnackBar.error(context, 'Erreur arrêt enregistrement: $e');
      }
    }
  }

  Future<void> _sendAudioMessage() async {
    if (_recordedAudioPath == null || _isUploading) return;
    setState(() => _isUploading = true);

    try {
      final result = await _storageService.uploadAudio(
        file: File(_recordedAudioPath!),
        conversationId: widget.conversationId,
        durationSeconds: _recordingDuration,
      );

      if (!mounted) return;

      if (result.isSuccess && result.data != null) {
        context.read<MessagingBloc>().add(SendAudioMessageEvent(audio: result.data!));
        _cancelAudioPreview();
      } else {
        AppSnackBar.error(context, result.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Erreur envoi audio: $e');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _cancelAudioPreview() {
    if (_recordedAudioPath != null) {
      final file = File(_recordedAudioPath!);
      if (file.existsSync()) file.deleteSync();
    }
    setState(() {
      _recordedAudioPath = null;
      _showAudioPreview = false;
      _recordingDuration = 0;
    });
  }
}
