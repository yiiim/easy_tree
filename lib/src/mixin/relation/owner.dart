part of "../../easy_tree.dart";

mixin EasyTreeOwnerRelation on EasyTreeOwner, EasyTreeRelation {
  late final Map<EasyTreeNodeKey, List<EasyTreeNode>> _allKeyMapNodes = () {
    var initMap = <EasyTreeNodeKey, List<EasyTreeNode>>{};
    for (var item in keys) {
      initMap[item] = [this];
    }
    return initMap;
  }();

  @override
  Iterable<EasyTreeNode> easyTreeGetChildrenInAll(EasyTreeNodeKey key) {
    return _allKeyMapNodes[key] ?? [];
  }

  @override
  void mountEasyTreeNode(EasyTreeNode? parent, EasyTreeNode node) {
    for (var element in node.keys) {
      _allKeyMapNodes[element] ??= [];
      _allKeyMapNodes[element]!.add(node);
    }
    super.mountEasyTreeNode(parent, node);
  }

  @override
  void unmountEasyTreeNode(EasyTreeNode node) {
    for (var element in node.keys) {
      _allKeyMapNodes[element]?.remove(node);
    }
    super.unmountEasyTreeNode(node);
  }

  void updateNodeRelation(EasyTreeNode node, List<EasyTreeNodeKey> oldKeys, List<EasyTreeNodeKey> newKeys) {
    for (var element in newKeys) {
      if (!oldKeys.contains(element)) {
        _allKeyMapNodes[element] ??= [];
        _allKeyMapNodes[element]!.add(node);
      } else {
        oldKeys.remove(element);
      }
    }
    for (var element in oldKeys) {
      _allKeyMapNodes[element]?.remove(node);
    }
  }

  List<EasyTreeNode> treeAllKeyNodes(EasyTreeNodeKey key) => _allKeyMapNodes[key] ?? [];
}
