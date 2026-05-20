import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/add_task_screen.dart';
import '../models/task_model.dart';
class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
  static Route<dynamic> generateRoute(RouteSettings settings,) {
    switch(settings.name){
      case login:
        return slidePage(
          const LoginScreen(),
        );
      case register:
        return slidePage(
          const RegisterScreen(),
        );
      case home:
        return fadePage(
          const HomeScreen(),
        );
      case addTask:
        return slidePage(
          const AddTaskScreen(),
        );
      case editTask:
        final task =settings.arguments as TaskModel;
        return slidePage(
          AddTaskScreen(
            existingTask: task,
          ),
        );
      default:
        return fadePage(
          const LoginScreen(),
        );
    }
  }
  static PageRouteBuilder fadePage(
    Widget page,
  ) {
    return PageRouteBuilder(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return page;
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(
        milliseconds: 280,
      ),
    );
  }
  static PageRouteBuilder slidePage(
    Widget page,
  ) {
    return PageRouteBuilder(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return page;
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        Animation<Offset> slideAnimation =
            Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        );
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(
        milliseconds: 300,
      ),
    );
  }
}