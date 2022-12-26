import 'package:flutter/material.dart';
import 'package:tweech/screens/settings_screen.dart';
import 'package:tweech/screens/feed_screen.dart';
import 'package:tweech/screens/goLive_screen.dart';
import 'package:tweech/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 1;

  getCurrentPage(int index) {
    _currentPageIndex = index;
    setState(() {});
  }

  List<Widget> pages = [
    const FeedScreen(),
    const GoLiveScreen(),
    const SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: pages[_currentPageIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: btnColor,
        unselectedItemColor: priColor,
        unselectedFontSize: 14,
        elevation: 0,
        currentIndex: _currentPageIndex,
        onTap: getCurrentPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.web_stories),
            label: "Live Streams",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call_outlined),
            label: "Go Live",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            // icon: Icon(Icons.webhook),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
