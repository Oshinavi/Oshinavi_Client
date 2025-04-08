import 'package:flutter/material.dart';
import 'package:mediaproject/components/bio_box.dart';
import 'package:mediaproject/pages/oshi_register_page.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/oshi_service.dart';
import 'package:provider/provider.dart';

class OshiProfilePage extends StatefulWidget {
  const OshiProfilePage({super.key});

  @override
  State<OshiProfilePage> createState() => _OshiProfilePageState();
}

class _OshiProfilePageState extends State<OshiProfilePage> {
  Map<String, dynamic>? oshi;
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => loadOshi());
    }
  }

  Future<void> loadOshi() async {
    setState(() => _isLoading = true);

    final service = OshiService();
    final result = await service.getOshi();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!result.containsKey('error')) {
          oshi = result;
        } else {
          oshi = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final oshiProvider = Provider.of<DatabaseProvider>(context, listen: false);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (oshi == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("오시 정보")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("아직 오시를 등록하지 않으신 것 같아요!"),
              const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OshiRegisterPage()),
              );
            },
            child: const Text("오시 등록"),
          ),
        ],
      ),
    ),
  );
}

    return FutureBuilder(
      future: oshiProvider.getUserProfile(oshi!["oshi_tweet_id"]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("오시 정보")),
            body: const Center(child: Text("오시 정보를 불러오는 데 실패했습니다.")),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(user.username),
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: ListView(
            children: [
              Center(
                child: Text(
                  '@${user.tweetId}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              BioBox(text: user.bio),
            ],
          ),
        );
      },
    );
  }
}
