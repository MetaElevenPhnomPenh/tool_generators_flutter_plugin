import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/constant/value.dart';


class FieldData {
  final DartType type;
  final String typeString;
  final List<DartObject?> metaDrtObject;

  const FieldData({
    required this.type,
    required this.typeString,
    required this.metaDrtObject,
  });
}

// Step 1
class ModelVisitor extends SimpleElementVisitor<void> {
// Step 2
  String className = '';
  Map<String, FieldData> fields = {};

// Step 3
  @override
  void visitConstructorElement(ConstructorElement element) {
    final String returnType = element.returnType.toString();
    className = returnType.replaceAll("*", ""); // ClassName* -> ClassName
  }

// Step 4
  @override
  void visitFieldElement(FieldElement element) {
    /*
    {
      name: String,
      price: double
    }
     */
    String elementType = element.type.toString().replaceAll("*", "");
    List<DartObject?> metaDrtObject = [];
    for (var v in element.metadata) {
      metaDrtObject.add(v.computeConstantValue());
    }
    fields[element.name] = FieldData(type: element.type, typeString: elementType, metaDrtObject: metaDrtObject);
  }
}
