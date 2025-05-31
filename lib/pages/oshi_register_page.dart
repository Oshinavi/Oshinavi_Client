import 'package:flutter/material.dart';
import 'package:mediaproject/components/input_alert_box.dart';
import 'package:mediaproject/components/loading_circle.dart';
import 'package:mediaproject/components/simple_button.dart';
import 'package:mediaproject/services/oshi_service.dart';

class OshiRegisterPage extends StatefulWidget {
  const OshiRegisterPage({Key? key}) : super(key: key);

  @override
  State<OshiRegisterPage> createState() => _OshiRegisterPageState();
}

class _OshiRegisterPageState extends State<OshiRegisterPage> {
  String? oshiId;
  bool _isLoading = true;

  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOshi();
  }

  Future<void> fetchOshi() async {
    final service = OshiService();
    final result = await service.getOshi();

    setState(() {
      _isLoading = false;
      if (result.containsKey("oshi_tweet_id")) {
        oshiId = result["oshi_tweet_id"];
      } else {
        oshiId = null;
      }
    });
  }

  void showRegisterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return InputAlertBox(
          textController: _inputController,
          hintText: "예: Hayama_Fuka",
          onPressedText: "등록",
          onPressed: () async {
            final inputId = _inputController.text.trim();
            if (inputId.isEmpty) return;

            final messenger = ScaffoldMessenger.of(dialogContext);
            final navigator = Navigator.of(dialogContext);
            final hideLoader = () => navigator.pop();

            // 로딩 표시
            showLoadingCircle(dialogContext);

            // 실제 등록 호출
            final result = await OshiService().registerOshi(inputId);

            // 로딩 해제
            hideLoader();

            if (!mounted) return;
            if (result.containsKey("error")) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text("존재하지 않는 ID입니다. 다시 한 번 확인해 주세요"),
                ),
              );
            } else {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text("오시 등록에 성공했어요!"),
                ),
              );
              // 대화상자 닫기
              navigator.pop();
              // 화면 업데이트
              setState(() {
                oshiId = inputId;
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("오시 등록")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              oshiId != null
                  ? "현재 등록된 오시: @$oshiId"
                  : "아직 등록된 오시가 없어요",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            SimpleButton(
              text: oshiId != null ? "오시 변경" : "오시 등록",
              onTap: showRegisterDialog,
            ),
          ],
        ),
      ),
    );
  }
}