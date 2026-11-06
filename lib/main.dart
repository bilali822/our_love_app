import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
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
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const CounterPage(),
    const ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFe75480),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'العداد'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'محادثة'),
        ],
      ),
    );
  }
}

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
    setState(() {
      _diff = _startDate.difference(DateTime.now()).abs();
    });
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
      appBar: AppBar(
        title: const Text('❤️ إلك إنتِ'),
        backgroundColor: const Color(0xFFe75480),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('باقي لنحتفل بذكرانا', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFb03060))),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildCounterBox('$days', 'أيام'),
                _buildCounterBox('$hours', 'ساعات'),
                _buildCounterBox('$minutes', 'دقايق'),
                _buildCounterBox('$seconds', 'ثواني'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterBox(String value, String label) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFe75480))),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFb03060))),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          "sender": "me",
          "text": _controller.text,
          "time": DateFormat('hh:mm a').format(DateTime.now()),
        });
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 محادثتنا'),
        backgroundColor: const Color(0xFFe75480),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["sender"] == "me";
                return Align(
                  alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFe75480) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
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
                        Text(
                          msg["text"]!,
                          style: TextStyle(color: isMe ? Colors.white : const Color(0xFF4a2c2a), fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          msg["time"]!,
                          style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10),
                        ),
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
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFFe75480),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
