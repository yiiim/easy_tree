part of "easy_tree.dart";

/// EasyTree所有者，每棵树可以有一个所有者
///
/// 如果对树指定不同的所有者，那么它们将是不同的树
/// owner也是一树节点，它是树的根节点
class EasyTreeOwner extends EasyTreeNode with EasyTreeNodeMixin {
  EasyTreeOwner() {
    mountEasyTree(null);
  }
  static final EasyTreeOwner _sharedOwner = EasyTreeRelationOwner();
  static EasyTreeOwner get sharedOwner => _sharedOwner;

  @override
  EasyTreeOwner? get easyTreeOwner => this;

  @override
  Element get easyTreeHostElement => WidgetsBinding.instance.renderViewElement!;

  @override
  List<EasyTreeNodeKey> get keys => [];

  /// 将节点挂载到树上
  void mountEasyTreeNode(EasyTreeNode? parent, EasyTreeNode node) {
    var p = parent ?? this;
    assert(p.easyTreeOwner == this);
    node.mountEasyTree(p);
    assert(node.easyTreeOwner == this);
    p.updateEasyTreeNodeChild(null, node);
  }

  /// 将节点从树上移除
  void unmountEasyTreeNode(EasyTreeNode node) {
    assert(node.easyTreeOwner == this);
    node.easyTreeParent?.updateEasyTreeNodeChild(node, null);
    node.unmountEasyTree();
  }
}

class EasyTreeRelationOwner extends EasyTreeOwner with EasyTreeSequenceMixin, EasyTreeRelation, EasyTreeSortRelation, EasyTreeOwnerRelation {}
