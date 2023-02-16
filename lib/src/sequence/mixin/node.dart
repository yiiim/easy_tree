part of "../../easy_tree.dart";

class _EasyTreeNodeElementTreeEntity {
  _EasyTreeNodeElementTreeEntity(this.node, this.element, this.topChildElement, {this.noBuild = true, this.children = const []});
  EasySequenceTreeNode node;
  Element element;
  Element topChildElement;
  bool noBuild;

  List<_EasyTreeNodeElementTreeEntity> children;
}

/// EasyTree的关键节点
///
/// 关键节点有可能不是实际的EasyTreeNode节点而是多个EasyTreeNode公共父节点
mixin EasySequenceTreeNodeMixin on EasySequenceTreeNode {
  /// owner
  EasySequenceTreeOwner? _owner;
  @override
  EasySequenceTreeOwner? get owner => _owner;

  /// 在
  Element? _topElement;
  @override
  Element? get topElement => _topElement;

  /// 父级节点
  EasySequenceTreeNode? _parent;
  @override
  EasySequenceTreeNode? get parent => _parent;

  /// 是否已经挂载
  bool _mounted = false;
  bool get mounted => _mounted;
  bool _dispose = false;

  /// 子级节点
  final List<EasySequenceTreeNode> _easySequenceTreeNodeChildren = [];

  @override
  List<EasySequenceTreeNode> get easySequenceTreeNodeChildren => _easySequenceTreeNodeChildren;

  /// 未build的子级
  // ignore: prefer_final_fields
  List<EasySequenceTreeNode> _easySequenceTreeNotBuildChildren = [];

  /// 未build的子级
  final List<_EasyTreeNodeElementTreeEntity> _easySequenceTreeNotBuildEntityChildren = [];

  @override
  @mustCallSuper
  void rebuildIfNeed() {
    assert(mounted);
    if (_easySequenceTreeNotBuildChildren.isNotEmpty || _easySequenceTreeNotBuildEntityChildren.isNotEmpty) {
      var notBuildChildren = List.of(_easySequenceTreeNotBuildChildren);
      var notBuildChildrenEntity = List.of(_easySequenceTreeNotBuildEntityChildren);
      _easySequenceTreeNotBuildChildren.clear();
      _easySequenceTreeNotBuildEntityChildren.clear();
      // 最大深度
      int currentDepth = -1;
      // 使用深度作为key，创建一个字典
      Map<int, List<_EasyTreeNodeElementTreeEntity>> nodeDepthMaps = {};
      // 把未build的子级加入
      for (var element in notBuildChildren) {
        var entity = _EasyTreeNodeElementTreeEntity(element, element.element, element.element, noBuild: true);
        nodeDepthMaps[element.element.depth] ??= [];
        nodeDepthMaps[element.element.depth]!.add(entity);
        if (element.element.depth > currentDepth) {
          currentDepth = element.element.depth;
        }
      }
      // 把未build的子级加入
      for (var element in notBuildChildrenEntity) {
        nodeDepthMaps[element.node.element.depth] ??= [];
        nodeDepthMaps[element.node.element.depth]!.add(element);
        if (element.node.element.depth > currentDepth) {
          currentDepth = element.node.element.depth;
        }
      }
      // 把子级加入
      for (var element in easySequenceTreeNodeChildren) {
        var entity = _EasyTreeNodeElementTreeEntity(element, element.element, element.element, noBuild: false);
        nodeDepthMaps[element.element.depth] ??= [];
        nodeDepthMaps[element.element.depth]!.add(entity);
        if (element.element.depth > currentDepth) {
          currentDepth = element.element.depth;
        }
      }
      assert(
        () {
          var allValues = nodeDepthMaps.values.expand((element) => element);
          return allValues.length == allValues.map((e) => e.element).toSet().length;
        }(),
      );
      // 最大深度的子级
      List<_EasyTreeNodeElementTreeEntity> pNodes = [...(nodeDepthMaps.remove(currentDepth) ?? [])];
      // 从最大深度的子级开始往上爬
      do {
        // 查找相同父级的节点
        Map<Element, List<_EasyTreeNodeElementTreeEntity>> maps = {};
        for (var item in List.of(pNodes)) {
          // 向上一级
          item.element.visitAncestorElements(
            (e) {
              if (e.depth == currentDepth - 1) {
                item.topChildElement = item.element;
                item.element = e;
              }
              return false;
            },
          );
          // 当爬到当前节点了，那么剩下的节点就是当前节点的子级了，将跳出循环，挂载剩余的节点到当前节点
          if (item.element != element) {
            // 如果父级已经在树中，加入这个节点的子节点
            var childrenNode = owner?.easyTreeElementsSequenceChildrenNode(item.element);
            assert(
              () {
                var result = childrenNode == null || childrenNode == this;
                if (result == false) {
                  visitEasySequenceTreeChildNode((element) {
                    if (result == false) result = (element == childrenNode);
                    return !result;
                  });
                }
                return result;
              }(),
            );
            if (childrenNode != null) {
              if (item.node is EasySequenceTreeChildrenNode) {
                for (var element in item.children) {
                  childrenNode._easySequenceTreeNotBuildEntityChildren.add(_EasyTreeNodeElementTreeEntity(element.node, element.node.element, element.node.element, noBuild: element.noBuild));
                }
              } else {
                childrenNode._easySequenceTreeNotBuildEntityChildren.add(_EasyTreeNodeElementTreeEntity(item.node, item.node.element, item.node.element, noBuild: item.noBuild));
              }
              pNodes.remove(item);
              continue;
            }
            if (maps[item.element] == null) maps[item.element] = [];
            maps[item.element]?.add(item);
          }
        }
        // 找到的相同父级的节点
        var sameSuperElements = maps.values.where((element) => element.length > 1);
        for (var element in sameSuperElements) {
          assert(element.map((e) => e.topChildElement).toSet().length == element.length);
          element.forEach(pNodes.remove);
          assert(element.length > 1);
          // 创建一个新的节点
          var childrenNode = EasySequenceTreeChildrenNode(element.first.element);
          var entity = _EasyTreeNodeElementTreeEntity(
            childrenNode,
            element.first.element,
            element.first.element,
            children: element,
            noBuild: true,
          );
          pNodes.add(entity);
        }
        // 当前深度的元素
        pNodes.addAll(nodeDepthMaps.remove(--currentDepth) ?? []);
      } while (currentDepth > element.depth && ((nodeDepthMaps.length + pNodes.length) > 1));
      // 挂载
      for (var element in pNodes) {
        if (element.noBuild) _mountEntity(element, this);
      }
    }
    visitEasySequenceTreeChildNode(
      (element) {
        element.rebuildIfNeed();
        return false;
      },
    );
    assert(easySequenceTreeNodeChildren.map((e) => e.topElement).toSet().length == easySequenceTreeNodeChildren.length);
  }

  void _mountEntity(_EasyTreeNodeElementTreeEntity entity, EasySequenceTreeNode parent) {
    if (entity.noBuild) {
      entity.node.mountEasySequenceTreeNode(parent, topElement: entity.topChildElement);
      parent.updateEasySequenceTreeNodeChild(null, entity.node);
    } else {
      if (entity.node.parent != parent) {
        entity.node.parent?.updateEasySequenceTreeNodeChild(entity.node, null);
        entity.node.updateEasySequenceTreeNodeParent(parent, topElement: entity.topChildElement);
        parent.updateEasySequenceTreeNodeChild(null, entity.node);
      }
    }
    for (var element in entity.children) {
      _mountEntity(element, entity.node);
    }
    assert(() {
      if (entity.node is EasySequenceTreeChildrenNode) {
        return entity.node.easySequenceTreeNodeChildren.length > 1;
      }
      return true;
    }());
  }

  @override
  @mustCallSuper
  void unmountEasySequenceTreeNode() {
    assert(mounted);
    assert(_dispose == false);
    _mounted = false;
    _dispose = true;
  }

  @override
  @mustCallSuper
  void mountEasySequenceTreeNode(EasySequenceTreeNode? parent, {Element? topElement}) {
    assert(_mounted == false);
    assert(_dispose == false);
    _topElement = topElement;
    _mounted = true;
    _owner = parent?.owner;
    _parent = parent;
  }

  @override
  @mustCallSuper
  void updateEasySequenceTreeNodeParent(EasySequenceTreeNode? parent, {Element? topElement}) {
    assert(mounted);
    _topElement = topElement;
    _parent = parent;
  }

  @override
  void updateEasySequenceTreeNodeChild(EasySequenceTreeNode? oldNode, EasySequenceTreeNode? newNode) {
    assert(oldNode != null || newNode != null);
    assert(oldNode == null || easySequenceTreeNodeChildren.contains(oldNode));
    if (oldNode != null) {
      easySequenceTreeNodeChildren.remove(oldNode);
    }
    if (newNode != null) {
      easySequenceTreeNodeChildren.add(newNode);
    }
  }

  @override
  void visitEasySequenceTreeChildNode(bool Function(EasySequenceTreeNode element) visitor) {
    for (var element in easySequenceTreeNodeChildren) {
      if (visitor(element)) {
        element.visitEasySequenceTreeChildNode(visitor);
      }
    }
  }
}
