import 'dart:math';

import 'package:easy_tree/easy_tree.dart';
import 'package:flutter/material.dart';

import 'widget.dart';

class TestEasyTreeModel {
  static const testElementAnyKey = EasyTreeNodeKey(TestElement);
  TestEasyTreeModel(this.key, {this.parent, this.children}) : _appendKeyIndex = children?.length ?? 1;
  final String key;
  final Color color = Color.fromARGB(255, Random().nextInt(155) + 100, Random().nextInt(155) + 100, Random().nextInt(155) + 100);
  final TestEasyTreeModel? parent;
  TestElement? element;
  List<TestEasyTreeModel>? children;
  List<TestEasyTreeModel> mountSortChildren = [];
  List<TestEasyTreeModel> mountSortAllChildren = [];
  void appendSortAllChildren(TestEasyTreeModel item) {
    mountSortAllChildren.add(item);
    parent?.appendSortAllChildren(item);
  }

  void removeSortAllChildren(TestEasyTreeModel item) {
    mountSortAllChildren.remove(item);
    parent?.removeSortAllChildren(item);
  }

  List<TestEasyTreeModel> get allChildren {
    List<TestEasyTreeModel> result = [];
    for (var element in children ?? <TestEasyTreeModel>[]) {
      result.add(element);
      result.addAll(element.allChildren);
    }
    return result;
  }

  factory TestEasyTreeModel.randomGenerate({int maxElementNumber = 100, String key = "1", TestEasyTreeModel? parent}) {
    int childNum = Random().nextInt(5) + 2;
    childNum = min(maxElementNumber, childNum);

    var leftElementNumber = maxElementNumber - childNum;
    List<int> childChildNum = List.generate(childNum, (index) => 0);
    if (leftElementNumber > 0) {
      for (var i = 0; i < childNum; i++) {
        childChildNum[i] = Random().nextInt(leftElementNumber);
        leftElementNumber -= childChildNum[i];
      }
    }
    var m = TestEasyTreeModel(key, parent: parent);
    m.children = List.generate(
      childNum,
      (index) => TestEasyTreeModel.randomGenerate(
        maxElementNumber: childChildNum[index],
        key: "$key-${index + 1}",
        parent: m,
      ),
    );
    m._appendKeyIndex = m.children?.length ?? 1;
    return m;
  }

  @override
  String toString() {
    return key;
  }

  void shuffle({bool deep = true}) {
    children?.shuffle();
    for (var i = 0; i < (children?.length ?? 0); i++) {
      if (deep) {
        children?[i].shuffle(deep: deep);
      }
    }
  }

  void layoffs({bool deep = true}) {
    if (children?.isEmpty != false) return;
    int index = Random().nextInt(children?.length ?? 0);
    children?.removeAt(index);
    if (deep) {
      for (var i = 0; i < (children?.length ?? 0); i++) {
        if (deep) {
          children?[i].layoffs(deep: deep);
        }
      }
    }
    assert(children?.map((e) => e.key).toSet().length == children?.length);
  }

  int _appendKeyIndex;
  void append({bool deep = true}) {
    if (children?.isEmpty != false) return;
    int insertIndex = Random().nextInt((children?.length ?? 0) + 1);
    var insertChild = TestEasyTreeModel.randomGenerate(maxElementNumber: Random().nextInt(2) + 1, key: "$key-${++_appendKeyIndex}", parent: this);
    children?.insert(insertIndex, insertChild);
    if (deep) {
      for (var i = 0; i < (children?.length ?? 0); i++) {
        if (deep && children?[i] != insertChild) {
          children?[i].append(deep: deep);
        }
      }
    }
    assert(children?.map((e) => e.key).toSet().length == children?.length);
  }

