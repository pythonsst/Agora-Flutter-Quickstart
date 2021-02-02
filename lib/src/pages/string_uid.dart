import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import '../utils/settings.dart' as config;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// MultiChannel Example
class StringUid extends StatefulWidget {
  RtcEngine _engine = null;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StringUid> {
  String channelId = config.channelId;
  String stringUid = config.stringUid;
  bool isJoined = false;
  TextEditingController _controller0, _controller1;

  @override
  void initState() {
    super.initState();
    _controller0 = TextEditingController(text: channelId);
    _controller1 = TextEditingController(text: stringUid);
    this._initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    widget._engine?.destroy();
  }

  _initEngine() async {
    widget._engine = await RtcEngine.create(config.APP_ID);
    this._addListeners();

    await widget._engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await widget._engine.setClientRole(ClientRole.Broadcaster);
  }

  _addListeners() {
    widget._engine?.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        log('joinChannelSuccess ${channel} ${uid} ${elapsed}');
        setState(() {
          isJoined = true;
        });
      },
      leaveChannel: (stats) {
        log('leaveChannel ${stats.toJson()}');
        setState(() {
          isJoined = false;
        });
      },
    ));
  }

  _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.microphone.request();
    }
    await widget._engine
        ?.joinChannelWithUserAccount(config.Token, channelId, stringUid);
  }

  _leaveChannel() async {
    await widget._engine?.leaveChannel();
  }

  _getUserInfo() {
    widget._engine?.getUserInfoByUserAccount(stringUid)?.then((userInfo) {
      log('getUserInfoByUserAccount ${userInfo.toJson()}');
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${userInfo.toJson()}'),
      ));
    })?.catchError((err) {
      log('getUserInfoByUserAccount ${err}');
    });
  }

  @override
  Widget build(BuildContext context) {
    _controller0.text="Android";
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(

        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(height: 30,),
/*
                  TextField(
                    controller: _controller0,
                    decoration: InputDecoration(hintText: 'Channel ID'),
                    onChanged: (text) {
                      setState(() {
                        channelId = text;
                      });
                    },
                  ),
*/
                  TextField(
                    controller: _controller1,
                    decoration: InputDecoration(hintText: 'User ID'),
                    onChanged: (text) {
                      setState(() {
                        stringUid = text;
                      });
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          onPressed:
                          isJoined ? this._leaveChannel : this._joinChannel,
                          child: Text('${isJoined ? 'Leave' : 'Join'} channel'),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RaisedButton(
                    onPressed: this._getUserInfo,
                    child: Text('Get userInfo'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
