import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eouymrxocetlfxyyibou.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvdXltcnhvY2V0bGZ4eXlpYm91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NDAwOTIsImV4cCI6MjA2MjMxNjA5Mn0.-CPfL7iGcbAnHdWOTAISfN6xGrI3U_lE5yk0Al10Tj8',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (context, child) => MaterialApp(
        title: 'Mazal Kayn Elkhir',
        theme: AppTheme.lightThemeMode,
        darkTheme: AppTheme.darkThemeMode,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: RouteGenerator.splash,
        onGenerateRoute: (settings) => RouteGenerator.generateRoute(
          settings,
          userType: 'defaultUserType',
        ),
        builder: (context, child) => ThemeBackground(
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}