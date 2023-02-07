part of "../easy_tree.dart";

/// 序列树中属于节点树节点的节点
class EasySequenceTreeElementNode extends EasySequenceTreeNode with EasySequenceTreeNodeMixin {
  EasySequenceTreeElementNode(this.easyTreeNode);
  final EasyTreeNode easyTreeNode;

  @override
  Element get element => easyTreeNode.easyTreeHostElement;

  @override
  void mountEasySequenceTreeNode(EasySequenceTreeNode? parent, {Element? topElement}) {
    super.mountEasySequenceTreeNode(parent, topElement: topElement);
    owner?.updateEasyTreeNodesSequenceNode(easyTreeNode, this);
  }

  @override
  void unmountEasySequenceTreeNode() {
    super.unmountEasySequenceTreeNode();
    owner?.updateEasyTreeNodesSequenceNode(easyTreeNode, null);
  }

  @override
  void updateEasySequenceTreeNodeParent(EasySequenceTreeNode? parent, {Element? topElement}) {
    super.updateEasySequenceTreeNodeParent(parent, topElement: topElement);
    owner?.updateEasyTreeNodesSequenceNode(easyTreeNode, this);
  }
}
