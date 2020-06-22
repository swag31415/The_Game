## The_Game

import tables
import sequtils
import graphs
import selectors

proc init(graph: var Graph; seed: proc(nodes: openarray[int]): seq[int]) =
  for id in toSeq(graph.keys).seed():
    fail(graph[id])

proc run(graph: var Graph; spread: proc(nodes: openarray[int]): seq[int]) =
  assert(graph.len() > 0) # Assert graph is not empty
  for node in graph.mvalues:
    if node.is_fail():
      for id in node.get_adj().spread():
        fail(graph[id])
    pass(node)