  void testEasyTree() {
    assert(element != null);
    assert(element?.num == this);
    assert(element?.easyTreeHostElement == element);
    assert(element?.easyTreeParent == parent?.element || element?.easyTreeParent == EasyTreeOwner.sharedOwner);
    assert((element?.widget.key as ValueKey).value == key);
    assert((children ?? <TestEasyTreeModel>[]).every((e) => element?.easyTreeChildren.contains(e.element) ?? false));
    assert(parent == ((element?.easyTreeOwner == element?.easyTreeParent) ? null : (element?.easyTreeParent as TestElement?)?.num));
    assert((children ?? <TestEasyTreeModel>[]).every((e) => mountSortChildren.contains(e)));
    assert(allChildren.every((e) => mountSortAllChildren.contains(e)));

    var parenChildren = [...parent?.children ?? []];
    var parentMountSortChildren = [...parent?.mountSortChildren ?? []];
    var parenAllChildren = [...parent?.allChildren ?? []];
    var parentMountSortAllChildren = [...parent?.mountSortAllChildren ?? []];
    assert(parenChildren.every((e) => parentMountSortChildren.contains(e)));
    assert(parenAllChildren.every((e) => parentMountSortAllChildren.contains(e)));

    // 挂载顺序的子级
    var relationChildren = element?.easyTreeGetChildren(TestEasyTreeModel.testElementAnyKey).toList();
    for (var i = 0; i < (relationChildren?.length ?? 0); i++) {
      assert((relationChildren![i] as TestElement).num == mountSortChildren[i]);
    }

    // 挂载顺序的全部子级
    var relationAllChildren = element?.easyTreeGetChildrenInAll(TestEasyTreeModel.testElementAnyKey).toList();
    for (var i = 0; i < (relationAllChildren?.length ?? 0); i++) {
      assert((relationAllChildren![i] as TestElement).num == mountSortAllChildren[i]);
    }

    // 挂载顺序的同级
    var relationSibling = element?.easyTreeGetSiblingList(TestEasyTreeModel.testElementAnyKey, includeSelf: true).toList();
    for (var i = 0; i < (relationSibling?.length ?? 0); i++) {
      assert((parent == null && (relationSibling![i] as TestElement).easyTreeOwner == EasyTreeOwner.sharedOwner) || (relationSibling![i] as TestElement).num == parentMountSortChildren[i]);
    }

    // 挂载顺序的前面的节点
    var relationPreviousSibling = element?.easyTreeGetPreviousSiblingList(TestEasyTreeModel.testElementAnyKey).toList();
    relationPreviousSibling = relationPreviousSibling?.reversed.toList();
    for (var i = 0; i < (relationPreviousSibling?.length ?? 0); i++) {
      if (parentMountSortChildren[i] == this) {
        assert(i == relationPreviousSibling!.length - 1);
        break;
      }
      assert((parent == null && (relationSibling![i] as TestElement).easyTreeOwner == EasyTreeOwner.sharedOwner) || (relationPreviousSibling![i] as TestElement).num == parentMountSortChildren[i]);
    }

    // 挂载顺序的后面的节点
    var relationNextSibling = element?.easyTreeGetNextSiblingList(TestEasyTreeModel.testElementAnyKey).toList();
    int j = -1;
    for (var i = 0; i < parentMountSortChildren.length; i++) {
      if (j > -1) {
        assert((parent == null && (relationSibling![i] as TestElement).easyTreeOwner == EasyTreeOwner.sharedOwner) || (relationNextSibling![j] as TestElement).num == parentMountSortChildren[i]);
        j++;
      }
      if (parentMountSortChildren[i] == this) {
        j++;
      }
    }

    // 父级列表
    var relationParents = element?.easyTreeGetParentList(TestEasyTreeModel.testElementAnyKey).toList();
    TestEasyTreeModel? c = parent;
    for (var i = 0; i < (relationParents?.length ?? 0); i++) {
      assert((relationParents![i] == EasyTreeOwner.sharedOwner && c == null) || ((relationParents[i] as TestElement).num == c));
      c = c?.parent;
    }

    // 父级
    TestEasyTreeModel? relationParentSelf = this;
    while (relationParentSelf?.parent != null) {
      var testParent = element?.easyTreeGetParent(EasyTreeNodeKey(relationParentSelf?.parent!.key));
      assert(testParent != null);
      assert(testParent == EasyTreeOwner.sharedOwner || testParent is TestElement);
      assert(testParent == EasyTreeOwner.sharedOwner || (testParent as TestElement).num == relationParentSelf?.parent!);
      relationParentSelf = relationParentSelf?.parent;
    }

    // 正确顺序的子级
    var relationSortedChildren = element?.easyTreeGetSortedChildren(TestEasyTreeModel.testElementAnyKey).toList();
    for (var i = 0; i < (relationSortedChildren?.length ?? 0); i++) {
      assert((relationSortedChildren![i] as TestElement).num == children![i]);
    }

    // 正确顺序的全部子级
    var relationSortedChildrenInAll = element?.easyTreeGetSortedChildrenInAll(TestEasyTreeModel.testElementAnyKey).toList();
    assert((children ?? <TestEasyTreeModel>[]).every((e) => relationChildren?.contains(e.element) ?? false));
    assert(relationSortedChildrenInAll?.length == allChildren.length);
    for (var i = 0; i < (relationSortedChildrenInAll?.length ?? 0); i++) {
      assert((relationSortedChildrenInAll![i] as TestElement).num == allChildren[i]);
    }

    // 测试子级
    for (var i = 0; i < (children?.length ?? 0); i++) {
      var item = children![i];
      assert(element?.easyTreeGetChild(EasyTreeNodeKey(item.key)) == item.element);
      assert(element?.easyTreeGetChildInAll(EasyTreeNodeKey(item.key)) == item.element);
      assert(element?.easyTreeGetSortedChild(EasyTreeNodeKey(item.key)) == item.element);
      assert(element?.easyTreeGetSortedChildInAll(EasyTreeNodeKey(item.key)) == item.element);
      for (var j = 0; j < mountSortChildren.indexOf(item); j++) {
        assert(item.element?.easyTreeGetPreviousSibling(EasyTreeNodeKey(mountSortChildren[j].key)) == mountSortChildren[j].element);
      }
      for (var j = 0; j < i; j++) {
        assert(item.element?.easyTreeGetSortedPreviousSibling(EasyTreeNodeKey(children![j].key)) == children![j].element);
      }
      for (var j = mountSortChildren.indexOf(item) + 1; j < mountSortChildren.length; j++) {
        assert(item.element?.easyTreeGetNextSibling(EasyTreeNodeKey(mountSortChildren[j].key)) == mountSortChildren[j].element);
      }
      for (var j = i + 1; j < children!.length; j++) {
        assert(item.element?.easyTreeGetSortedNextSibling(EasyTreeNodeKey(children![j].key)) == children![j].element);
      }
      for (var j = 0; j < children!.length; j++) {
        assert(item.element?.easyTreeGetSibling(EasyTreeNodeKey(children![j].key), includeSelf: true) == children![j].element);
        assert(item.element?.easyTreeGetSortedSibling(EasyTreeNodeKey(children![j].key), includeSelf: true) == children![j].element);
      }

      item.testEasyTree();
    }
  }

  void markNeedsBuild() {
    element?.markNeedsBuild();
    for (var element in children ?? <TestEasyTreeModel>[]) {
      element.markNeedsBuild();
    }
  }
}
