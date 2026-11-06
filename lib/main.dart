import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // فل سكرين غصب عن التلفون
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
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
  final List<Widget> _pages = [
    const HomePage(),
    const ContentPage(), // تبويب المحتوى الجديد
    const LoveCardPage(),
    const CounterPage(),
    const WishlistPage(),
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
        extendBody: true, // يمتد المحتوى تحت الشاشة
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFe75480),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white.withOpacity(0.95),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'محتوى'),
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'بطاقة الحب'),
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'العداد'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'الأمنيات'),
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
  String daily = "";
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() { isLoading = true; isError = false; });
    try {
      final res = await http.get(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/app-data")).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() { daily = jsonDecode(res.body)['daily'] ?? "لا يوجد رسالة"; isLoading = false; });
      } else {
        setState(() { isLoading = false; isError = true; });
      }
    } catch (e) {
      setState(() { isLoading = false; isError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea( // هون بنستخدم SafeArea عشان المحتوى ما يدخل تحت الكاميرا
      child: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // عنوان الصفحة كبديل للـ AppBar
          const Center(
            child: Text('❤️ إلك إنتِ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFb03060))),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10)],
            ),
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : isError 
                ? const Text("تعذر الاتصال بالسيرفر. تأكد من الإنترنت.", textAlign: TextAlign.center, style: TextStyle(color: Colors.red))
                : Text(daily, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFFb03060), height: 1.6, fontWeight: FontWeight.bold)),
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
          const SizedBox(height: 80), // مساحة عشان الـ Bottom Nav
        ],
      ),
    );
  }
}

// --- 4. صفحة المحتوى (القصائد والأدعية والهمسات) ---
class ContentPage extends StatefulWidget {
  const ContentPage({super.key});
  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  String _currentText = "اختر نوع المحتوى واضغط 'جيبلي وحدة جديدة'...";
  String _selectedType = "poem";
  bool isLoading = false;

  void _fetchContent() async {
    setState(() { _currentText = "جاري التحميل..."; isLoading = true; });
    try {
      final response = await http.get(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/get-content/$_selectedType"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() { _currentText = data['text'] ?? "لا يوجد محتوى"; isLoading = false; });
      }
    } catch (e) {
      setState(() { _currentText = "خطأ في الاتصال بالسيرفر"; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('📜 محتوى الموقع', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFb03060))),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.pink.shade200)),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                value: _selectedType,
                style: const TextStyle(color: Color(0xFFb03060), fontSize: 18, fontWeight: FontWeight.bold),
                items: const [
                  DropdownMenuItem(value: "poem", child: Text("📜 قصائد وأشعار")),
                  DropdownMenuItem(value: "dua", child: Text("🤲 أدعية")),
                  DropdownMenuItem(value: "verse", child: Text("📖 آيات وأذكار")),
                  DropdownMenuItem(value: "whisper", child: Text("✨ همسات")),
                ],
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: isLoading 
                      ? const CircularProgressIndicator()
                      : Text(_currentText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Color(0xFF4a2c2a), height: 1.6)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe75480),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _fetchContent,
              child: const Text('جيبلي وحدة جديدة', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 70), // مساحة للـ Bottom Nav
          ],
        ),
      ),
    );
  }
}

// --- 5. صفحة بطاقة الحب ---
class LoveCardPage extends StatefulWidget {
  const LoveCardPage({super.key});
  @override
  State<LoveCardPage> createState() => _LoveCardPageState();
}

class _LoveCardPageState extends State<LoveCardPage> {
  bool isLoading = true;
  bool isActive = false;
  bool isError = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() { super.initState(); _checkStatus(); }

  void _checkStatus() async {
    setState(() { isLoading = true; isError = false; });
    try {
      final res = await http.get(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/love-card-status")).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() { isActive = jsonDecode(res.body)['is_active']; isLoading = false; });
      } else { setState(() { isLoading = false; isError = true; }); }
    } catch (e) { setState(() { isLoading = false; isError = true; }); }
  }

  void _renewCard() async {
    if (_controller.text.isEmpty) return;
    try {
      final res = await http.post(
        Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/renew-love-card"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": _controller.text}),
      );
      if (res.statusCode == 200) {
        setState(() { isActive = true; _controller.clear(); });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تجديد بطاقة الحب بنجاح! ❤️")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لازم تكتب 'بحبك' ❤️")));
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading 
            ? const CircularProgressIndicator()
            : isError
              ? const Text("تعذر الاتصال بالسيرفر. تأكد من الإنترنت.", style: TextStyle(color: Colors.red))
              : isActive 
                ? Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                      border: Border.all(color: const Color(0xFFe75480), width: 3),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, size: 100, color: Color(0xFFe75480)),
                        SizedBox(height: 20),
                        Text('بطاقة الحب مجددة لليوم! ❤️', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFb03060))),
                        SizedBox(height: 10),
                        Text('شكراً لأنك كتبت "بحبك" اليوم. الحب بتجدد كل يوم.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
                      const SizedBox(height: 20),
                      const Text('⚠️ لازم تجدد بطاقة الحب!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const SizedBox(height: 10),
                      const Text('اكتب كلمة "بحبك" مع قلب ❤️ عشان تجدد البطاقة لليوم.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF4a2c2a))),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _controller, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(hintText: 'اكتب بحبك ❤️ هنا...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFe75480), padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _renewCard,
                        child: const Text('تجديد البطاقة', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

// --- 6. صفحة العداد ---
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
  void initState() { super.initState(); _updateTime(); _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime()); }
  void _updateTime() => setState(() => _diff = _startDate.difference(DateTime.now()).abs());
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
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

// --- 7. صفحة الأمنيات ---
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> wishes = [];
  bool isLoading = true;
  bool isError = false;
  final _controller = TextEditingController();

  @override
  void initState() { super.initState(); _fetchWishes(); }

  void _fetchWishes() async {
    setState(() { isLoading = true; isError = false; });
    try {
      final res = await http.get(Uri.parse("https://hadilmohamad1.pythonanywhere.com/api/app-data")).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() { wishes = jsonDecode(res.body)['wishlist'] ?? []; isLoading = false; });
      } else { setState(() { isLoading = false; isError = true; }); }
    } catch (e) { setState(() { isLoading = false; isError = true; }); }
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
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('🌷 أمنياتنا', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFb03060))),
          const SizedBox(height: 10),
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
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : isError
                ? const Center(child: Text("تعذر الاتصال بالسيرفر. تأكد من الإنترنت.", style: TextStyle(color: Colors.red)))
                : ListView.builder(
                    itemCount: wishes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(wishes[index], style: const TextStyle(fontSize: 16)),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteWish(index)),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 70), // مساحة للـ Bottom Nav
        ],
      ),
    );
  }
}
