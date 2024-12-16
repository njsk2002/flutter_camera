
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vid_player/const/agora.dart';

class CamScreen extends StatefulWidget{
  const CamScreen({Key? key}) : super(key:key);
  @override
  _CamScreenState createState() => _CamScreenState();


}//class

class _CamScreenState extends State<CamScreen>{
  RtcEngine? engine; // 아고라 엔진을 저장할 함수
  int? uid; //my id
  int? otherid;  // 상대방 id

  Future<bool> init() async { // 권한 관련 작업 모두 실행
    final resp = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = resp[Permission.camera];
    final micPermission = resp[Permission.microphone];

    if(cameraPermission != PermissionStatus.granted ||
    micPermission != PermissionStatus.granted){
      throw '카메라 또는 마이크 권한이 없습니다.';
    }



    // 아고라 엔진 초기화
   if (engine == null) {
      // 엔진 정의가 되지 않았으면 새로 정의하기
      engine = createAgoraRtcEngine();

      // 아고라 엔진 초기화
      await engine!.initialize(
        //초기화할때 사용할 설정 제공
        RtcEngineContext(
          //미리저장해둔 APP_ID 입력
          appId: APP_ID,
          //라이브 동영상 송출에 최적화합니다.
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      engine!.registerEventHandler(
        // 아고라 엔진에서 받을수 있는 이벤트 값을 등록
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed){
            // 채널 접속에 성공했을때 실행
            print('채널에 입장했습니다. uid : ${connection.localUid}');
            setState(() {
              this.uid = connection.localUid;
            });
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats){
            //채널을 퇴장했을때 실행
            print('채널 퇴장');
            setState(() {
              uid = null;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed){
            // 다른 사용자가 접속했을때 실행
            print('상대가 채널에 입장을 했습니다.. uid" $remoteUid');
            setState(() {
              otherid = remoteUid;
            });
          },

          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason){
            // 다른 사용자가 채널을 나갔을때 실행
            print('상대가 채널을 나갔습니다.');
            setState(() {
              otherid = null;
            });
          },
        ),
      );
      //엔진으로 영상 송출 설정
      await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine!.enableVideo(); //동영상 기능 활성화
      await engine!.startPreview(); // 카메라를 이용해 동영상을 실행합니다.
      //채널에 들어가기
      await engine!.joinChannel(
        //채널입장하기
          token: TEMP_TOKEN,
          channelId: CHANNEL_NAME,
          //영상과 관련된 여러가지 설정을 할수있음.
          // 현재 프로젝트에서 불필요함.
          uid: 0,
          options: ChannelMediaOptions(),
      );
      
    }//아고라 엔진
  return true;
}

  @override
  Widget build(BuildContext context) {

   return Scaffold(
     appBar: AppBar(
       title: Text('LIVE'),
     ),

     body: FutureBuilder( // Future 값을 기반으로 위젯 렌더링
       future: init(),
       builder: (BuildContext context, AsyncSnapshot snapshot){
         //print(snapshot.data);
         if(snapshot.hasError){
           return Center(
             child: Text(
               snapshot.error.toString(),
             ),
           );
         }//if

         if(!snapshot.hasData){
           // ➌ Future 실행 후 아직 데이터가 없을 때 (로딩 중)
           return Center(
             child: CircularProgressIndicator(),
           );
         }//if

         return Column( // 나머지 상황에 권한이 있음을 표기
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             Expanded(
                 child: Stack(
                        children: [
                          renderMainView(), // 상대방을 찍은 화면
                          Align(
                            //내가 찍은 화면
                            alignment: Alignment.topLeft,
                            child: Container(
                              color: Colors.grey,
                              height: 160,
                              width: 120,
                              child: renderSubView(),
                            ),
                          )
                        ],
                        ),
             ),

             Padding(
               padding: EdgeInsets.symmetric(horizontal: 8.0),
               child: ElevatedButton(
                 // 뒤로가기 기능 및 채널 퇴장 기능
                   onPressed: () async{
                     if(engine != null){
                       await engine!.leaveChannel();
                       //아래 두줄 추가
                       await engine!.release(); // Agora 엔진 리소스 해제
                       engine = null;
                       
                     }
                     Navigator.of(context).pop();
                   },
                   child: Text('채널나가기'),
               ),
             ),
           ],
         );
       },
       // child: Text('Cam Screen'),
     ),
   );

  }

  //내 핸드폰이 찍는 화면 랜더링
  Widget renderSubView(){
    if(uid !=null){
      //AgoraVideoview 위젯을 사용함
      // 동영상 화면에 보여줄 위젯을 구현할수 있음
      return AgoraVideoView(
        controller: VideoViewController(
          // Videoviewcontroller를 매개변수로 입력해주면 해당 컨트롤러가 제공하는 동영상정보를
          // AgoraVideoView 위젯을 통해 보여줄수 있음.
          rtcEngine: engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );

    }else{
      // 아직 내가 채널에 접속하지 않았따면 로딩화면을 보여줌
      return CircularProgressIndicator();
    }

  }

  //상대방 핸드폰으로 찍는 화면 랜더링
  Widget renderMainView(){
    if(otherid != null){
      return AgoraVideoView(
        //videoviewcontroller.remote 생성자를 이용하면
        //상대방의 동영상을 AgoraVideoView를 그려낼수 있음.
        controller: VideoViewController.remote(
          rtcEngine: engine!,
          //uid에 상대방 idㄹ르 입력해준다
          canvas: VideoCanvas(uid: otherid),
          connection: const RtcConnection(channelId: CHANNEL_NAME),
        ),
      );

    }else {
      // 상대가 아직 채널에 들어오지 않았다면, 대기 메세지를 보여준다.
      return Center(
        child: const Text(
          '다른 사용자가 입장할때 까지 대기해주세요!',
          textAlign: TextAlign.center,
        ),
      );
    }
  }

}//class