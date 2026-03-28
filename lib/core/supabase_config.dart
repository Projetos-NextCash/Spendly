import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://kowupafzejvcyxfludei.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtvd3VwYWZ6ZWp2Y3l4Zmx1ZGVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1Mzg0OTcsImV4cCI6MjA4NzExNDQ5N30.zqbBnIBrhA19UfNUAzloSAAaOxPpVn4geNSxnL-fmsY',
    );
  }
}