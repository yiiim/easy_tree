part of "../easy_tree.dart";

/// 序列树的节点
abstract class EasySequenceTreeNode {
  /// 当前节点在Element树中的所属节点
  Element get element;

  /// 当前节点在上级节点中的直接子节点
  Element? get topElement;

  /// owner
  EasySequenceTreeOwner? get owner;

  /// 当前的父级节点
  EasySequenceTreeNode? get parent;

  /// 挂载节点
  void mountEasySequenceTreeNode(EasySequenceTreeNode? parent, {Element? topElement});

  /// 卸载节点
  void unmountEasySequenceTreeNode();

  /// 更新节点父级
  void updateEasySequenceTreeNodeParent(EasySequenceTreeNode? parent, {Element? topElement});

  /// 更新节点子级
  void updateEasySequenceTreeNodeChild(EasySequenceTreeNode? oldNode, EasySequenceTreeNode? newNode);

  /// 重新构建子级，如果需要
  void rebuildIfNeed();

  /// 直接子级列表
  List<EasySequenceTreeNode> get easySequenceTreeNodeChildren;

  /// 递归子级
  void visitEasySequenceTreeChildNode(bool Function(EasySequenceTreeNode element) visitor);
}
