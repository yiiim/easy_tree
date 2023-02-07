part of "../../easy_tree.dart";

mixin EasyTreeSortRelation on EasyTreeNode, EasyTreeRelation, EasyTreeSequenceMixin {
  /// 获取指定Key顺序正确的子级列表
  Iterable<EasyTreeNode> easyTreeGetSortedChildren(EasyTreeNodeKey key) {
    var result = easyTreeGetChildren(key);
    if (result.length <= 1) return result;
    result = result.sorted(easySequenceTreeOwner.sortNode);
    return result;
  }

  /// 获取指定Key顺序正确的子级
  EasyTreeNode? easyTreeGetSortedChild(EasyTreeNodeKey key) => easyTreeGetSortedChildren(key).firstOrNull;

  /// 在全部子级（包括叶子级）中获取指定Key顺序正确的子级列表
  Iterable<EasyTreeNode> easyTreeGetSortedChildrenInAll(EasyTreeNodeKey key) {
    var result = easyTreeGetChildrenInAll(key);
    if (result.length <= 1) return result;
    return easySequenceTreeOwner.deepSortNodes(result.toList());
  }

  /// 在全部子级（包括叶子级）中获取指定Key顺序正确的子级
  EasyTreeNode? easyTreeGetSortedChildInAll(EasyTreeNodeKey key) => easyTreeGetSortedChildrenInAll(key).firstOrNull;

  /// 获取指定Key顺序正确的上一个兄弟级
  EasyTreeNode? easyTreeGetSortedPreviousSibling(EasyTreeNodeKey key) {
    var list = easyTreeGetSiblingList(key, includeSelf: false).toList();
    if (easyTreeParent is EasyTreeSequenceMixin) {
      list.add(this);
      list.sort((easyTreeParent as EasyTreeSequenceMixin).easySequenceTreeOwner.sortNode);
    }
    EasyTreeNode? result;
    for (var element in list) {
      if (element == this) break;
      result = element;
    }
    return result;
  }

  /// 获取指定Key顺序正确的下一个兄弟级别
  EasyTreeNode? easyTreeGetSortedNextSibling(EasyTreeNodeKey key) {
    var list = easyTreeGetSiblingList(key, includeSelf: false).toList();
    if (easyTreeParent is EasyTreeSequenceMixin) {
      list.add(this);
      list.sort((easyTreeParent as EasyTreeSequenceMixin).easySequenceTreeOwner.sortNode);
    }
    EasyTreeNode? result;
    for (var element in list.reversed) {
      if (element == this) break;
      result = element;
    }
    return result;
  }

  /// 获取指定Key顺序正确的兄弟级
  EasyTreeNode? easyTreeGetSortedSibling(EasyTreeNodeKey key, {bool includeSelf = false}) => easyTreeGetSortedSiblingList(key, includeSelf: includeSelf).firstOrNull;

  /// 获取指定Key顺序正确的兄弟级列表
  Iterable<EasyTreeNode> easyTreeGetSortedSiblingList(EasyTreeNodeKey key, {bool includeSelf = false}) {
    var result = easyTreeGetSiblingList(key, includeSelf: includeSelf);
    if (result.length <= 1) return result;
    return result.sorted(easySequenceTreeOwner.sortNode);
  }
}
