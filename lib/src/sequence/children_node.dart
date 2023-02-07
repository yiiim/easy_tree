part of "../easy_tree.dart";

/// 序列树中多个节点的父级节点
class EasySequenceTreeChildrenNode extends EasySequenceTreeNode with EasySequenceTreeNodeMixin {
  EasySequenceTreeChildrenNode(Element element) : _easyTreeKeyNodeHostElement = element;

  @override
  void mountEasySequenceTreeNode(EasySequenceTreeNode? parent, {Element? topElement}) {
    super.mountEasySequenceTreeNode(parent, topElement: topElement);
    assert(owner != null);
    owner?.updateEasyTreeElementsSequenceChildrenNode(element, this);
  }

  @override
  void unmountEasySequenceTreeNode() {
    assert(owner != null);
    owner?.updateEasyTreeElementsSequenceChildrenNode(element, null);
    super.unmountEasySequenceTreeNode();
  }

  bool _unmountSelfIfNeed() {
    if (mounted == false) return false;
    if (easySequenceTreeNodeChildren.length <= 1) {
      if (easySequenceTreeNodeChildren.length == 1) {
        var onlyOne = easySequenceTreeNodeChildren.first;
        onlyOne.updateEasySequenceTreeNodeParent(_parent, topElement: topElement);
        _parent?.updateEasySequenceTreeNodeChild(this, onlyOne);
      } else {
        _parent?.updateEasySequenceTreeNodeChild(this, null);
      }
      unmountEasySequenceTreeNode();
      return true;
    }
    return false;
  }

  @override
  void updateEasySequenceTreeNodeChild(EasySequenceTreeNode? oldNode, EasySequenceTreeNode? newNode) {
    super.updateEasySequenceTreeNodeChild(oldNode, newNode);
    if (oldNode != null) {
      _unmountSelfIfNeed();
    }
    assert(owner?.easyTreeElementsSequenceChildrenNode(element) == null || easySequenceTreeNodeChildren.isNotEmpty);
  }

  final Element _easyTreeKeyNodeHostElement;
  @override
  Element get element => _easyTreeKeyNodeHostElement;
}
