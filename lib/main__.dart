
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


late List<CameraDescription> _cameras;

Future<void> main() async {
  //Future 앱이 실행될 준비가 되었는지 확인
  WidgetsFlutterBinding.ensureInitialized();
  //핸드폰에 있는 카메라들 가져오기
  _cameras = await availableCameras();
  runApp(const CameraApp());
}//main class

class CameraApp extends StatefulWidget{
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState()  => _CameraAppState();

}//class

class _CameraAppState extends State<CameraApp>{
  //카메라를 제어할수 있는 컨트롤러 선언
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  initializeCamera() async {
    // 가장 첫번째 카메라로 카메라 저장하기
    try {
      controller = CameraController(
          _cameras[0], ResolutionPreset.max); //(첫번째사용할 카메라, 해상도)
      //카메라 초기화
      await controller.initialize();
      setState(() {});
    } catch (e) {
      //에러났을때 출력
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied' :
            print('User denied camera access,');
            break;
          default:
            print('Handle other errors');
            break;
        }
      }
    }
  }

  @override
  void dispose(){
    //컨트롤러 삭제
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //카메라 초기화 상태 확인
    if (!controller.value.isInitialized){
      return Container();
    }
    return MaterialApp(
      //카메라 보여주기
      home: CameraPreview(controller),
    );
  }







}



