// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Process _$ProcessFromJson(Map<String, dynamic> json) {
  return Process(
    operateTypeStr: json['dicSubName'] as String ?? '',
    operatePerson: json['operatePersonName'] as String ?? '',
    alarmCauseStr: json['alarmCauseStr'] as String ?? '',
    operateResult: json['operateResult'] as String ?? '',
    operateTimeStr: json['operateTime'] as String ?? '',
    operateDesc: json['operateDesc'] as String ?? '',
    attachments: (json['attachmentList'] as List)
            ?.map((e) => e == null
                ? null
                : Attachment.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
    mobileLawList: (json['enforcements'] as List)
            ?.map((e) => e == null
                ? null
                : MobileLaw.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$ProcessToJson(Process instance) => <String, dynamic>{
      'dicSubName': instance.operateTypeStr,
      'operateTime': instance.operateTimeStr,
      'operatePersonName': instance.operatePerson,
      'alarmCauseStr': instance.alarmCauseStr,
      'operateResult': instance.operateResult,
      'operateDesc': instance.operateDesc,
      'attachmentList': instance.attachments,
      'enforcements': instance.mobileLawList,
    };
