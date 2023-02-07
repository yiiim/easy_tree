part of "../../easy_tree.dart";

mixin EasyTreeSequenceMixin on EasyTreeNode {
  late final EasySequenceTreeOwner easySequenceTreeOwner = EasySequenceTreeOwner(this);

  @override
  void updateEasyTreeNodeChild(EasyTreeNode? oldNode, EasyTreeNode? newNode) {
    super.updateEasyTreeNodeChild(oldNode, newNode);

    /// 添加子节点时，同时把节点添加到序列树
    if (newNode != null) {
      easySequenceTreeOwner.addEasyTreeChildNode(newNode);
    }

    /// 移除子节点时，同时把节点从序列树移除
    if (oldNode != null) {
      easySequenceTreeOwner.removeEasyTreeChildNode(oldNode);
      // 找到序列树中的节点
      var sequenceTreeNode = easySequenceTreeOwner.easyTreeNodesSequenceNode(oldNode);
      // 卸载节点
      sequenceTreeNode?.unmountEasySequenceTreeNode();
      // 告诉节点父级更新
      sequenceTreeNode?.parent?.updateEasySequenceTreeNodeChild(sequenceTreeNode, null);
    }
  }
}
