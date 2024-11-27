import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_scout/provider/bottom_navigation_provider.dart';
import 'package:trash_scout/screens/user/home_screen.dart';
import 'package:trash_scout/screens/user/profile_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_bottom_navigation_item.dart';
import 'package:trash_scout/screens/user/leaderboard_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildContent(context),
          CustomBottomNavigation(),
        ],
      ),
    );
  }
}

Widget buildContent(BuildContext context) {
  final navigationProvider = Provider.of<BottomNavigationProvider>(context);
  int currentIndex = navigationProvider.currentIndex;

  switch (currentIndex) {
    case 0:
      return HomeScreen();
    case 1:
      return LeaderboardScreen();
    case 2:
      return ProfileScreen();
    default:
      return HomeScreen();
  }
}

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<BottomNavigationProvider>(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 70,
        padding: EdgeInsets.only(
          left: 54,
          right: 54,
          top: 10,
        ),
        decoration: BoxDecoration(
          color: whiteColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => navigationProvider.currentIndex = 0,
              child: CustomBottomNavigationItem(
                title: 'Home',
                imageUrl: 'assets/home_icon.png',
                index: 0,
              ),
            ),
            GestureDetector(
              onTap: () => navigationProvider.currentIndex = 1,
              child: CustomBottomNavigationItem(
                title: 'Leaderboard',
                imageUrl: 'assets/leaderboard_icon.png',
                index: 1,
              ),
            ),
            GestureDetector(
              onTap: () => navigationProvider.currentIndex = 2,
              child: CustomBottomNavigationItem(
                title: 'Profile',
                imageUrl: 'assets/profile_icon.png',
                index: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
