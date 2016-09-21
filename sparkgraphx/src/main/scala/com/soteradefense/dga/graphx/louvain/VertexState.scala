package com.soteradefense.dga.graphx.louvain

class VertexState extends Serializable {
  // 所属社区ID
  var community = -1L
  // 社区的度数
  var communitySigmaTot = 0L
  // 节点总度数
  var internalWeight = 0L
  // 节点出度
  var nodeWeight = 0L
  var changed = false

  override def toString(): String = {
    s"{community: $community, communitySigmaTot: $communitySigmaTot, internalWeight: $internalWeight, nodeWeight: $nodeWeight"
  }
}
