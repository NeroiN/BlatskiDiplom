// test.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'bodyscreen.dart';

class Test extends StatefulWidget {
  Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final _controller = SidebarXController(selectedIndex: 0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TimeTracker',
      theme: ThemeData(scaffoldBackgroundColor: Colors.black12),
      home: Scaffold(
        body: Row(
          children: [
            SidebarX(
              controller: _controller,
              theme: SidebarXTheme(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(color: Colors.white),
                selectedTextStyle: const TextStyle(color: Colors.white),
                itemTextPadding: const EdgeInsets.only(left: 30),
                selectedItemTextPadding: const EdgeInsets.only(left: 30),
                itemDecoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                selectedItemDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: actionColor.withOpacity(0.37)),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 52, 52, 97),
                      Color.fromARGB(255, 46, 46, 72),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        145,
                        145,
                        145,
                      ).withOpacity(0.28),
                      blurRadius: 30,
                    ),
                  ],
                ),
                iconTheme: const IconThemeData(color: Colors.white, size: 20),
              ),
              extendedTheme: const SidebarXTheme(
                width: 200,
                decoration: BoxDecoration(color: Colors.black12),
                margin: EdgeInsets.only(right: 10),
              ),
              footerDivider: divider,
              headerBuilder: (context, extended) {
                return SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset('lib/assets/images/avatar2.jpg'),
                  ),
                );
              },
              items: [
                SidebarXItem(
                  icon: Icons.home,
                  label: 'Home',
                  onTap: () {
                    setState(() {
                      _controller.selectIndex(0);
                    });
                  },
                ),
                SidebarXItem(
                  icon: Icons.search,
                  label: 'Search',
                  onTap: () {
                    setState(() {
                      _controller.selectIndex(1);
                    });
                  },
                ),
                SidebarXItem(
                  icon: Icons.library_add,
                  label: 'qwe',
                  onTap: () {
                    setState(() {
                      _controller.selectIndex(2);
                    });
                  },
                ),
                SidebarXItem(
                  icon: Icons.bolt,
                  label: 'asd',
                  onTap: () {
                    setState(() {
                      _controller.selectIndex(3);
                    });
                  },
                ),
                SidebarXItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    setState(() {
                      _controller.selectIndex(4);
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: BodyScreen(selectedIndex: _controller.selectedIndex),
            ),
          ],
        ),
      ),
    );
  }
}

const primaryColor = Color(0xFF685BFF);
const actionColor = Color(0xFF5F5FA7);
final divider = Divider(color: Colors.white.withOpacity(0.3), height: 1);
