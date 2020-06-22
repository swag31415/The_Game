## Stats

import tables
import sequtils
import graphs

proc node_count*(graph: Graph): int =
  return graph.len()

proc edge_count*(graph: Graph): int =
  for node in graph.values:
    result.inc(node.get_adj().len())

proc fail_count*(graph: Graph): int =
  for node in graph.values:
    if node.is_fail: result.inc()

proc score_counts*(graph: Graph): CountTable[int] =
  toSeq(graph.values).map(get_score).toCountTable()

proc avg_edges_by_score*(graph: Graph): Table[int, float] =
  for node in graph.values:
    let score = node.get_score()
    let edges = node.get_adj().len()
    if result.hasKey(score):
      result[score] += float(edges)
    else:
      result[score] = float(edges)
  for (score, count) in graph.score_counts().pairs:
    result[score] /= float(count)