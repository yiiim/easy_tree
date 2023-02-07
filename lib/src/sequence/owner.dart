part of "../easy_tree.dart";

/// 序列树所有者
///
/// 在简单树中，子节点的顺序是不可靠的，在需要子节点的正确顺序时，需要构造一个序列树来获取
/// 序列树所有者由简单树的节点构造，序列树由该节点所有的子节点以及这些子节点分叉节点构成
/// 序列树所有者是序列树的根节点
class EasySequenceTreeOwner extends EasySequenceTreeElementNode {
  /// 需要使用一个树节点创建owner，将会构建维护该节点的序列树
  EasySequenceTreeOwner(super.easyTreeNode) {
    // 挂载自己
    mountEasySequenceTreeNode(null);
  }

  /// 这里保存在所有节点的排序值
  final Map<EasyTreeNode, int> _sortValueMaps = {};

  /// 未build的简单树子级
  final List<EasyTreeNode> _easyTreeNotBuildChildren = [];

  /// 是否需要更新节点的排序值，实际上每帧都应该更新排序值
  bool _isNeedUpdateSortValue = true;

  /// 获取节点的排序值
  ///
  /// 节点必须在这颗树中
  int nodeSortValue(EasyTreeNode a) {
    rebuildIfNeed();
    var sequenceNode = easyTreeNodesSequenceNode(a);
    assert(sequenceNode != null, "节点未在树中");
    updateNodeSortValueIfNeed();
    return _sortValueMaps[sequenceNode?.easyTreeNode] ?? 0;
  }

  /// 排序两个节点
  int sortNode(EasyTreeNode a, EasyTreeNode b) {
    return nodeSortValue(a).compareTo(nodeSortValue(b));
  }

  List<EasyTreeNode> deepSortNodes(List<EasyTreeNode> deepNodes) {
    var sortValueMaps = <EasyTreeNode, int>{};
    int index = 0;
    Set<EasyTreeNode> deepNodeDeepParents = {};
    Map<EasyTreeNode, Set<EasyTreeNode>> deepNodeParents = {};
    for (var element in deepNodes) {
      EasyTreeNode? p = element;
      while (p?.easyTreeParent != null) {
        deepNodeParents[p!.easyTreeParent!] ??= {};
        deepNodeParents[p.easyTreeParent!]!.add(p);
        deepNodeDeepParents.add(p.easyTreeParent!);
        if (p.easyTreeParent == easyTreeNode) break;
        p = p.easyTreeParent;
      }
    }
    void updateDeepNodeSortValue(EasyTreeNode node) {
      if (deepNodes.contains(node)) {
        sortValueMaps[node] = index++;
      }
      if (deepNodeDeepParents.contains(node)) {
        if (node is EasyTreeSequenceMixin && (deepNodeParents[node]?.length ?? 0) > 1) {
          node.easySequenceTreeOwner.rebuildIfNeed();
          node.easySequenceTreeOwner.easySequenceTreeNodeChildren.sort(_sort);
          // 递归子级
          node.easySequenceTreeOwner.visitEasySequenceTreeChildNode(
            (element) {
              if (element is EasySequenceTreeElementNode) {
                updateDeepNodeSortValue(element.easyTreeNode);
              }
              // 叶子级继续排序
              element.easySequenceTreeNodeChildren.sort(_sort);
              return true;
            },
          );
        } else {
          node.visitEasyTreeChildNode(
            (element) {
              updateDeepNodeSortValue(element);
              return false;
            },
          );
        }
      }
    }

    updateDeepNodeSortValue(easyTreeNode);
    return deepNodes.sorted((a, b) => (sortValueMaps[a] ?? 0).compareTo(sortValueMaps[b] ?? 0));
  }

  /// 更新节点的排序值
  void updateNodeSortValueIfNeed() {
    if (_isNeedUpdateSortValue == false) return;
    _sortValueMaps.clear();
    // 子级排序
    easySequenceTreeNodeChildren.sort(_sort);
    int index = 0;
    // 递归子级
    visitEasySequenceTreeChildNode(
      (element) {
        if (element is EasySequenceTreeElementNode) {
          _sortValueMaps[element.easyTreeNode] = index++;
        }
        // 叶子级继续排序
        element.easySequenceTreeNodeChildren.sort(_sort);
        return true;
      },
    );
    _isNeedUpdateSortValue = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _isNeedUpdateSortValue = true;
    });
  }

  int _sort(EasySequenceTreeNode a, EasySequenceTreeNode b) {
    if (a.topElement?.slot is! IndexedSlot) return -1;
    if (b.topElement?.slot is! IndexedSlot) return -2;
    return (a.topElement?.slot as IndexedSlot).index.compareTo((b.topElement?.slot as IndexedSlot).index);
  }

  /// 添加一个简单树节点到序列树
  void addEasyTreeChildNode(EasyTreeNode node) {
    _easyTreeNotBuildChildren.add(node);
  }

  void removeEasyTreeChildNode(EasyTreeNode node) {
    _easyTreeNotBuildChildren.remove(node);
  }

  /// 将树中的[EasySequenceTreeChildrenNode]对应到[Element]
  final Map<Element, EasySequenceTreeChildrenNode> _easyTreeElementsSequenceChildrenNode = {};

  /// 将树中的[EasySequenceTreeElementNode]对应到[EasyTreeNode]
  final Map<EasyTreeNode, EasySequenceTreeElementNode> _easyTreeNodesSequenceNode = {};

  /// 获取此树中[EasyTreeNode]对应的[EasySequenceTreeElementNode]
  EasySequenceTreeElementNode? easyTreeNodesSequenceNode(EasyTreeNode node) {
    return _easyTreeNodesSequenceNode[node];
  }

  /// 更新此树中[EasyTreeNode]对应的[EasySequenceTreeElementNode]
  void updateEasyTreeNodesSequenceNode(EasyTreeNode node, EasySequenceTreeElementNode? elementKeyNode) {
    if (elementKeyNode == null) {
      _easyTreeNodesSequenceNode.remove(node);
    } else {
      _easyTreeNodesSequenceNode[node] = elementKeyNode;
    }
  }

  /// 获取此树中[Element]对应的[EasySequenceTreeChildrenNode]
  EasySequenceTreeChildrenNode? easyTreeElementsSequenceChildrenNode(Element element) {
    return _easyTreeElementsSequenceChildrenNode[element];
  }

  /// 更新此树中[Element]对应的[EasySequenceTreeChildrenNode]
  void updateEasyTreeElementsSequenceChildrenNode(Element element, EasySequenceTreeChildrenNode? childrenKeyNode) {
    if (childrenKeyNode == null) {
      _easyTreeElementsSequenceChildrenNode.remove(element);
    } else {
      _easyTreeElementsSequenceChildrenNode[element] = childrenKeyNode;
    }
  }

  @override
  void rebuildIfNeed() {
    if (_easyTreeNotBuildChildren.isNotEmpty) {
      _easySequenceTreeNotBuildChildren.addAll(_easyTreeNotBuildChildren.map((e) => EasySequenceTreeElementNode(e)));
    }
    super.rebuildIfNeed();
    assert(() {
      var count = 0;
      void itemCount(EasySequenceTreeNode node) {
        if (node is EasySequenceTreeElementNode && node != this) count++;
        node.visitEasySequenceTreeChildNode((element) {
          itemCount(element);
          return false;
        });
      }

      itemCount(this);
      if (count != easyTreeNode.easyTreeChildren.length) throw "排序的元素数量错误";
      return true;
    }());
    _easyTreeNotBuildChildren.clear();
  }

  @override
  EasySequenceTreeOwner? get owner => this;
}
