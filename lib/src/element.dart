part of "easy_tree.dart";

/// 用来寻找上级Element的InheritedWidget
class _EasyTreeInheritedWidget extends InheritedWidget {
  const _EasyTreeInheritedWidget({required this.easyTreeElement, required Widget child, Key? key}) : super(child: child, key: key);

  /// 当前级的[EasyTreeElement]
  final EasyTreeElement easyTreeElement;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

abstract class _EasyTreeElement extends ComponentElement implements EasyTreeElementNode {
  _EasyTreeElement(super.widget);
}

abstract class EasyTreeElement extends _EasyTreeElement with EasyTreeNodeMixin, EasyTreeElementMixin {
  EasyTreeElement(super.widget, {EasyTreeOwner? easyTreeOwner}) : easyTreeOwner = easyTreeOwner ?? EasyTreeOwner.sharedOwner;

  @override
  final EasyTreeOwner? easyTreeOwner;

  @override
  Widget build() {
    return _EasyTreeInheritedWidget(easyTreeElement: this, child: buildChild());
  }

  @override
  void update(covariant Widget newWidget) {
    super.update(newWidget);
    markNeedsBuild();
    rebuild();
  }

  Widget buildChild();

  @override
  EasyTreeElementNode? easyTreeParentElementNode() => getEasyTreeElementFromContext(this, easyTreeOwner: easyTreeOwner);

  @override
  List<EasyTreeNodeKey> get keys => [EasyTreeNodeKey.anyKey];

  static EasyTreeElementNode? getEasyTreeElementFromContext(BuildContext context, {EasyTreeOwner? easyTreeOwner}) {
    EasyTreeElement? node = (context.getElementForInheritedWidgetOfExactType<_EasyTreeInheritedWidget>()?.widget as _EasyTreeInheritedWidget?)?.easyTreeElement;
    while (node != null && node.easyTreeOwner != easyTreeOwner) {
      node = (node.getElementForInheritedWidgetOfExactType<_EasyTreeInheritedWidget>()?.widget as _EasyTreeInheritedWidget?)?.easyTreeElement;
    }
    return node;
  }
}

abstract class EasyTreeRelationElement extends EasyTreeElement with EasyTreeRelation, EasyTreeSequenceMixin, EasyTreeSortRelation {
  EasyTreeRelationElement(super.widget, {super.easyTreeOwner});
}
