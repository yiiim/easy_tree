import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test/model.dart';
import 'test/widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    "test easytree",
    (tester) async {
      var testModel = TestEasyTreeModel.randomGenerate(
        maxElementNumber: 100,
        key: "0",
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestWidget(
              key: ValueKey(testModel.key),
              childNum: testModel,
            ),
          ),
        ),
      );
      for (var i = 0; i < 100; i++) {
        await tester.pump();
        debugPrint("测试树");
        testModel.testEasyTree();
      }
      for (var i = 0; i < 100; i++) {
        testModel.shuffle(deep: true);
        testModel.markNeedsBuild();
        await tester.pump();
        debugPrint("测试树打乱");
        testModel.testEasyTree();
      }
      for (var i = 0; i < 100; i++) {
        debugPrint("测试树增删节点");
        testModel.append();
        testModel.markNeedsBuild();
        await tester.pump();
        testModel.testEasyTree();
        testModel.layoffs();
        testModel.markNeedsBuild();
        await tester.pump();
        testModel.testEasyTree();
      }
    },
  );
}
