import 'package:analyzer/dart/element/element.dart';
import 'package:annotations/annotations.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:generators/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';

class JsonGenerator extends GeneratorForAnnotation<JsonAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final ModelVisitor visitor = ModelVisitor();
    // Visit class fields and constructor
    element.visitChildren(visitor);

    // Buffer to write each part of generated class
    final buffer = StringBuffer();

    String generatedFromJSon = generateFromJsonMethod(visitor);
    buffer.writeln(generatedFromJSon);

    String generatedToJSon = generateToJsonMethod(visitor);
    buffer.writeln(generatedToJSon);

    String generatedCopyWith = generateCopyWithMethod(visitor);
    buffer.writeln(generatedCopyWith);

    return buffer.toString();
  }

  // Method to generate fromJSon method
  String generateFromJsonMethod(ModelVisitor visitor) {
    // Class name from model visitor
    String className = visitor.className;

    // Buffer to write each part of generated class
    final buffer = StringBuffer();

    // --------------------Start fromJson Generation Code--------------------//
    buffer.writeln('// From Json Method');
    buffer.writeln('$className _\$${className}FromJson(Map<String, dynamic> json) => ');
    buffer.write('$className(');

    for (int i = 0; i < visitor.fields.length; i++) {
      final field = visitor.fields.values.elementAt(i);
      String dataType = field.typeString.toString();
      final bool isOptional = dataType.contains('?');
      dataType = dataType.replaceAll("?", "");
      bool isList = field.type.isDartCoreList;
      if (isList) {
        dataType = dataType.replaceAll("List<", "");
        dataType = dataType.replaceAll(">", "");
      }
      String fieldName = camelCaseToSnakeCase(visitor.fields.keys.elementAt(i));
      String mapValue = "json['$fieldName']";
      if (isObject(dataType)) {
        String fromJson = '$dataType.fromJson($mapValue)';
        if (isList) {
          fromJson = 'List<$dataType>.from($mapValue.map((v) => $dataType.fromJson(v)))';
        }
        mapValue = isOptional ? '$mapValue == null ? null : $fromJson' : fromJson;
      } else {
        if (isList) {
          mapValue = 'List<$dataType>.from($mapValue.map((v) => ${tranformValue(type: dataType, v: 'v', isOptional: isOptional)}))';
        } else {
          mapValue = tranformValue(type: dataType, v: mapValue, isOptional: isOptional);
        }
        if (isOptional) {
          mapValue = "json['$fieldName'] == null ? null : $mapValue";
        }
      }
      /*     for (var v in field.metaDrtObject) {
        if(v?.type?.element == JsonKey){
          var value = v?.getField('defaultValue')?.toBoolValue();
        }
      }*/
      buffer.writeln(
        "${visitor.fields.keys.elementAt(i)}: $mapValue,",
      );
    }
    buffer.writeln(');');
    buffer.toString();
    return buffer.toString();
    // --------------------End fromJson Generation Code--------------------//
  }

  String tranformValue({required String type, required String v, required bool isOptional}) {
    switch (type) {
      case 'String':
        return '$v.toString().toAppString()${isOptional ? '' : '!'}';
      case 'int':
        return '$v.toString().toAppInt()';
      case 'double':
        return '$v.toString().toAppDouble()';
      case 'bool':
        return '$v == true';
      default:
        return v;
    }
  }

  bool isObject(String v) {
    if (['String', 'int', 'double', 'bool', 'Color', 'num', 'dynamic'].contains(v)) {
      return false;
    }
    return true;
  }

  String camelCaseToSnakeCase(String input) {
    /*String result = input.replaceAllMapped(RegExp(r'([A-Z])'), (Match match) {
      return '_' + match.group(0)!.toLowerCase();
    });

    // Remove leading underscore if present
    if (result.startsWith('_')) {
      result = result.substring(1);
    }
    if(input == 'id'){
      return '_id';
    }
    */
    return input;
  }

  // Method to generate fromJSon method
  String generateToJsonMethod(ModelVisitor visitor) {
    // Class name from model visitor
    String className = visitor.className;

    // Buffer to write each part of generated class
    final buffer = StringBuffer();

    // --------------------Start toJson Generation Code--------------------//
    buffer.writeln('// To Json Method');
    buffer.writeln('Map<String, dynamic> _\$${className}ToJson($className instance) => ');
    buffer.write('<String, dynamic>{');
    for (int i = 0; i < visitor.fields.length; i++) {
      final field = visitor.fields.values.elementAt(i);
      String dataType = field.typeString.toString();
      bool isList = field.type.isDartCoreList;
      if (isList) {
        dataType = dataType.replaceAll("List<", "");
        dataType = dataType.replaceAll(">", "");
      }
      final bool isOptional = dataType.contains('?');
      dataType = dataType.replaceAll("?", "");
      String fieldName = visitor.fields.keys.elementAt(i);
      String jsonValue = "instance.$fieldName";
      if (isObject(dataType)) {
        if (isList) {
          jsonValue = 'List.from($jsonValue${isOptional ? '!' : ''}.map((v) => v.toJson()))';
          if (isOptional) {
            jsonValue = "instance.$fieldName == null ? null : $jsonValue";
          }
        } else {
          jsonValue = '$jsonValue${isOptional ? '?' : ''}.toJson()';
        }
      }
      buffer.writeln(
        "'${camelCaseToSnakeCase(fieldName)}': $jsonValue,",
      );
    }
    buffer.writeln('};');
    return buffer.toString();
    // --------------------End toJson Generation Code--------------------//
  }

  // Method to generate fromJSon method
  String generateCopyWithMethod(ModelVisitor visitor) {
    // Class name from model visitor
    String className = visitor.className;

    // Buffer to write each part of generated class
    final buffer = StringBuffer();

    // --------------------Start copyWith Generation Code--------------------//
    buffer.writeln("// Extension for a $className class to provide 'copyWith' method");
    buffer.writeln('extension \$${className}Extension on $className {');
    buffer.writeln('$className copyWith({');
    for (int i = 0; i < visitor.fields.length; i++) {
      final field = visitor.fields.values.elementAt(i);
      String dataType = field.typeString.toString().replaceAll("?", "");
      String fieldName = visitor.fields.keys.elementAt(i);
      buffer.writeln(
        '$dataType? $fieldName,',
      );
    }
    buffer.writeln('}) {');
    buffer.writeln('return $className(');
    for (int i = 0; i < visitor.fields.length; i++) {
      buffer.writeln(
        "${visitor.fields.keys.elementAt(i)}: ${visitor.fields.keys.elementAt(i)} ?? this.${visitor.fields.keys.elementAt(i)},",
      );
    }
    buffer.writeln(');');
    buffer.writeln('}');
    buffer.writeln('}');
    buffer.toString();
    return buffer.toString();
    // --------------------End copyWith Generation Code--------------------//
  }
}
