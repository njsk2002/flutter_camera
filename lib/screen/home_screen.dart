
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vid_player/screen/cam_screen.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child : Column(
              children: [
                Expanded(child: _Logo()),
                Expanded(child: _Image()),
                Expanded(child: _EntryButton()),
              ],
            )
          ),
      ),

    );
  }

} // class


// LOGO
class _Logo extends StatelessWidget{

  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16.0), //모서리 둥글게
          boxShadow: [
            BoxShadow(
              color: Colors.blue[300]!,
              blurRadius: 12.0,
              spreadRadius: 2.0,
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam,
                color: Colors.white,
                size: 40.0,
              ),
              SizedBox(width:12.0),
              Text( // 앱이름
                'LIVE',
                style: TextStyle(
                  color:  Colors.white,
                  fontSize: 30.0,
                  letterSpacing: 4.0, //글자간 간격
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}//CLASS

class _Image extends StatelessWidget{
  const _Image({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'asset/img/home_img.png'
      ),
    );
  }

}//class

// StatelessWidget을 상속받아 _EntryButton 클래스 정의
class _EntryButton extends StatelessWidget {
  // 생성자: 부모 클래스 StatelessWidget의 생성자를 호출하여 초기화
  const _EntryButton({Key? key}) : super(key: key);

  // build 메서드: 화면에 표시될 위젯을 반환
  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: 열(Column)의 주축 방향(세로) 정렬 방식 설정
      mainAxisAlignment: MainAxisAlignment.end, // 세로 기준으로 아래쪽에 정렬
      // crossAxisAlignment: 열(Column)의 교차축 방향(가로) 정렬 방식 설정
      crossAxisAlignment: CrossAxisAlignment.stretch, // 가로 기준으로 최대 크기까지 확장

      // Column의 자식 위젯들
      children: [
        // ElevatedButton: 버튼 위젯
        ElevatedButton(
          // onPressed: 버튼 클릭 시 실행되는 콜백 함수
          onPressed: () {
            // Navigator.of(context).push 사용하여 새 화면으로 이동
            Navigator.of(context).push(
              // MaterialPageRoute를 사용하여 화면 전환 정의
              MaterialPageRoute(
                // builder: 새로운 화면을 생성하는 함수
                builder: (_) => CamScreen(), // CamScreen으로 이동
              ),
            );
          },
          // 버튼의 텍스트
          child: Text('입장하기'),
        ),
      ],
    );
  }
}//class

