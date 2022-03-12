import 'package:flutter_router/generated/json/base/json_convert_content.dart';
import 'package:flutter_router/json_test_entity.dart';

JsonTestEntity $JsonTestEntityFromJson(Map<String, dynamic> json) {
  final JsonTestEntity jsonTestEntity = JsonTestEntity();
  final int? test = jsonConvert.convert<int>(json['test']);
  if (test != null) {
    jsonTestEntity.test = test;
  }
  return jsonTestEntity;
}

Map<String, dynamic> $JsonTestEntityToJson(JsonTestEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['test'] = entity.test;
  return data;
}
