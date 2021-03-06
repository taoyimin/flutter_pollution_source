import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:pollution_source/http/dio_utils.dart';
import 'package:pollution_source/http/error_handle.dart';
import 'package:pollution_source/module/common/common_widget.dart';
import 'package:pollution_source/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pollution_source/res/constant.dart';
import 'package:pollution_source/res/gaps.dart';
import 'package:pollution_source/route/application.dart';
import 'package:pollution_source/route/routes.dart';
import 'package:pollution_source/util/file_utils.dart';
import 'package:pollution_source/util/system_utils.dart';
import 'package:pollution_source/util/toast_utils.dart';
import 'package:pollution_source/util/ui_utils.dart';

/// 个人中心界面
class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final double _headerHeight = 300;
  final double _headerBgHeight = 230;
  final double _cardHeight = 200;
  final double _cardMarginBottom = 30;
  String version;

  @override
  void initState() {
    super.initState();
    if (!SystemUtils.isWeb) {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        setState(() {
          version = packageInfo.version;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(0xFFFFEB5E),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(0xFFFAFAFA),
                  ),
                ),
              ],
            ),
          ),
          EasyRefresh.custom(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  // 顶部栏
                  Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: _headerHeight,
                        color: Color(0xFFFAFAFA),
                      ),
                      ClipPath(
                        clipper: TopBarClipper(
                            MediaQuery.of(context).size.width, _headerBgHeight),
                        child: Container(
                          height: _headerBgHeight,
                          width: double.infinity,
                          child: Image.asset(
                            "assets/images/mine_header_bg.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: _cardMarginBottom,
                        right: 10,
                        left: 10,
                        child: ClipPath(
                          clipper: TopCardClipper(
                              MediaQuery.of(context).size.width,
                              _headerBgHeight),
                          child: Container(
                            height: _cardHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                UIUtils.getBoxShadow(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: _headerHeight -
                            _cardMarginBottom -
                            _cardHeight +
                            10,
                        right: 56,
                        left: 56,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 90,
                              width: 90,
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                    "assets/images/mine_user_header.png"),
                              ),
                            ),
                            Gaps.vGap8,
                            AutoSizeText(
                              '${SpUtil.getString(Constant.spRealName)}',
                              style: const TextStyle(fontSize: 23),
                              maxLines: 1,
                            ),
                            Gaps.vGap8,
                            Text(
                              '登录时间：${SpUtil.getString(Constant.spLoginTime, defValue: '未知')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colours.secondary_text,
                              ),
                            ),
                            Gaps.vGap8,
                            GestureDetector(
                              onDoubleTap: () async {
                                SpUtil.putBool(
                                    Constant.spDebug,
                                    !SpUtil.getBool(Constant.spDebug,
                                        defValue: false));
                                if (SpUtil.getBool(Constant.spDebug,
                                    defValue: false)) {
                                  Toast.show('已开启Debug模式');
                                  try {
                                    JPush jpush = JPush();
                                    bool isNotificationEnabled =
                                        await jpush.isNotificationEnabled();
                                    Map tags = await jpush.getAllTags();
                                    String configInfo = '''推送权限：${isNotificationEnabled ? '已开启' : '未开启'}
设备别名：${SpUtil.getString(Constant.spAlias, defValue: '')}
设备标签：${tags['tags']}''';
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('配置信息'),
                                          content: Text(configInfo),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: configInfo));
                                                Toast.show('复制到剪贴板成功！');
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("复制"),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("确定"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    Toast.show('获取推送配置信息失败！错误信息：$e');
                                  }
                                } else {
                                  Toast.show('已关闭Debug模式');
                                }
                                // 重新创建Dio实例
                                PollutionDioUtils.internal();
                                OperationDioUtils.internal();
                              },
                              child: Text(
                                '当前版本号：${version ?? '未知'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colours.secondary_text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
//                      Positioned(
//                        bottom: 140,
//                        right: 50,
//                        child: GestureDetector(
//                          onTap: () async {
//                            await BarcodeScanner.scan();
//                          },
//                          child: Image.asset(
//                            "assets/images/icon_QR_code.png",
//                            width: 23,
//                            height: 23,
//                            fit: BoxFit.cover,
//                          ),
//                        ),
//                      ),
//                      Positioned(
//                        top: SystemUtils.isWeb ? 16 : 36,
//                        left: 16,
//                        child: Icon(
//                          Icons.notifications_none,
//                          color: Colors.white,
//                        ),
//                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    color: Color(0xFFFAFAFA),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "常用功能",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Gaps.vGap10,
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              UIUtils.getBoxShadow(),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              GridView(
                                shrinkWrap: true,
                                primary: false,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                ),
                                children: <Widget>[
                                  InkWellButton(
                                    onTap: () async {
                                      bool success = await Application.router
                                          .navigateTo(context,
                                              '${Routes.changePassword}');
                                      if (success ?? false) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('密码修改成功！'),
                                            action: SnackBarAction(
                                                label: '我知道了',
                                                textColor:
                                                    Colours.primary_color,
                                                onPressed: () {}),
                                          ),
                                        );
                                      }
                                    },
                                    children: <Widget>[
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              "assets/images/icon_change_password.png",
                                              width: 30,
                                              height: 30,
                                            ),
                                            const Text(
                                              "修改密码",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Colours.secondary_text),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWellButton(
                                    alignment: Alignment.center,
                                    onTap: () async {
                                      try {
                                        bool hasUpdate =
                                            await SystemUtils.checkUpdate(
                                                context);
                                        if (!hasUpdate) {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('已经是最新版本'),
                                              action: SnackBarAction(
                                                  label: '我知道了',
                                                  textColor:
                                                      Colours.primary_color,
                                                  onPressed: () {}),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${ExceptionHandle.handleException(e).msg}'),
                                            action: SnackBarAction(
                                                label: '我知道了',
                                                textColor:
                                                    Colours.primary_color,
                                                onPressed: () {}),
                                          ),
                                        );
                                      }
                                    },
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            "assets/images/icon_check_update.png",
                                            width: 30,
                                            height: 30,
                                          ),
                                          const Text(
                                            "版本更新",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colours.secondary_text),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  InkWellButton(
                                    alignment: Alignment.center,
                                    onTap: () {
                                      if (SystemUtils.isWeb) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Web平台不支持分享产品'),
                                            action: SnackBarAction(
                                                label: '我知道了',
                                                textColor:
                                                    Colours.primary_color,
                                                onPressed: () {}),
                                          ),
                                        );
                                      } else if (Platform.isAndroid) {
                                        Application.router.navigateTo(
                                            context, '${Routes.shareProduct}');
                                      } else {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('当前平台不支持分享产品'),
                                            action: SnackBarAction(
                                                label: '我知道了',
                                                textColor:
                                                    Colours.primary_color,
                                                onPressed: () {}),
                                          ),
                                        );
                                      }
                                    },
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            "assets/images/icon_share_product.png",
                                            width: 30,
                                            height: 30,
                                          ),
                                          const Text(
                                            "分享产品",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colours.secondary_text),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  InkWellButton(
                                    alignment: Alignment.center,
                                    onTap: () {
                                      if (SystemUtils.isWeb) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Web平台不支持清理缓存'),
                                            action: SnackBarAction(
                                                label: '我知道了',
                                                textColor:
                                                    Colours.primary_color,
                                                onPressed: () {}),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('清理缓存'),
                                              content: CacheTextWidget(),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('取消'),
                                                ),
                                                FlatButton(
                                                  onPressed: () async {
                                                    await FileUtils
                                                        .clearApplicationDirectory();
                                                    Toast.show('清理附件成功！');
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('确定'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            "assets/images/icon_clear_cache.png",
                                            width: 30,
                                            height: 30,
                                          ),
                                          const Text(
                                            '清理缓存',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colours.secondary_text),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  InkWellButton(
                                    alignment: Alignment.center,
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('注销登录'),
                                              content: const Text(
                                                  "是否确定注销当前登录用户并返回登录界面？"),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("取消"),
                                                ),
                                                FlatButton(
                                                  onPressed: () async {
                                                    // 清空密码
                                                    SpUtil.remove(Constant
                                                            .spPasswordList[
                                                        SpUtil.getInt(Constant
                                                            .spUserType)]);
                                                    // 清空用户名
                                                    SpUtil.remove(
                                                        Constant.spRealName);
                                                    // 清空userId
                                                    SpUtil.remove(
                                                        Constant.spUserId);
                                                    // 清空token
                                                    SpUtil.remove(
                                                        Constant.spToken);
                                                    // 清空登录时间
                                                    SpUtil.remove(
                                                        Constant.spLoginTime);
                                                    try {
                                                      // 删除别名和标签
                                                      JPush jpush = JPush();
                                                      jpush
                                                          .deleteAlias()
                                                          .then((map) {
                                                        SpUtil.putString(
                                                            Constant.spAlias,
                                                            map['alias']);
                                                      });
                                                      jpush.deleteTags([
                                                        Constant.userTags[SpUtil
                                                            .getInt(Constant
                                                                .spUserType)]
                                                      ]);
                                                    } catch (e) {
                                                      Toast.show(
                                                          '删除别名和标签失败！错误信息：$e');
                                                    }
                                                    Navigator.of(context).pop();
                                                    Application.router
                                                        .navigateTo(context,
                                                            '${Routes.root}',
                                                            clearStack: true);
                                                  },
                                                  child: const Text("确定"),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            "assets/images/icon_login_out.png",
                                            width: 30,
                                            height: 30,
                                          ),
                                          const Text(
                                            "注销登录",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colours.secondary_text),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 个人中心顶部栏裁剪
class TopBarClipper extends CustomClipper<Path> {
  // 宽高
  double width;
  double height;

  TopBarClipper(this.width, this.height);

  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(width, 0.0);
    path.lineTo(width, height / 2);
    path.lineTo(0.0, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

/// 个人中心顶部Card裁剪
class TopCardClipper extends CustomClipper<Path> {
  // 宽高
  double width;
  double height;

  TopCardClipper(this.width, this.height);

  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.moveTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, 0);
    path.lineTo(0, height / 2);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
