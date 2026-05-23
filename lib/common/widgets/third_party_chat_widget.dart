import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';

import 'package:flutter_grocery/utill/images.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';


class ThirdPartyChatWidget extends StatefulWidget {
  final ConfigModel? configModel;
  const ThirdPartyChatWidget({
    super.key,
    required this.configModel,
  });

  @override
  State<ThirdPartyChatWidget> createState() => _ThirdPartyChatWidgetState();
}

class _ThirdPartyChatWidgetState extends State<ThirdPartyChatWidget> {
  List<SpeedDialChild> dialList = [];

  @override
  void initState() {
    _loadDialList();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ThirdPartyChatWidget oldWidget) {
    if (oldWidget.configModel != widget.configModel) {
      _loadDialList();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _loadDialList() {
    dialList.clear();
    if (widget.configModel?.whatsapp != null &&
        widget.configModel!.whatsapp!.status! &&
        widget.configModel?.whatsapp!.number != null) {
      dialList.add(SpeedDialChild(
        backgroundColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          height: 65,
          width: 65,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: ClipOval(
            child: Image.asset(Images.whatsapp,
                height: 55, width: 55, fit: BoxFit.cover),
          ),
        ),
        onPressed: () async {
          final String? whatsapp = widget.configModel?.whatsapp!.number;
          final Uri whatsappMobile =
              Uri.parse("whatsapp://send?phone=$whatsapp");
          if (await canLaunchUrl(whatsappMobile)) {
            await launchUrl(whatsappMobile,
                mode: LaunchMode.externalApplication);
          } else {
            await launchUrl(
                Uri.parse("https://web.whatsapp.com/send?phone=$whatsapp"),
                mode: LaunchMode.externalApplication);
          }
        },
      ));
    }

    if (widget.configModel?.telegram != null &&
        widget.configModel!.telegram!.status! &&
        widget.configModel?.telegram!.userName != null) {
      dialList.add(SpeedDialChild(
        backgroundColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(Images.telegram, fit: BoxFit.cover),
          ),
        ),
        onPressed: () async {
          final String? userName = widget.configModel?.telegram!.userName;
          final Uri whatsappMobile = Uri.parse("https://t.me/$userName");
          if (await canLaunchUrl(whatsappMobile)) {
            await launchUrl(whatsappMobile,
                mode: LaunchMode.externalApplication);
          }
        },
      ));
    }

    if (widget.configModel?.messenger != null &&
        widget.configModel!.messenger!.status! &&
        widget.configModel?.messenger!.userName != null) {
      dialList.add(SpeedDialChild(
        backgroundColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(Images.messenger, fit: BoxFit.cover),
          ),
        ),
        onPressed: () async {
          final String? userId = widget.configModel?.messenger!.userName;
          final Uri messengerUrl = Uri.parse("https://m.me/$userId");
          if (await canLaunchUrl(messengerUrl)) {
            await launchUrl(messengerUrl, mode: LaunchMode.externalApplication);
          }
        },
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return dialList.isEmpty
        ? const SizedBox()
        : dialList.length > 1
            ? SpeedDial(
                closedForegroundColor: Colors.white,
                openForegroundColor: Colors.white,
                closedBackgroundColor: Theme.of(context).primaryColor,
                openBackgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.3),
                labelsBackgroundColor: Colors.white,
                speedDialChildren: dialList,
                child: const Icon(Icons.message),
              )
            : Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () => dialList.first.onPressed(),
                    child: dialList.first.child),
              );
  }
}
