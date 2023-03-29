part of "../easy_tree.dart";

mixin EasyTreeElementMixin on EasyTreeElementNode, Element {
  @override
  Element get easyTreeHostElement => this;

  /// 这个是为了获得super.mount之后build之前执行一些代码
  bool _firstBuild = true;

  /// 挂载自己
  void _mountSelf() {
    // 如果没有指定owner，那么就用公共的owner
    var owner = easyTreeOwner ?? EasyTreeOwner.sharedOwner;
    // 离这个节点最近最近的父级EasyTreeElement
    EasyTreeNode? appendToNode = easyTreeParentElementNode() ?? owner;
    // 挂载节点
    easyTreeOwner?.mountEasyTreeNode(appendToNode, this);
  }

  /// 卸载自己
  void _unmountSelf() {
    // 卸载节点
    easyTreeOwner?.unmountEasyTreeNode(this);
  }

  @override
  @mustCallSuper
  void rebuild({bool force = false}) {
    if (_firstBuild) {
      _firstBuild = false;
      _mountSelf();
    }
    super.rebuild();
  }

  @override
  @mustCallSuper
  void activate() {
    super.activate();
    _mountSelf();
  }

  @override
  @mustCallSuper
  void deactivate() {
    super.deactivate();
    // 卸载节点
    _unmountSelf();
  }
}
