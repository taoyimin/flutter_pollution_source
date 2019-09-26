import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class IndexState extends Equatable {
  IndexState([List props = const []]) : super(props);
}

//首页首次进入的加载状态
class IndexLoading extends IndexState {
  @override
  String toString() => 'IndexLoading';
}

//首页加载完成状态
class IndexLoaded extends IndexState {
  final aqiStatistics;
  final aqiExamineList;
  final surfaceWaterList;

  IndexLoaded({
    @required this.aqiStatistics,
    @required this.aqiExamineList,
    @required this.surfaceWaterList,
  }) : super([aqiStatistics, aqiExamineList, surfaceWaterList]);

  @override
  String toString() => 'IndexLoaded';
}

//首页刷新完成状态
class IndexRefreshed extends IndexState {
  final aqiStatistics;

  IndexRefreshed({
    @required this.aqiStatistics,
  }) : super([aqiStatistics]);

  @override
  String toString() => 'IndexRefreshed';
}

//首页发生错误的状态
class IndexError extends IndexState {
  @override
  String toString() => 'IndexError';
}