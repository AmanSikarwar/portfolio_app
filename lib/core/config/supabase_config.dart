import 'package:envied/envied.dart';

part 'supabase_config.g.dart';

@Envied(path: '.env')
class SupabaseConfig {
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _SupabaseConfig.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _SupabaseConfig.supabaseAnonKey;
}
