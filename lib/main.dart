import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. إخفاء شريط الإشعارات والأزرار (وضع الغمر الكامل)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  // 2. جعل شريط الحالة شفاف تماماً (عشان ما يطلع خط رمادي فوق)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محمد وهديل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFfff0f5),
      ),
      home: const SplashScreen(),
    );
  }
}

// --- 1. شاشة اللوغو ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 120, color: Color(0xFFe75480)),
              SizedBox(height: 20),
              Text('محمد وهديل', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFb03060))),
              SizedBox(height: 10),
              Text('مساحتنا الخاصة ❤️', style: TextStyle(fontSize: 18, color: Color(0xFFe75480))),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. الشاشة الرئيسية ---
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const CounterPage(), const ChatPage()];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('الخروج'),
              content: const Text('هل تريد الخروج من التطبيق؟'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                TextButton(onPressed: () => SystemNavigator.pop(), child: const Text('خروج', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        // لا نستخدم SafeArea هنا عشان نضمن إنو المحتوى يمتد لكل الشاشة
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFe75480),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'العداد'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'محادثة'),
          ],
        ),
      ),
    );
  }
}

// --- 3. صفحة العداد ---
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final DateTime _startDate = DateTime(2026, 6, 13);
  Duration _diff = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    setState(() => _diff = _startDate.difference(DateTime.now()).abs());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int days = _diff.inDays;
    int hours = _diff.inHours % 24;
    int minutes = _diff.inMinutes % 60;
    int seconds = _diff.inSeconds % 60;

    return Scaffold(
      // شلنا الـ AppBar عشان نملأ الشاشة
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 80, color: Color(0xFFe75480)),
            const SizedBox(height: 10),
            const Text('باقي لنحتفل بذكرانا', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFb03060))),
            const SizedBox(height: 30),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: [
                _buildBox('$days', 'أيام'),
                _buildBox('$hours', 'ساعات'),
                _buildBox('$minutes', 'دقايق'),
                _buildBox('$seconds', 'ثواني'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String val, String label) {
    return Container(
      width: 85, height: 85,
      decoration: BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFe75480))),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFb03060))),
        ],
      ),
    );
  }
}

// --- 4. صفحة المحادثة (متصلة بالسيرفر) ---
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _messages = [];
  Timer? _pollTimer;
  final String apiUrl = "https://hadilmohamad1.pythonanywhere.com/api/get-chat";

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages());
  }

  void _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _messages = data['messages'] ?? []);
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final text = _controller.text.trim();
    _controller.clear();

    try {
      await http.post(
        Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/send-chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text, "sender": "app_user"}),
      );
      _fetchMessages();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شلنا الـ AppBar هون كمان
      body: Column(
        children: [
          // مساحة صغيرة فوق عشان ما يلتصق الكلام بحافة الشاشة
          const SizedBox(height: 30), 
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["sender"] == "app_user"; 
                return Align(
                  alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFe75480) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
                        bottomLeft: isMe ? const Radius.circular(2) : const Radius.circular(15),
                        bottomRight: isMe ? const Radius.circular(15) : const Radius.circular(2),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 5, spreadRadius: 1),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg["text"] ?? "", style: TextStyle(color: isMe ? Colors.white : const Color(0xFF4a2c2a), fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(msg["time"] ?? "", style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFFe75480),
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
                ),
              ],
            ),
          ),
          // مساحة صغيرة تحت عشان ما يلتصق الحقل بأزرار التلفون
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
