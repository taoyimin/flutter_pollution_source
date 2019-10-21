import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:pollution_source/http/dio_utils.dart';
import 'package:pollution_source/http/http.dart';
import 'package:pollution_source/module/enter/list/enter_list.dart';
import 'package:pollution_source/util/constant.dart';

class EnterListBloc extends Bloc<EnterListEvent, EnterListState> {
  @override
  EnterListState get initialState => EnterListLoading();

  @override
  Stream<EnterListState> mapEventToState(EnterListEvent event) async* {
    try {
      if (event is EnterListLoad) {
        yield* _mapEnterListLoadToState(event);
      }
    } catch (e) {
      yield EnterListError(
          errorMessage: ExceptionHandle.handleException(e).msg);
    }
  }

  Stream<EnterListState> _mapEnterListLoadToState(EnterListLoad event) async* {
    final currentState = state;
    //加载企业列表
    if (!event.isRefresh && currentState is EnterListLoaded) {
      //加载更多
      final enterList = await getEnterList(
        currentPage: currentState.currentPage + 1,
        enterName: event.enterName,
        areaCode: event.areaCode,
        state: event.state,
        enterType: event.enterType,
        attentionLevel: event.attentionLevel,
      );
      yield EnterListLoaded(
        enterList: currentState.enterList + enterList,
        currentPage: currentState.currentPage + 1,
        hasNextPage:
        currentState.pageSize == enterList.length,
      );
    } else {
      //首次加载或刷新
      final enterList = await getEnterList(
        enterName: event.enterName,
        areaCode: event.areaCode,
        state: event.state,
        enterType: event.enterType,
        attentionLevel: event.attentionLevel,
      );
      if (enterList.length == 0) {
        //没有数据
        yield EnterListEmpty();
      } else {
        yield EnterListLoaded(
          enterList: enterList,
          hasNextPage: Constant.defaultPageSize == enterList.length,
        );
      }
    }
  }

  //获取企业列表数据
  Future<List<Enter>> getEnterList({
    currentPage = Constant.defaultCurrentPage,
    pageSize = Constant.defaultPageSize,
    enterName = '',
    areaCode = '',
    state = '',
    enterType = '',
    attentionLevel = '',
  }) async {
    Response response = await DioUtils.instance
        .getDio()
        .get(HttpApi.enterList, queryParameters: {
      'currentPage': currentPage,
      'pageSize': pageSize,
      'enterpriseName': enterName,
      'areaCode': areaCode,
      'state': state,
      'enterpriseType': enterType,
      'attenLevel': attentionLevel,
    });
    return convertEnterList(
        response.data[Constant.responseDataKey][Constant.responseListKey]);
  }

  //格式化企业数据
  List<Enter> convertEnterList(List<dynamic> jsonArray) {
    return jsonArray.map((json) {
      return Enter.fromJson(json);
    }).toList();
  }
}
