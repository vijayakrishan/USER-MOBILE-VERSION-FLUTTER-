import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ResQMeshUserApp());
}

class ResQMeshUserApp extends StatelessWidget {
  const ResQMeshUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'ResQMesh Survivor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: AppConstants.primaryColor,
            surface: AppConstants.surfaceColor,
            error: AppConstants.errorColor,
          ),
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.backgroundColor,
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.token != null) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
