import 'dart:async';
import 'dart:typed_data';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:pollution_source/http/error_handle.dart';
import 'package:pollution_source/http/http_api.dart';
import 'package:pollution_source/module/common/upload/upload_repository.dart';
import 'package:pollution_source/module/process/upload/process_upload_model.dart';

class ProcessUploadRepository extends UploadRepository<ProcessUpload, String> {
  @override
  checkData(ProcessUpload data) {
    if (TextUtil.isEmpty(data.orderId))
      throw DioError(error: InvalidParamException('报警管理单Id为空'));
    if (TextUtil.isEmpty(data.operatePerson))
      throw DioError(error: InvalidParamException('请输入操作人'));
    if (TextUtil.isEmpty(data.operateType))
      throw DioError(error: InvalidParamException('操作类型为空'));
    if (TextUtil.isEmpty(data.operateDesc))
      throw DioError(error: InvalidParamException('请输入操作描述'));
    if (data.attachments == null || data.attachments.length == 0)
      throw DioError(error: InvalidParamException('请选择附件上传'));
  }

  @override
  HttpApi createApi() {
    return HttpApi.processesUpload;
  }

  @override
  Future<FormData> createFormData(ProcessUpload data) async {
    return FormData.fromMap({
      'id': data.orderId,
      'orderId': data.orderId,
      'operatePerson': data.operatePerson,
      'operateType': data.operateType,
      'operateDesc': data.operateDesc,
      "file": await Future.wait(data.attachments?.map((asset) async {
        ByteData byteData = await asset.getByteData();
        return MultipartFile.fromBytes(byteData.buffer.asUint8List(),
            filename: asset.name);
      })?.toList() ??
          [])
    });
  }
}