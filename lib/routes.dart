import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/edit_profile_screen.dart';
import 'ui/screens/history_screen.dart';

final routes = {
  '/home': (context) => const HomeScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/edit_profile': (context) => const EditProfileScreen(),
  '/history': (context) => const HistoryScreen(),
};
