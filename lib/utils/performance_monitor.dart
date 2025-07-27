import 'dart:developer' as developer;

class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _measurements = {};

  static void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  static void endTimer(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _measurements.putIfAbsent(operation, () => []).add(duration);
      
      if (duration.inMilliseconds > 1000) {
        developer.log(
          'Slow operation detected: $operation took ${duration.inMilliseconds}ms',
          name: 'PerformanceMonitor',
          level: 900,
        );
      }
      
      _startTimes.remove(operation);
    }
  }

  static Duration? getAverageTime(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) return null;
    
    final totalMicroseconds = measurements.fold<int>(
      0, (sum, duration) => sum + duration.inMicroseconds);
    return Duration(microseconds: totalMicroseconds ~/ measurements.length);
  }

  static List<String> getSlowOperations({int thresholdMs = 1000}) {
    return _measurements.entries
        .where((entry) {
          final avgTime = getAverageTime(entry.key);
          return avgTime != null && avgTime.inMilliseconds > thresholdMs;
        })
        .map((entry) => entry.key)
        .toList();
  }

  static void clearMeasurements() {
    _measurements.clear();
    _startTimes.clear();
  }

  static void logPerformanceReport() {
    developer.log('=== Performance Report ===', name: 'PerformanceMonitor');
    
    for (final entry in _measurements.entries) {
      final avgTime = getAverageTime(entry.key);
      final count = entry.value.length;
      developer.log(
        '${entry.key}: ${avgTime?.inMilliseconds}ms avg (${count} measurements)',
        name: 'PerformanceMonitor',
      );
    }
    
    final slowOperations = getSlowOperations();
    if (slowOperations.isNotEmpty) {
      developer.log(
        'Slow operations: ${slowOperations.join(', ')}',
        name: 'PerformanceMonitor',
        level: 900,
      );
    }
  }
}

class AsyncPerformanceMonitor {
  static Future<T> measure<T>(String operation, Future<T> Function() task) async {
    PerformanceMonitor.startTimer(operation);
    try {
      final result = await task();
      return result;
    } finally {
      PerformanceMonitor.endTimer(operation);
    }
  }
} 