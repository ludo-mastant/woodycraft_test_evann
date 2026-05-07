int readInt(dynamic value, [int defaultValue = 0]) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? defaultValue;
}

double readDouble(dynamic value, [double defaultValue = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse((value?.toString() ?? '').replaceAll(',', '.')) ??
      defaultValue;
}

String readString(dynamic value, [String defaultValue = '']) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return defaultValue;
  return text;
}

List<dynamic> readList(dynamic value) {
  if (value is List) return value;
  if (value is Map && value['data'] is List) return value['data'] as List;
  return [];
}

Map<String, dynamic> readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
