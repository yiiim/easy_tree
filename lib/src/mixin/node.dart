part of "../easy_tree.dart";

mixin EasyTreeNodeMixin on EasyTreeNode {
  /// 父级节点
  EasyTreeNode? _easyTreeParent;
  @override
  EasyTreeNode? get easyTreeParent => _easyTreeParent;

  /// owner
  EasyTreeOwner? _easyTreeOwner;
  @override
  EasyTreeOwner? get easyTreeOwner => _easyTreeOwner;

  /// 是否已经挂载
  bool _mounted = false;
  bool get mounted => _mounted;

  int _easyTreeDepth = 0;
  @override
  int get easyTreeDepth => _easyTreeDepth;

  /// 子级节点
  final List<EasyTreeNode> _easyTreeChildren = [];

  @override
  Iterable<EasyTreeNode> get easyTreeChildren => _easyTreeChildren;

  @override
  @mustCallSuper
  void unmountEasyTree() {
    assert(mounted);
    _mounted = false;
  }

  @override
  @mustCallSuper
  void mountEasyTree(EasyTreeNode? parent) {
    assert(_mounted == false);
    _easyTreeOwner = parent?.easyTreeOwner;
    _mounted = true;
    _easyTreeParent = parent;
    _easyTreeDepth = (parent?.easyTreeDepth ?? 0) + 1;
  }

  @override
  @mustCallSuper
  void updateEasyTreeNodeChild(EasyTreeNode? oldNode, EasyTreeNode? newNode) {
    assert(oldNode != null || newNode != null);
    if (oldNode != null) {
      assert(oldNode.easyTreeOwner == easyTreeOwner);
      _easyTreeChildren.remove(oldNode);
    }
    if (newNode != null) {
      assert(newNode.easyTreeOwner == easyTreeOwner);
      _easyTreeChildren.add(newNode);
    }
  }

  @override
  void visitEasyTreeChildNode(bool Function(EasyTreeNode element) visitor) {
    for (var element in _easyTreeChildren) {
      if (visitor(element)) {
        element.visitEasyTreeChildNode(visitor);
      }
    }
  }
}
