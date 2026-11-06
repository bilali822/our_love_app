import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
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
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFe75480), foregroundColor: Colors.white),
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
  final List<Widget> _pages = [
    const HomePage(),
    const LoveCardPage(),
    const CounterPage(),
    const WishlistPage(),
    const ChatPage(),
  ];

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
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFe75480),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'بطاقة الحب'),
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'العداد'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'الأمنيات'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'محادثة'),
          ],
        ),
      ),
    );
  }
}

// --- 3. الصفحة الرئيسية ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String daily = "جاري التحميل...";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      final res = await http.get(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/app-data"));
      if (res.statusCode == 200) {
        setState(() => daily = jsonDecode(res.body)['daily'] ?? "لا يوجد رسالة");
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('❤️ إلك إنتِ')),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Text(daily, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFFb03060), height: 1.6, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFfff8e7), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFd4af37), width: 2),
            ),
            child: const Column(
              children: [
                Icon(Icons.workspace_premium, color: Color(0xFFd4af37), size: 50),
                SizedBox(height: 10),
                Text('شهادة وعد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFb8860b))),
                Divider(color: Color(0xFFd4af37)),
                Text(
                  'أنا محمد، أوعدكِ يا هديل إني رح كون السند والظهر، ورح أحافظ على هالحب الحلال، وربنا يتمم بخير ويجمعنا بالحلال.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.8, color: Color(0xFF4a2c2a)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. صفحة بطاقة الحب ---
class LoveCardPage extends StatefulWidget {
  const LoveCardPage({super.key});
  @override
  State<LoveCardPage> createState() => _LoveCardPageState();
}

class _LoveCardPageState extends State<LoveCardPage> {
  bool isLoading = true;
  bool isActive = false;
  final TextEditingController _controller = TextEditingController();
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    try {
      final res = await http.get(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/love-card-status"));
      if (res.statusCode == 200) {
        setState(() {
          isActive = jsonDecode(res.body)['is_active'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "تعذر الاتصال بالسيرفر";
        isLoading = false;
      });
    }
  }

  void _renewCard() async {
    if (_controller.text.isEmpty) return;
    
    setState(() => errorMessage = "");
    try {
      final res = await http.post(
        Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/renew-love-card"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": _controller.text}),
      );
      
      if (res.statusCode == 200) {
        setState(() {
          isActive = true;
          _controller.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تجديد بطاقة الحب بنجاح! ❤️")));
      } else {
        setState(() => errorMessage = "لازم تكتب 'بحبك' ❤️");
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('❤️ بطاقة الحب')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isActive 
            ? Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                  border: Border.all(color: const Color(0xFFe75480), width: 3),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 100, color: Color(0xFFe75480)),
                    SizedBox(height: 20),
                    Text(
                      'بطاقة الحب مجددة لليوم! ❤️',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFb03060)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'شكراً لأنك كتبت "بحبك" اليوم. الحب بتجدد كل يوم.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
                  const SizedBox(height: 20),
                  const Text(
                    '⚠️ لازم تجدد بطاقة الحب!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'اكتب كلمة "بحبك" مع قلب ❤️ عشان تجدد البطاقة لليوم.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF4a2c2a)),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: 'اكتب بحبك ❤️ هنا...',
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe75480),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _renewCard,
                    child: const Text('تجديد البطاقة', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ), // <--- هون كانت الغلطة (الفاصلة الناقصة)
                ],
              ),
        ),
      ),
    );
  }
}

// --- 5. صفحة العداد ---
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

  void _updateTime() => setState(() => _diff = _startDate.difference(DateTime.now()).abs());
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🕰️ عدّادنا')),
      body: Center(
        child: Wrap(
          spacing: 15, runSpacing: 15, alignment: WrapAlignment.center,
          children: [
            _buildBox('${_diff.inDays}', 'أيام'),
            _buildBox('${_diff.inHours % 24}', 'ساعات'),
            _buildBox('${_diff.inMinutes % 60}', 'دقايق'),
            _buildBox('${_diff.inSeconds % 60}', 'ثواني'),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String val, String label) {
    return Container(
      width: 85, height: 85,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFe75480))),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFb03060))),
      ]),
    );
  }
}

// --- 6. صفحة الأمنيات ---
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> wishes = [];
  final _controller = TextEditingController();

  @override
  void initState() { super.initState(); _fetchWishes(); }

  void _fetchWishes() async {
    try {
      final res = await http.get(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/app-data"));
      if (res.statusCode == 200) setState(() => wishes = jsonDecode(res.body)['wishlist'] ?? []);
    } catch (e) {}
  }

  void _addWish() async {
    if (_controller.text.isEmpty) return;
    await http.post(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/add-wish"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"wish": _controller.text}));
    _controller.clear();
    _fetchWishes();
  }

  void _deleteWish(int index) async {
    await http.post(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/delete-wish"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"index": index}));
    _fetchWishes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌷 أمنياتنا')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'أضف أمنية جديدة...', filled: true, fillColor: Colors.white, border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                CircleAvatar(backgroundColor: const Color(0xFFe75480), child: IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _addWish)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: wishes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(wishes[index], style: const TextStyle(fontSize: 16)),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteWish(index)),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// --- 7. صفحة المحادثة ---
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
      if (response.statusCode == 200) setState(() => _messages = jsonDecode(response.body)['messages'] ?? []);
    } catch (e) {}
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();
    _controller.clear();
    try {
      await http.post(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/send-chat"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"message": text, "sender": "app_user"}));
      _fetchMessages();
    } catch (e) {}
  }

  @override
  void dispose() { _pollTimer?.cancel(); _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 محادثتنا')),
      body: Column(
        children: [
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
                    margin: const EdgeInsets.symmetric(vertical: 5), padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFe75480) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
                        bottomLeft: isMe ? const Radius.circular(2) : const Radius.circular(15),
                        bottomRight: isMe ? const Radius.circular(15) : const Radius.circular(2),
                      ),
                    ),
                    child: Text(msg["text"] ?? "", style: TextStyle(color: isMe ? Colors.white : const Color(0xFF4a2c2a), fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'اكتب رسالتك...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))))),
                const SizedBox(width: 10),
                CircleAvatar(backgroundColor: const Color(0xFFe75480), child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
