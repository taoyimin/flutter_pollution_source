import 'package:flutter/material.dart';
import 'package:flutter_bmflocation/flutter_baidu_location.dart';
import 'package:pollution_source/util/common_utils.dart';

/// 废气监测设备校验上报
class AirDeviceCheckUpload {
  /// 任务id
  String inspectionTaskId;

  /// 任务类型
  String itemType;

  /// 位置信息
  BaiduLocation baiduLocation;

  /// 校验因子名称
  String factorName;

  /// 校验因子代码
  String factorCode;

  /// 校验因子单位
  String factorUnit;

  /// 校验记录
  List<AirDeviceCheckRecord> airDeviceCheckRecordList;

  /// 如校验合格前对系统进行过处理、调整、参数修改，请说明
  final TextEditingController paramRemark = TextEditingController();

  /// 如校验后，颗粒物测量仪、流速仪的原校正系统改动，请说明
  final TextEditingController changeRemark = TextEditingController();

  /// 总体校验是否合格
  final TextEditingController checkResult = TextEditingController();

  AirDeviceCheckUpload({this.inspectionTaskId, this.itemType});

  /// 获取参比方法测量值平均值
  String get compareAvgVal {
    try {
      if (airDeviceCheckRecordList == null) {
        return '';
      }
      var tempList = airDeviceCheckRecordList
          .where((item) => CommonUtils.isNumeric(item.currentCheckResult.text));
      if (tempList.length == 0) {
        return '';
      }
      return (tempList
                  .map((item) => double.tryParse(item.currentCheckResult.text))
                  .reduce((a, b) => a + b) /
              tempList.length)
          .toStringAsFixed(4);
    } catch (e) {
      return '';
    }
  }

  /// 获取CEMS 测量值平均值
  String get cemsAvgVal {
    try {
      if (airDeviceCheckRecordList == null) {
        return '';
      }
      var tempList = airDeviceCheckRecordList
          .where((item) => CommonUtils.isNumeric(item.currentCheckIsPass.text));
      if (tempList.length == 0) {
        return '';
      }
      return (tempList
                  .map((item) => double.tryParse(item.currentCheckIsPass.text))
                  .reduce((a, b) => a + b) /
              tempList.length)
          .toStringAsFixed(4);
    } catch (e) {
      return '';
    }
  }
}

/// 废气监测设备校验记录
class AirDeviceCheckRecord {
  /// 监测时间
  DateTime currentCheckTime;

  /// 参比方法测量值
  final TextEditingController currentCheckResult = TextEditingController();

  /// CEMS测量值
  final TextEditingController currentCheckIsPass = TextEditingController();
}
