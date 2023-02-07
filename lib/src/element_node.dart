part of "easy_tree.dart";

abstract class EasyTreeElementNode extends EasyTreeNode {
  /// 最近的上一级节点
  EasyTreeElementNode? easyTreeParentElementNode();
}
