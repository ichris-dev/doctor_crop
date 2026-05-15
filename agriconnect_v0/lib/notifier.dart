// session_notifier.dart
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class SessionUser {
  final int userId;
  final String fullName;
  final String phoneNumber;

  const SessionUser({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
  });
}

// null means no user logged in
ValueNotifier<SessionUser?> sessionNotifier = ValueNotifier(null);

class ChatPreview {
  final String conversationId;
  final String fullName;
  final String phoneNumber;
  final String? lastMessage; // nullable — no messages yet = null
  final DateTime? lastMessageTime;

  ChatPreview({
    required this.conversationId,
    required this.fullName,
    required this.phoneNumber,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      conversationId: json['conversation_id'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'].toString())
          : null,
    );
  }
}

ValueNotifier<List<ChatPreview>> chatsNotifier = ValueNotifier([]);

class UserInfo {
  final int user_id;
  final String fullName;
  final String location;
  final String phoneNumber;

  const UserInfo({
    required this.user_id,
    required this.fullName,
    required this.location,
    required this.phoneNumber,
  });
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      user_id: json['user_id'],
      fullName: json['full_name'],
      location: json['location'],
      phoneNumber: json['phone_number'],
    );
  }
}

ValueNotifier<List<UserInfo>?> fetchedUsers = ValueNotifier([]);

class UserChats {
  final int messageId;
  final String message;
  final DateTime createdAt;
  final int senderId;
  final int receiverId;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final bool isMine;

  UserChats({
    required this.messageId,
    required this.message,
    required this.createdAt,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.isMine,
  });

  factory UserChats.fromJson(Map<String, dynamic> json) {
    return UserChats(
      messageId: json['message_id'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      senderId: json['sender_id'] as int? ?? 0,
      receiverId: json['receiver_id'] as int? ?? 0,
      senderName: json['sender_name'] as String? ?? '',
      senderPhone: json['sender_phone'] as String? ?? '',
      receiverName: json['receiver_name'] as String? ?? '',
      receiverPhone: json['receiver_phone'] as String? ?? '',
      isMine: json['is_mine'] as bool? ?? false,
    );
  }
}

ValueNotifier<List<UserChats>> fetchChats = ValueNotifier([]);

class Product {
  final int id;
  final int storeId;
  final String productName;
  final String description;
  final int priceRwf;
  final String imageUrl;
  final String location;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.storeId,
    required this.productName,
    required this.description,
    required this.priceRwf,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      storeId: json['store_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceRwf: json['price_rwf'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      location: json['location'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }
}

// Add this global notifier
ValueNotifier<List<Product>> fetchedProducts = ValueNotifier([]);

// ── Store session ──────────────────────────────────────────────────────────────

class StoreSession {
  final int storeId;
  final String storeName;
  final String storePhone;
  final String storeLocation;
  final String createdAt;
  final List<StoreProduct> products;

  const StoreSession({
    required this.storeId,
    required this.storeName,
    required this.storePhone,
    required this.storeLocation,
    required this.createdAt,
    required this.products,
  });

  factory StoreSession.fromJson(
    Map<String, dynamic> json,
    List<StoreProduct> products,
  ) {
    return StoreSession(
      storeId: json['store_id'] as int? ?? 0,
      storeName: json['store_name'] as String? ?? '',
      storePhone: json['store_phone'] as String? ?? '',
      storeLocation: json['store_location'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      products: products,
    );
  }
}

class StoreProduct {
  final int id;
  final int storeId;
  final String productName;
  final String description;
  final int priceRwf;
  final String imageUrl;
  final String location;
  final DateTime createdAt;

  const StoreProduct({
    required this.id,
    required this.storeId,
    required this.productName,
    required this.description,
    required this.priceRwf,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: json['id'] as int? ?? 0,
      storeId: json['store_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priceRwf: json['price_rwf'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      location: json['location'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }
}

// null = user has no store
ValueNotifier<StoreSession?> storeSessionNotifier = ValueNotifier(null);
