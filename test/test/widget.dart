import 'dart:math';

import 'package:easy_tree/easy_tree.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class TestWidget extends Widget {
  const TestWidget({this.childNum, Key? key}) : super(key: key);
  final TestEasyTreeModel? childNum;
  @override
  Element createElement() => TestElement(this);
}

class TestElement extends EasyTreeRelationElement {
  TestElement(super.widget) : num = (widget as TestWidget).childNum {
    num?.element = this;
  }
  TestEasyTreeModel? num;

  @override
  Widget buildChild() {
    var group = <List<TestEasyTreeModel>>[];
    var childCount = (num?.children?.length ?? 0);
    if (childCount > 0) {
      var groupLength = Random().nextInt((childCount / 2).ceil()) + 1;
      var leftCount = childCount;
      for (var i = 0; i < groupLength; i++) {
        var count = i == groupLength - 1 ? leftCount : Random().nextInt(leftCount);
        group.add(
          List.generate(count, (index) => num!.children![childCount - leftCount + index]),
        );
        leftCount -= count;
      }
      assert(group.fold<int>(0, (previousValue, element) => previousValue + element.length) == childCount);
    }
    return Container(
      color: num?.color,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              num?.testEasyTree();
              TestElement before = easyTreeGetChild(TestEasyTreeModel.testElementAnyKey) as TestElement;
              num?.shuffle(deep: true);
              num?.markNeedsBuild();
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                var after = easyTreeGetChild(TestEasyTreeModel.testElementAnyKey) as TestElement;
                assert(before == after);
                num?.testEasyTree();
              });
            },
            behavior: HitTestBehavior.translucent,
            child: Text("${num?.key})"),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.unmodifiable(
                group.map(
                  (e) => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      e.length,
                      (index) => index % 2 == 0
                          ? TestWidget(
                              key: ValueKey(e[index].key),
                              childNum: e[index],
                            )
                          : SizedBox(
                              child: TestWidget(
                                key: ValueKey(e[index].key),
                                childNum: e[index],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void update(covariant Widget newWidget) {
    super.update(newWidget);
    assert((newWidget as TestWidget).childNum == num);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    num?.parent?.mountSortChildren.add(num!);
    num?.parent?.appendSortAllChildren(num!);
    super.mount(parent, newSlot);
  }

  @override
  void activate() {
    num?.parent?.mountSortChildren.add(num!);
    num?.parent?.appendSortAllChildren(num!);
    super.activate();
  }

  @override
  void deactivate() {
    assert(num?.parent == null || num!.parent!.mountSortChildren.contains(num));
    num?.parent?.mountSortChildren.remove(num!);
    num?.parent?.removeSortAllChildren(num!);
    super.deactivate();
  }

  @override
  List<EasyTreeNodeKey> get keys => [TestEasyTreeModel.testElementAnyKey, EasyTreeNodeKey(num?.key)];
}
