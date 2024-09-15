import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:netease_cloud_music_app/common/constants/colors.dart';
import 'package:netease_cloud_music_app/common/constants/url.dart';
import 'package:netease_cloud_music_app/common/utils/image_utils.dart';
import 'package:netease_cloud_music_app/common/utils/log_box.dart';
import 'package:netease_cloud_music_app/pages/roaming/play_album_cover.dart';
import 'package:netease_cloud_music_app/pages/roaming/roaming_controller.dart';
import 'package:netease_cloud_music_app/pages/roaming/widgets/play_list.dart';

import '../../common/music_handler.dart';
import 'dart:math' as math;

class Roaming extends StatefulWidget {
  const Roaming({super.key});

  static void showBottomPlayer(BuildContext hostContext) {
    showGeneralDialog(
      context: hostContext,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 200),
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset(0, 0),
          ).animate(animation1),
          child: child,
        );
      },
      pageBuilder: (context, animation1, animation2) {
        // 在弹窗中获取当前页面的安全区域padding
        // https://stackoverflow.com/questions/49737225/safearea-not-working-in-persistent-bottomsheet-in-flutter
        final view = View.of(context);
        final viewPadding = view.padding;
        final mediaPadding = MediaQuery.paddingOf(context);
        final viewTopPadding = viewPadding.top / view.devicePixelRatio;
        final topPadding = math.max(viewTopPadding, mediaPadding.top);

        return Material(
          child: Container(
            padding:
                EdgeInsets.only(top: topPadding, bottom: mediaPadding.bottom),
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppTheme.playPageBackgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.w),
                    topRight: Radius.circular(20.w))),
            child: Roaming(),
          ),
        );
      },
    );
  }

  @override
  State<Roaming> createState() => _RoamingState();
}

class _RoamingState extends State<Roaming> {
  final RoamingController controller = Get.find<RoamingController>();
  final audioHandler = GetIt.instance<MusicHandler>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void playMusic() async {
    audioHandler.play();
  }

  void pauseMusic() {
    audioHandler.pause();
  }

  void stopMusic() {
    audioHandler.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPlayerHeader(context),
        Expanded(
          child: SizedBox(
            height: 60.w,
          ),
        ),
        Hero(
          tag: "test",
          child: Obx(() {
            return PlayAlbumCover(
              rotating: controller.playing.value,
              pading: 40.w,
              imgPic:
                  '${controller.mediaItem.value.extras?['image'] ?? PLACE_IMAGE_HOLDER}',
            );
          }),
        ),
        Expanded(
          child: SizedBox(
            height: 60.w,
          ),
        ),
        // 歌曲信息
        _buildPlayerMusicInfo(),
        // 进度条
        _buildProgressBar(),
        // 播放按钮
        _buildPlayerControl(context),
        // 底部按钮
        _buildBottomButton(context)
      ],
    );
  }

  _buildPlayerHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: IconButton(
            icon: Icon(TablerIcons.chevron_down,
                color: Colors.grey[400], size: 60.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Text(
          '你的红心歌曲和相似推荐',
          style: TextStyle(color: Colors.grey[300]),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20.w),
          child: IconButton(
            icon: Icon(TablerIcons.share, color: Colors.grey[400], size: 45.w),
            onPressed: () {
              Get.toNamed('/settings');
            },
          ),
        ),
      ],
    );
  }

  _buildPlayerMusicInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.mediaItem.value.title.fixAutoLines(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 36.w),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 10.w,
                ),
                Text(
                  (controller.mediaItem.value.artist ?? '').fixAutoLines(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 26.w),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  TablerIcons.heart_plus,
                  color: Colors.grey[400],
                  size: 60.w,
                ),
                onPressed: () {},
              ),
              SizedBox(
                width: 60.w,
              ),
              Image.asset(ImageUtils.getImagePath('detail_icn_cmt'),
                  width: 60.w, height: 60.w),
            ],
          )
        ],
      ),
    );
  }

  _buildProgressBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.w),
      child: ProgressBar(
        progress: controller.duration.value,
        buffered: controller.duration.value,
        total: controller.mediaItem.value.duration!,
        onSeek: (duration) {
          LogBox.info('Seek to: ${duration.inMilliseconds}');
        },
        thumbColor: Colors.white,
        barHeight: 2.0,
        thumbRadius: 5.0,
        timeLabelTextStyle: TextStyle(color: Colors.white, fontSize: 18.w),
        timeLabelPadding: 14.w,
      ),
    );
  }

  _buildPlayerControl(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              ImageUtils.getImagePath('play_btn_shuffle'),
              width: 50.w,
              height: 50.w,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(
            width: 55.w,
          ),
          IconButton(
            icon: Icon(
              TablerIcons.player_skip_back_filled,
              color: Colors.grey[400],
              size: 55.w,
            ),
            onPressed: () {},
          ),
          SizedBox(
            width: 60.w,
          ),
          IconButton(
            icon: Icon(
              controller.playing.value
                  ? TablerIcons.player_pause_filled
                  : TablerIcons.player_play_filled,
              color: Colors.grey[400],
              size: 80.w,
            ),
            onPressed: () {
              controller.playOrPause();
            },
          ),
          SizedBox(
            width: 55.w,
          ),
          IconButton(
            icon: Icon(
              TablerIcons.player_skip_forward_filled,
              color: Colors.grey[400],
              size: 55.w,
            ),
            onPressed: () {},
          ),
          SizedBox(
            width: 60.w,
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  context: context,
                  builder: (context) {
                    return Obx(() {
                      return Container(
                        padding:
                            EdgeInsets.only(top: 40.w, left: 20.w, right: 20.w),
                        child: PlayList(
                          mediaItems: controller.mediaItems,
                          currentItem: controller.mediaItem.value,
                          onItemTap: (index) {
                            controller.playByIndex(index, 'roaming',
                                mediaItem: controller.mediaItems);
                          },
                          playing: controller.playing.value,
                        ),
                      );
                    });
                  });
            },
            child: Image.asset(
              ImageUtils.getImagePath('epj'),
              width: 70.w,
              height: 70.w,
            ),
          ),
        ],
      );
    });
  }

  _buildBottomButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              TablerIcons.devices,
              color: Colors.grey[500],
              size: 40.w,
            ),
            onPressed: () {},
          ),
          SizedBox(
            width: 140.w,
          ),
          IconButton(
            icon: Icon(
              TablerIcons.info_square,
              color: Colors.grey[500],
              size: 40.w,
            ),
            onPressed: () {},
          ),
          SizedBox(
            width: 140.w,
          ),
          IconButton(
            icon: Icon(
              TablerIcons.dots,
              color: Colors.grey[500],
              size: 40.w,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

extension FixAutoLines on String {
  String fixAutoLines() {
    return Characters(this).join('\u{200B}');
  }
}
