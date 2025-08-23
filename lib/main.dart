import 'package:flutter/material.dart';
import 'app/app.dart';
import 'modules/supabase/supabase_module.dart';
import 'modules/ai_script/ai_script_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 기본 모듈들 초기화
  await SupabaseModule.instance.initialize();
  AiScriptModule.instance.initialize();

  runApp(const MyApp());
}
