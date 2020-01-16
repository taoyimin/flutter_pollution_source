import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pollution_source/module/common/common_widget.dart';
import 'package:pollution_source/module/common/detail/detail_bloc.dart';
import 'package:pollution_source/module/common/detail/detail_event.dart';
import 'package:pollution_source/module/common/page/page_bloc.dart';
import 'package:pollution_source/module/common/page/page_event.dart';
import 'package:pollution_source/module/common/page/page_state.dart';
import 'package:pollution_source/module/common/upload/upload_bloc.dart';
import 'package:pollution_source/module/common/upload/upload_event.dart';
import 'package:pollution_source/module/common/upload/upload_state.dart';
import 'package:pollution_source/module/inspection/common/routine_inspection_upload_factor_model.dart';
import 'package:pollution_source/module/inspection/common/routine_inspection_upload_factor_repository.dart';
import 'package:pollution_source/module/inspection/common/routine_inspection_upload_list_model.dart';
import 'package:pollution_source/module/inspection/correct/air/upload/air_device_correct_upload_model.dart';
import 'package:pollution_source/res/colors.dart';
import 'package:pollution_source/res/gaps.dart';
import 'package:pollution_source/util/toast_utils.dart';
import 'package:pollution_source/widget/custom_header.dart';

class AirDeviceCorrectUploadPage extends StatefulWidget {
  final String json;

  AirDeviceCorrectUploadPage({
    this.json,
  });

  @override
  _AirDeviceCorrectUploadPageState createState() =>
      _AirDeviceCorrectUploadPageState();
}

