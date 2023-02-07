part of "easy_tree.dart";

/// 用于在树中获取节点的关键
class EasyTreeNodeKey<T> {
  static EasyTreeNodeKey anyKey = const EasyTreeNodeKey<Type>(EasyTreeNodeKey);
  const EasyTreeNodeKey(this.key);
  final T key;
  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) {
    return (other as EasyTreeNodeKey<T>?)?.key == key;
  }
}
