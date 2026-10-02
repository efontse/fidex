import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/theme.dart';
import 'models/product_model.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/basket_provider.dart';
import 'providers/order_provider.dart';
import 'providers/logistics_provider.dart';
import 'providers/admin_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/visitor/visitor_home_screen.dart';
import 'screens/consumer/consumer_home_screen.dart';
import 'screens/consumer/product_detail_screen.dart';
import 'screens/consumer/basket_screen.dart';
import 'screens/consumer/checkout_screen.dart';
import 'screens/consumer/order_tracking_screen.dart';
import 'screens/farmer/farmer_dashboard_screen.dart';
import 'screens/farmer/add_product_screen.dart';
import 'screens/farmer/value_chain_screen.dart';
import 'screens/logistician/logistician_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FarmoraApp());
}

class FarmoraApp extends StatelessWidget {
  const FarmoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => BasketProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => LogisticsProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'FARMORA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/otp':
              return MaterialPageRoute(builder: (_) => const OtpScreen());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/visitor':
              return MaterialPageRoute(builder: (_) => const VisitorHomeScreen());
            case '/consumer':
              return MaterialPageRoute(builder: (_) => const ConsumerHomeScreen());
            case '/product-detail':
              final product = settings.arguments as ProductModel;
              return MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              );
            case '/basket':
              return MaterialPageRoute(builder: (_) => const BasketScreen());
            case '/checkout':
              return MaterialPageRoute(builder: (_) => const CheckoutScreen());
            case '/order-tracking':
              final orderId = settings.arguments as int? ?? 1;
              return MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(orderId: orderId),
              );
            case '/farmer':
              return MaterialPageRoute(builder: (_) => const FarmerDashboardScreen());
            case '/farmer/add-product':
              final product = settings.arguments as ProductModel?;
              return MaterialPageRoute(builder: (_) => AddProductScreen(productToEdit: product));
            case '/farmer/log-event':
              final product = settings.arguments as ProductModel?;
              return MaterialPageRoute(
                builder: (_) => ValueChainScreen(preselectedProduct: product),
              );
            case '/logistician':
              return MaterialPageRoute(builder: (_) => const LogisticianDashboardScreen());
            case '/admin':
              return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
            default:
              return MaterialPageRoute(builder: (_) => const VisitorHomeScreen());
          }
        },
      ),
    );
  }
}
