## The_Game

import tables
import sequtils
import graphs
import selectors
import stats

const
  fail_filename = "fails.csv"
  score_filename = "scores.csv"
  avg_edge_by_score_filename = "edge_by_score.csv"

proc init*(graph: var Graph; seed: proc(nodes: openarray[int]): seq[int]) =
  for id in toSeq(graph.keys).seed():
    fail(graph[id])

proc run*(graph: var Graph; spread: proc(nodes: openarray[int]): seq[int]) =
  assert(graph.len() > 0) # Assert graph is not empty
  var fails: seq[int]
  for node in graph.mvalues:
    if node.is_fail():
      for id in node.get_adj().spread():
        fails.add(id)
    pass(node)
  for id in fails:
    fail(graph[id])

proc run*(graph: var Graph; num_trials: int; seed, spread: proc(nodes: openarray[int]): seq[int]) =
  echo "\pParameters:"
  echo "  Total Nodes: ", graph.node_count()
  echo "  Total Edges: ", graph.edge_count()
  echo "  Iterations: ", num_trials
  echo "  Number of failures will be stored in ", fail_filename
  echo "  Score distributions will be stored in ", score_filename
  echo "  Average edges by score will be stored in ", avg_edge_by_score_filename
  echo "  (All csv's are indexed by iteration)"
  echo "\pRunning simulation..."
  
  let fail_file = open(fail_filename, fmWrite); defer: fail_file.close()
  let score_file = open(score_filename, fmWrite); defer: score_file.close()
  let avg_edge_by_score_file = open(avg_edge_by_score_filename, fmWrite); defer: avg_edge_by_score_file.close()

  fail_file.writeLine("iteration, number_of_failures")

  score_file.write("iteration")
  avg_edge_by_score_file.write("iteration")
  for i in 0..<num_trials:
    score_file.write(", ", i)
    avg_edge_by_score_file.write(", ", i)
  score_file.write("\p")
  avg_edge_by_score_file.write("\p")

  for i in 1..num_trials:
    if i == 1: graph.init(seed)
    else: graph.run(spread)

    fail_file.writeLine(i, ", ", graph.fail_count())

    score_file.write(i)
    avg_edge_by_score_file.write(i)

    let scores = graph.score_counts()
    let edges = graph.avg_edges_by_score()
    for j in 0..<num_trials:
      if scores.hasKey(j):
        score_file.write(", ", scores[j])
      else:
        score_file.write(", ", 0)
      
      if edges.hasKey(j):
        avg_edge_by_score_file.write(", ", edges[j])
      else:
        avg_edge_by_score_file.write(", ", 0)
    score_file.write("\p")
    avg_edge_by_score_file.write("\p")
  echo "Done!"

var graph = load("networks\\facebook_combined.txt")
graph.run(100, random(1), percent(0.1))