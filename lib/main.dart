import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lkroupuydsoadujyykif.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxrcm91cHV5ZHNvYWR1anl5a2lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxMzQzOTMsImV4cCI6MjA2MDcxMDM5M30.nFxbjvkYxb5vWYddUgvYUteze0AKMWrDd8kJE6GWnTE',
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
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}