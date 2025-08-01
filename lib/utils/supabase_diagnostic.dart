import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'env_config.dart';

class SupabaseDiagnostic {
  /// Run comprehensive diagnostic tests
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};
    
    print('🔍 Starting Supabase diagnostic tests...');
    
    // Test 1: Configuration
    results['configuration'] = await _testConfiguration();
    
    // Test 2: Connectivity
    results['connectivity'] = await _testConnectivity();
    
    // Test 3: Storage
    results['storage'] = await _testStorage();
    
    // Test 4: Bucket
    results['bucket'] = await _testBucket();
    
    // Test 5: Permissions
    results['permissions'] = await _testPermissions();
    
    print('✅ Diagnostic tests completed');
    return results;
  }
  
  /// Test configuration
  static Future<Map<String, dynamic>> _testConfiguration() async {
    final results = <String, dynamic>{};
    
    try {
      results['urlConfigured'] = EnvConfig.supabaseUrl.isNotEmpty;
      results['keyConfigured'] = EnvConfig.supabaseAnonKey.isNotEmpty;
      results['isConfigured'] = EnvConfig.isSupabaseConfigured;
      
      if (results['isConfigured']) {
        print('✅ Supabase configuration is valid');
      } else {
        print('❌ Supabase configuration is missing');
      }
    } catch (e) {
      results['error'] = e.toString();
      print('❌ Configuration test failed: $e');
    }
    
    return results;
  }
  
  /// Test connectivity
  static Future<Map<String, dynamic>> _testConnectivity() async {
    final results = <String, dynamic>{};
    
    try {
      if (!EnvConfig.isSupabaseConfigured) {
        results['connected'] = false;
        results['error'] = 'Not configured';
        return results;
      }
      
      // Test basic connectivity
      await SupabaseConfig.client.storage.listBuckets();
      results['connected'] = true;
      print('✅ Supabase connectivity test passed');
    } catch (e) {
      results['connected'] = false;
      results['error'] = e.toString();
      print('❌ Supabase connectivity test failed: $e');
    }
    
    return results;
  }
  
  /// Test storage
  static Future<Map<String, dynamic>> _testStorage() async {
    final results = <String, dynamic>{};
    
    try {
      if (!EnvConfig.isSupabaseConfigured) {
        results['available'] = false;
        results['error'] = 'Not configured';
        return results;
      }
      
      // Test storage access
      final buckets = await SupabaseConfig.client.storage.listBuckets();
      results['available'] = true;
      results['bucketCount'] = buckets.length;
      results['bucketNames'] = buckets.map((b) => b.name).toList();
      
      print('✅ Storage test passed. Found ${buckets.length} buckets');
    } catch (e) {
      results['available'] = false;
      results['error'] = e.toString();
      print('❌ Storage test failed: $e');
    }
    
    return results;
  }
  
  /// Test bucket
  static Future<Map<String, dynamic>> _testBucket() async {
    final results = <String, dynamic>{};
    
    try {
      if (!EnvConfig.isSupabaseConfigured) {
        results['exists'] = false;
        results['error'] = 'Not configured';
        return results;
      }
      
      final buckets = await SupabaseConfig.client.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == 'climacore-images');
      
      results['exists'] = bucketExists;
      results['bucketName'] = 'climacore-images';
      
      if (bucketExists) {
        print('✅ Storage bucket "climacore-images" exists');
      } else {
        print('❌ Storage bucket "climacore-images" not found');
        results['suggestion'] = 'Create the bucket manually in Supabase dashboard';
      }
    } catch (e) {
      results['exists'] = false;
      results['error'] = e.toString();
      print('❌ Bucket test failed: $e');
    }
    
    return results;
  }
  
  /// Test permissions
  static Future<Map<String, dynamic>> _testPermissions() async {
    final results = <String, dynamic>{};
    
    try {
      if (!EnvConfig.isSupabaseConfigured) {
        results['canUpload'] = false;
        results['error'] = 'Not configured';
        return results;
      }
      
      // Test if we can list files in our bucket
      try {
        await SupabaseConfig.client.storage.from('climacore-images').list();
        results['canList'] = true;
        results['canUpload'] = true;
        print('✅ Storage permissions test passed');
      } catch (e) {
        results['canList'] = false;
        results['canUpload'] = false;
        results['error'] = e.toString();
        print('❌ Storage permissions test failed: $e');
      }
    } catch (e) {
      results['canUpload'] = false;
      results['error'] = e.toString();
      print('❌ Permissions test failed: $e');
    }
    
    return results;
  }
  
  /// Generate diagnostic report
  static String generateReport(Map<String, dynamic> results) {
    final report = StringBuffer();
    report.writeln('📊 SUPABASE DIAGNOSTIC REPORT');
    report.writeln('=' * 50);
    
    // Configuration
    final config = results['configuration'] as Map<String, dynamic>;
    report.writeln('\n🔧 CONFIGURATION:');
    report.writeln('URL Configured: ${config['urlConfigured']}');
    report.writeln('Key Configured: ${config['keyConfigured']}');
    report.writeln('Overall: ${config['isConfigured'] ? '✅ OK' : '❌ FAILED'}');
    
    // Connectivity
    final connectivity = results['connectivity'] as Map<String, dynamic>;
    report.writeln('\n🌐 CONNECTIVITY:');
    report.writeln('Connected: ${connectivity['connected'] ? '✅ OK' : '❌ FAILED'}');
    if (connectivity['error'] != null) {
      report.writeln('Error: ${connectivity['error']}');
    }
    
    // Storage
    final storage = results['storage'] as Map<String, dynamic>;
    report.writeln('\n💾 STORAGE:');
    report.writeln('Available: ${storage['available'] ? '✅ OK' : '❌ FAILED'}');
    if (storage['bucketCount'] != null) {
      report.writeln('Buckets Found: ${storage['bucketCount']}');
    }
    if (storage['error'] != null) {
      report.writeln('Error: ${storage['error']}');
    }
    
    // Bucket
    final bucket = results['bucket'] as Map<String, dynamic>;
    report.writeln('\n🪣 BUCKET:');
    report.writeln('Exists: ${bucket['exists'] ? '✅ OK' : '❌ FAILED'}');
    report.writeln('Name: ${bucket['bucketName']}');
    if (bucket['suggestion'] != null) {
      report.writeln('Suggestion: ${bucket['suggestion']}');
    }
    if (bucket['error'] != null) {
      report.writeln('Error: ${bucket['error']}');
    }
    
    // Permissions
    final permissions = results['permissions'] as Map<String, dynamic>;
    report.writeln('\n🔐 PERMISSIONS:');
    report.writeln('Can Upload: ${permissions['canUpload'] ? '✅ OK' : '❌ FAILED'}');
    if (permissions['error'] != null) {
      report.writeln('Error: ${permissions['error']}');
    }
    
    // Summary
    report.writeln('\n📋 SUMMARY:');
    final allTests = [
      config['isConfigured'],
      connectivity['connected'],
      storage['available'],
      bucket['exists'],
      permissions['canUpload'],
    ];
    
    final passedTests = allTests.where((test) => test == true).length;
    final totalTests = allTests.length;
    
    report.writeln('Tests Passed: $passedTests/$totalTests');
    
    if (passedTests == totalTests) {
      report.writeln('🎉 All tests passed! Supabase is properly configured.');
    } else {
      report.writeln('⚠️ Some tests failed. Check the details above.');
      report.writeln('\n🔧 RECOMMENDED FIXES:');
      
      if (!config['isConfigured']) {
        report.writeln('• Configure Supabase URL and API key in env_config.dart');
      }
      if (!connectivity['connected']) {
        report.writeln('• Check your internet connection and Supabase URL');
      }
      if (!storage['available']) {
        report.writeln('• Check Supabase project status and API key permissions');
      }
      if (!bucket['exists']) {
        report.writeln('• Create "climacore-images" bucket in Supabase dashboard');
      }
      if (!permissions['canUpload']) {
        report.writeln('• Configure storage policies in Supabase dashboard');
      }
    }
    
    return report.toString();
  }
  
  /// Show diagnostic dialog
  static Future<void> showDiagnosticDialog(BuildContext context) async {
    final results = await runDiagnostics();
    final report = generateReport(results);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supabase Diagnostic Report'),
        content: SingleChildScrollView(
          child: Text(report),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 