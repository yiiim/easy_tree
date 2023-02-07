part of "easy_tree.dart";

/// EasyTree节点
abstract class EasyTreeNode {
  /// 当前节点在Element树中的所属节点
  Element get easyTreeHostElement;

  /// owner
  EasyTreeOwner? get easyTreeOwner;

  /// 层级
  int get easyTreeDepth;

  /// 父级
  EasyTreeNode? get easyTreeParent;

  /// 子级
  Iterable<EasyTreeNode> get easyTreeChildren;

  /// 挂载节点
  void mountEasyTree(EasyTreeNode? parent);

  /// 卸载节点
  void unmountEasyTree();

  /// 更新子节点
  ///
  /// 如果[oldNode]不为空则从子节点中移除oldNode
  /// 如果[newNode]不为空，则添加子节点
  void updateEasyTreeNodeChild(EasyTreeNode? oldNode, EasyTreeNode? newNode);

  /// 递归子级
  void visitEasyTreeChildNode(bool Function(EasyTreeNode element) visitor);

  /// keys
  List<EasyTreeNodeKey> get keys;
}
