## Graphs

import strutils
import sequtils
import tables

type
  Node* = object
    fail: bool # Used as a marker for nodes that have *just* failed and have yet to report it
    score: int
    adj: seq[int] # The id's of nodes they "know"
  Graph* = Table[int, Node] # Just a lookup table for all the nodes

# the node "Fails" the round by setting its score to zero and fail to true
proc fail*(node: var Node) = 
  node.score = 0
  node.fail = true

# the node "Passes" the round by incresing its score and fail to false
proc pass*(node: var Node) =
  node.fail = false
  node.score.inc()

proc get_adj*(node: Node): seq[int] =
  return node.adj

proc get_score*(node: Node): int =
  return node.score

proc is_fail*(node: Node): bool =
  return node.fail

proc add_pair(graph: var Graph; a, b: int) =
  if graph.hasKey(a):
    graph[a].adj.add(b)
  else:
    graph[a] = Node(fail: false, score: 0, adj: @[b])

proc load*(filename: string; directed = false): Graph =
  for line in lines(filename):
    let nums = splitWhitespace(line).map(parseint)
    assert(nums.len() == 2)
    result.add_pair(nums[0], nums[1])
    if not directed: result.add_pair(nums[1], nums[0])

proc `$`*(graph: Graph): string =
  for (id, node) in graph.pairs:
    result.add("$# has a score of $# and knows $# others\p" % [$id, $node.score, $node.adj.len])