part of "../../easy_tree.dart";

mixin EasyTreeRelation on EasyTreeNode {
  @mustCallSuper
  void updateRelation(List<EasyTreeNodeKey> oldKeys, List<EasyTreeNodeKey> newKeys) {
    (easyTreeOwner as EasyTreeOwnerRelation?)?.updateNodeRelation(this, oldKeys, newKeys);
  }

  bool _getParentWhere(EasyTreeNode node) {
    EasyTreeNode p = this;
    while (p.easyTreeParent != node) {
      if (p.easyTreeParent == null) return false;
      p = p.easyTreeParent!;
    }
    return true;
  }

  /// 获取指定Key的父级列表
  Iterable<EasyTreeNode> easyTreeGetParentList(EasyTreeNodeKey key) {
    return (easyTreeOwner as EasyTreeOwnerRelation).treeAllKeyNodes(key).reversed.where(_getParentWhere);
  }

  /// 获取指定Key的父级
  EasyTreeNode? easyTreeGetParent(EasyTreeNodeKey key) => easyTreeGetParentList(key).firstOrNull;

  /// 获取指定Key上一个兄弟级
  EasyTreeNode? easyTreeGetPreviousSibling(EasyTreeNodeKey key) => easyTreeGetPreviousSiblingList(key).firstOrNull;

  /// 获取指定Key上一个兄弟级列表
  Iterable<EasyTreeNode> easyTreeGetPreviousSiblingList(EasyTreeNodeKey key) sync* {
    var list = easyTreeGetSiblingList(key, includeSelf: false).toList();
    Map<EasyTreeNode, int> sortIndexMap = {};
    var listChildren = easyTreeParent?.easyTreeChildren.toList() ?? [];
    for (var i = 0; i < listChildren.length; i++) {
      sortIndexMap[listChildren[i]] = i;
    }
    list.add(this);
    list.sort((a, b) => sortIndexMap[b]!.compareTo(sortIndexMap[a]!));
    bool yd = false;
    for (var element in list) {
      if (yd) yield element;
      if (element == this) yd = true;
    }
  }

  /// 获取指定Key下一个兄弟级别
  EasyTreeNode? easyTreeGetNextSibling(EasyTreeNodeKey key) => easyTreeGetNextSiblingList(key).firstOrNull;

  /// 获取指定Key下一个兄弟级别列表
  Iterable<EasyTreeNode> easyTreeGetNextSiblingList(EasyTreeNodeKey key) sync* {
    var list = easyTreeGetSiblingList(key, includeSelf: false).toList();
    Map<EasyTreeNode, int> sortIndexMap = {};
    var listChildren = easyTreeParent?.easyTreeChildren.toList() ?? [];
    for (var i = 0; i < listChildren.length; i++) {
      sortIndexMap[listChildren[i]] = i;
    }
    list.add(this);
    list.sort((a, b) => sortIndexMap[a]!.compareTo(sortIndexMap[b]!));
    bool yd = false;
    for (var element in list) {
      if (yd) yield element;
      if (element == this) yd = true;
    }
  }

  /// 获取指定Key兄弟级列表
  Iterable<EasyTreeNode> easyTreeGetSiblingList(EasyTreeNodeKey key, {bool includeSelf = false}) {
    if (includeSelf) {
      return (easyTreeOwner as EasyTreeOwnerRelation).treeAllKeyNodes(key).where((e) => e.easyTreeParent == easyTreeParent);
    } else {
      return (easyTreeOwner as EasyTreeOwnerRelation).treeAllKeyNodes(key).where((e) => e.easyTreeParent == easyTreeParent && e != this);
    }
  }

  /// 获取指定Key兄弟级
  EasyTreeNode? easyTreeGetSibling(EasyTreeNodeKey key, {bool includeSelf = false}) => easyTreeGetSiblingList(key, includeSelf: includeSelf).firstOrNull;

  /// 获取指定Key子级列表
  Iterable<EasyTreeNode> easyTreeGetChildren(EasyTreeNodeKey key) {
    assert(
      easyTreeOwner is EasyTreeOwnerRelation,
      "EasyTreeRelationChild的Owner必须为EasyTreeRelationOwner",
    );
    return (easyTreeOwner as EasyTreeOwnerRelation).treeAllKeyNodes(key).where((e) => e.easyTreeParent == this);
  }

  /// 获取指定Key子级
  EasyTreeNode? easyTreeGetChild(EasyTreeNodeKey key) => easyTreeGetChildren(key).firstOrNull;

  bool _getChildrenInAllWhere(EasyTreeNode node) {
    var p = node;
    while (p.easyTreeParent != this) {
      if (p.easyTreeParent == null) return false;
      p = p.easyTreeParent!;
    }
    return true;
  }

  /// 在全部子级（包括叶子级）中获取子级列表
  Iterable<EasyTreeNode> easyTreeGetChildrenInAll(EasyTreeNodeKey key) {
    assert(
      easyTreeOwner is EasyTreeOwnerRelation,
      "EasyTreeRelationAllChild的Owner必须为EasyTreeRelationOwner",
    );
    return (easyTreeOwner as EasyTreeOwnerRelation).treeAllKeyNodes(key).where(_getChildrenInAllWhere);
  }

  /// 在全部子级（包括叶子级）中获取子级
  EasyTreeNode? easyTreeGetChildInAll(EasyTreeNodeKey key) => easyTreeGetChildrenInAll(key).firstOrNull;
}
