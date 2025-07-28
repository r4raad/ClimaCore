import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  user,
  ai,
  system,
}

enum MessageStatus {
  sending,
  sent,
  error,
}

class AIMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? userId;
  final String? conversationId;
  final Map<String, dynamic>? metadata;

  AIMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.status,
    this.userId,
    this.conversationId,
    this.metadata,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.user,
      ),
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      userId: json['userId'],
      conversationId: json['conversationId'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.toString().split('.').last,
      'userId': userId,
      'conversationId': conversationId,
      'metadata': metadata,
    };
  }

  AIMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? userId,
    String? conversationId,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      metadata: metadata ?? this.metadata,
    );
  }
}

class AIConversation {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final List<AIMessage> messages;
  final Map<String, dynamic>? settings;

  AIConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    this.lastMessageAt,
    required this.messages,
    this.settings,
  });

  factory AIConversation.fromJson(Map<String, dynamic> json) {
    return AIConversation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastMessageAt: json['lastMessageAt'] is Timestamp 
          ? (json['lastMessageAt'] as Timestamp).toDate()
          : null,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => AIMessage.fromJson(m))
          .toList() ?? [],
      settings: json['settings'] != null 
          ? Map<String, dynamic>.from(json['settings'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'messages': messages.map((m) => m.toJson()).toList(),
      'settings': settings,
    };
  }

  AIConversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<AIMessage>? messages,
    Map<String, dynamic>? settings,
  }) {
    return AIConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
      settings: settings ?? this.settings,
    );
  }
}

class AIResponse {
  final String content;
  final Map<String, dynamic>? metadata;
  final bool isError;
  final String? errorMessage;

  AIResponse({
    required this.content,
    this.metadata,
    this.isError = false,
    this.errorMessage,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      content: json['content'] ?? '',
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      isError: json['isError'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'metadata': metadata,
      'isError': isError,
      'errorMessage': errorMessage,
    };
  }
} 