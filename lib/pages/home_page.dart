import 'package:flutter/material.dart';
import 'package:flutter_todolist_app/user_view_model.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/common_parts.dart';
import 'package:flutter_todolist_app/pages/todos_page.dart';
import 'package:flutter_todolist_app/pages/dones_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pageWidgets = [
      TodosPage(),
      DonesPage(),
    ];

    return Scaffold(
      appBar: GradientAppBar(
        title: Icon(Icons.style),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await context.read(userViewModelProvider).signOut();
            },
          )
        ],
        backgroundColorStart: Colors.cyan,
        backgroundColorEnd: Colors.indigo,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pageWidgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            activeIcon: GradientIcon(Icons.inbox),
            title: Text('ToDo'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            activeIcon: GradientIcon(Icons.check),
            title: Text('Done'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onPageChanged(int index) => setState(() => _selectedIndex = index);

  void _onItemTapped(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 160), curve: Curves.easeIn);
  }
}
