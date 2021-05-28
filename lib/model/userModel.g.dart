// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
    json['_id'] as String,
    json['email'] as String,
    json['receive_notification'] as bool,
    json['role'] as String,
    json['token'] as String,
  );
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      '_id': instance.id,
      'email': instance.email,
      'receive_notification': instance.receiveNotification,
      'role': instance.role,
      'token': instance.token,
    };
