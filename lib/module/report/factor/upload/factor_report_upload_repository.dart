import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:pollution_source/http/error_handle.dart';
import 'package:pollution_source/http/http_api.dart';
import 'package:pollution_source/module/common/upload/upload_repository.dart';
import 'package:pollution_source/module/report/factor/upload/factor_report_upload_model.dart';

class FactorReportUploadRepository
    extends UploadRepository<FactorReportUpload, String> {
  checkData(FactorReportUpload data) {
    if (data.enter == null)
      throw DioError(error: InvalidParamException('请选择企业'));
    if (data.monitor == null)
      throw DioError(error: InvalidParamException('请选择监控点'));
    if (data.monitor.dischargeId == null) {
      throw DioError(
          error: InvalidParamException(
              'monitorId=${data.monitor.monitorId}的监控点没有对应的排口Id'));
    }
    if (data.alarmTypeList == null || data.alarmTypeList.length == 0)
      throw DioError(error: InvalidParamException('请选择异常类型'));
    if (data.factorCodeList == null || data.factorCodeList.length == 0)
      throw DioError(error: InvalidParamException('请选择异常因子'));
    if (data.startTime == null)
      throw DioError(error: InvalidParamException('请选择开始时间'));
    if (data.endTime == null)
      throw DioError(error: InvalidParamException('请选择结束时间'));
    if (data.alarmTypeList.length == 1 && data.alarmTypeList[0].code == 'fault' && data.endTime.difference(data.startTime).inMinutes > data.limitDay * 24 * 60)
      throw DioError(error: InvalidParamException('当异常类型为${data.alarmTypeList[0].name}时,开始时间和结束时间间隔不能超过${data.limitDay}天'));
    if (TextUtil.isEmpty(data.exceptionReason.text))
      throw DioError(error: InvalidParamException('请输入异常原因'));
    if (data.attachments == null || data.attachments.length == 0)
      throw DioError(error: InvalidParamException('请选择附件上传'));
  }

  @override
  HttpApi createApi() {
    return HttpApi.factorReportUpload;
  }

  @override
  Future<FormData> createFormData(FactorReportUpload data) async {
    return FormData.fromMap({
      'enterId': data.enter.enterId,
      'outId': data.monitor.dischargeId,
      'monitorId': data.monitor.monitorId,
      'startTime': data.startTime.toString(),
      'endTime': data.endTime.toString(),
      'alarmType':
          data.alarmTypeList.map((dataDict) => dataDict.code).join(','),
      'factorCode':
          data.factorCodeList.map((dataDict) => dataDict.code).join(','),
      'exceptionReason': data.exceptionReason.text,
      "file": await Future.wait(data.attachments?.map((asset) async {
            ByteData byteData = await asset.getByteData();
            return MultipartFile.fromBytes(byteData.buffer.asUint8List(),
                filename: asset.name);
          })?.toList() ??
          [])
    });
  }
}