class _AirDeviceCorrectUploadPageState
    extends State<AirDeviceCorrectUploadPage> {
  PageBloc _pageBloc;

  /// 加载因子信息Bloc
  DetailBloc _detailBloc;
  UploadBloc _uploadBloc;
  RoutineInspectionUploadList task;

  @override
  void initState() {
    super.initState();
    task = RoutineInspectionUploadList.fromJson(json.decode(widget.json));
    // 初始化页面Bloc
    _pageBloc = BlocProvider.of<PageBloc>(context);
    // 加载界面(默认有一条记录)
    _pageBloc.add(PageLoad(
        model: AirDeviceCorrectUpload(
      inspectionTaskId: task.inspectionTaskId,
    )));
    _detailBloc = BlocProvider.of<DetailBloc>(context);
    // 加载该设备的监测因子
    _detailBloc.add(DetailLoad(
        params: RoutineInspectionUploadFactorRepository.createParams(
      factorCode: task.factorCode,
      deviceId: task.deviceId,
      monitorId: task.monitorId,
    )));
    // 初始化上报Bloc
    _uploadBloc = BlocProvider.of<UploadBloc>(context);
  }

  @override
  void dispose() {
    // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EasyRefresh.custom(
        slivers: <Widget>[
          BlocBuilder<PageBloc, PageState>(
            builder: (context, state) {
              String enterName = '';
              String monitorName = '';
              String deviceName = '';
              String inspectionStartTime = '';
              String inspectionEndTime = '';
              if (state is PageLoaded) {
                enterName = task?.enterName ?? '';
                monitorName = task?.monitorName ?? '';
                deviceName = task?.deviceName ?? '';
                inspectionStartTime = task?.inspectionStartTime ?? '';
                inspectionEndTime = task?.inspectionEndTime ?? '';
              }
              return UploadHeaderWidget(
                title: '废气监测设备校准上报',
                subTitle: '''$enterName
监控点名：$monitorName
设备名称：$deviceName
开始日期：$inspectionStartTime
截至日期：$inspectionEndTime''',
                imagePath:
                    'assets/images/long_stop_report_upload_header_image.png',
                backgroundColor: Colours.primary_color,
              );
            },
          ),
          MultiBlocListener(
            listeners: [
              BlocListener<UploadBloc, UploadState>(
                listener: uploadListener,
              ),
              BlocListener<UploadBloc, UploadState>(
                listener: (context, state) {
                  if (state is UploadSuccess) {
                    Toast.show(state.message);
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
            child: BlocBuilder<PageBloc, PageState>(
              builder: (context, state) {
                if (state is PageLoaded) {
                  return _buildPageLoadedDetail(state.model);
                } else {
                  return ErrorSliver(
                      errorMessage: 'BlocBuilder监听到未知的的状态！state=$state');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageLoadedDetail(AirDeviceCorrectUpload airDeviceCorrectUpload) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            DetailRowWidget<RoutineInspectionUploadFactor>(
              title: '校准因子',
              content: airDeviceCorrectUpload?.factor?.factorName,
              detailBloc: _detailBloc,
              onLoaded: (RoutineInspectionUploadFactor factor) {
                _pageBloc.add(PageLoad(
                  model: airDeviceCorrectUpload.copyWith(factor: factor),
                ));
              },
              onErrorTap: () {
                // 加载失败后点击重新加载
                _detailBloc.add(DetailLoad(
                    params:
                        RoutineInspectionUploadFactorRepository.createParams(
                  factorCode: task.factorCode,
                  deviceId: task.deviceId,
                  monitorId: task.monitorId,
                )));
              },
            ),
            Gaps.hLine,
            DetailRowWidget<RoutineInspectionUploadFactor>(
              title: '计量单位',
              content: airDeviceCorrectUpload?.factor?.unit,
              detailBloc: _detailBloc,
              onLoaded: (RoutineInspectionUploadFactor factor) {},
              onErrorTap: () {
                // 加载失败后点击重新加载
                _detailBloc.add(DetailLoad(
                    params:
                        RoutineInspectionUploadFactorRepository.createParams(
                  factorCode: task.factorCode,
                  deviceId: task.deviceId,
                  monitorId: task.monitorId,
                )));
              },
            ),
            Gaps.hLine,
            DetailRowWidget<RoutineInspectionUploadFactor>(
              title: '分析仪量程',
              content: airDeviceCorrectUpload?.factor?.measureRange ?? '无',
              detailBloc: _detailBloc,
              onLoaded: (RoutineInspectionUploadFactor factor) {},
              onErrorTap: () {
                // 加载失败后点击重新加载
                _detailBloc.add(DetailLoad(
                    params:
                        RoutineInspectionUploadFactorRepository.createParams(
                  factorCode: task.factorCode,
                  deviceId: task.deviceId,
                  monitorId: task.monitorId,
                )));
              },
            ),
            Gaps.hLine,
            InfoRowWidget(
                title: '分析仪原理', content: task?.measurePrinciple ?? '无'),
            Gaps.hLine,
            SelectRowWidget(
              title: '校准开始时间',
              content: DateUtil.formatDate(
                  airDeviceCorrectUpload?.correctStartTime,
                  format: 'yyyy-MM-dd HH:mm'),
              onTap: () {
                DatePicker.showDatePicker(context,
                    locale: DateTimePickerLocale.zh_cn,
                    pickerMode: DateTimePickerMode.datetime,
                    onClose: () {}, onConfirm: (dateTime, selectedIndex) {
                  _pageBloc.add(PageLoad(
                      model: airDeviceCorrectUpload.copyWith(
                          correctStartTime: dateTime)));
                });
              },
            ),
            Gaps.hLine,
            SelectRowWidget(
              title: '校准结束时间',
              content: DateUtil.formatDate(
                  airDeviceCorrectUpload?.correctEndTime,
                  format: 'yyyy-MM-dd HH:mm'),
              onTap: () {
                DatePicker.showDatePicker(context,
                    locale: DateTimePickerLocale.zh_cn,
                    pickerMode: DateTimePickerMode.datetime,
                    onClose: () {}, onConfirm: (dateTime, selectedIndex) {
                  _pageBloc.add(PageLoad(
                      model: airDeviceCorrectUpload.copyWith(
                          correctEndTime: dateTime)));
                });
              },
            ),
            Gaps.hLine,
            Row(
              children: <Widget>[
                Container(
                  height: 46,
                  child: Center(
                    child: const Text(
                      '零点漂移校准',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '零气浓度值',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model: airDeviceCorrectUpload.copyWith(zeroVal: value)));
              },
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '上次校准后 测试值',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model:
                        airDeviceCorrectUpload.copyWith(beforeZeroVal: value)));
              },
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '校前测试值',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model: airDeviceCorrectUpload.copyWith(
                        correctZeroVal: value)));
              },
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '零点漂移 %F.S.',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model:
                        airDeviceCorrectUpload.copyWith(zeroPercent: value)));
              },
            ),
            Gaps.hLine,
            RadioRowWidget(
              title: '仪器校准是否正常',
              trueText: '正常',
              falseText: '不正常',
              checked: airDeviceCorrectUpload.zeroIsNormal,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model:
                        airDeviceCorrectUpload.copyWith(zeroIsNormal: value)));
              },
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '校准后测试值',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model: airDeviceCorrectUpload.copyWith(
                        zeroCorrectVal: value)));
              },
            ),
            Gaps.hLine,
            Row(
              children: <Widget>[
                Container(
                  height: 46,
                  child: Center(
                    child: const Text(
                      '量程漂移校准',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '标气浓度值',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model: airDeviceCorrectUpload.copyWith(rangeVal: value)));
              },
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '上次校准后 测试值',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model: airDeviceCorrectUpload.copyWith(
                        beforeRangeVal: value)));
              },
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '校前测试值',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model: airDeviceCorrectUpload.copyWith(
                        correctRangeVal: value)));
              },
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '量程漂移 %F.S.',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model:
                        airDeviceCorrectUpload.copyWith(rangePercent: value)));
              },
            ),
            Gaps.hLine,
            RadioRowWidget(
              title: '仪器校准是否正常',
              trueText: '正常',
              falseText: '不正常',
              checked: airDeviceCorrectUpload.rangeIsNormal,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model:
                        airDeviceCorrectUpload.copyWith(rangeIsNormal: value)));
              },
            ),
            Gaps.hLine,
            EditRowWidget(
              title: '校准后测试值',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pageBloc.add(PageLoad(
                    model: airDeviceCorrectUpload.copyWith(
                        rangeCorrectVal: value)));
              },
            ),
            Gaps.hLine,
            Gaps.vGap20,
            Row(
              children: <Widget>[
                ClipButton(
                  text: '提交',
                  icon: Icons.file_upload,
                  color: Colors.lightBlue,
                  onTap: () {
                    _uploadBloc.add(Upload(
                      data: airDeviceCorrectUpload,
                    ));
                  },
                ),
              ],
            ),
            Gaps.vGap20,
          ],
        ),
      ),
    );
  }
}