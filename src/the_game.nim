## The_Game

import tables
import sequtils
import graphs
import selectors
import stats
import os
import strformat
import strutils

const
  fail_filename = "fails.csv"
  score_filename = "scores.csv"
  avg_edge_by_score_filename = "edge_by_score.csv"

proc `++`(x: var int): int =
  x = x + 1
  return x

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

when isMainModule:
  if paramCount() == 0:
    echo &"""
The Game: A model of how the game is spread
By swag31415 @ https://github.com/swag31415

Usage: {getAppFilename().extractFilename()} Network_txt_file [is_directed] seeding_algorithm [opts] spreading_algorithm [opts] iterations

Ex: {getAppFilename().extractFilename()} datafile.txt true random 1 random 2 1000
   
    Would pick one random node from the directed network in
    datafile.txt and for 1000 iterations run a simulation of
    The Game where every loser tells two random other nodes
    about the game.

Available algorithms:

  first                   Just grabs the first node
  random     [number]     Gets a random `number` nodes
  percent    [percent]    Gets a random `percent` of nodes
                          `percent` is just a number between 0 and 1
                          Ex: 0.625
Text file format:

  The text file is a collection of edges. Each line contains
  one edge which is defined as two integers (the nodes) seperated
  by a space. For a directed network the edge goes from the
  first node to the second.
  Ex:              would be:
    1 ------- 2             1 2
    |         |             3 4
    |         |             2 4
    3 ------- 4             1 3

  And a directed   would be:
  network:                  2 1
    1 <-----> 2             1 2
    |         |             4 3
    V         V             1 3
    3 <------ 4             2 4
"""
  else:
    var
      net_file: string
      is_directed: bool
      seed, spread: proc(nodes: openarray[int]): seq[int]
      iterations: int
      p = 0
    net_file = paramStr(++p)
    try: is_directed = paramStr(++p).parseBool()
    except:
      echo "Invalid entry for is_bool. Run with no command line arguments for help"
      quit(QuitFailure)
    try:
      case paramStr(++p).toLower():
        of "first": seed = first()
        of "random": seed = random(paramStr(++p).parseInt())
        of "percent": seed = percent(paramStr(++p).parseFloat())
        else: raise newException(OSError, "")
    except:
      echo "Invalid entry for seeding_algrithm or opt. Run with no command line arguments for help"
      quit(QuitFailure)
    try:
      case paramStr(++p).toLower():
        of "first": spread = first()
        of "random": spread = random(paramStr(++p).parseInt())
        of "percent": spread = percent(paramStr(++p).parseFloat())
        else: raise newException(OSError, "")
    except:
      echo "Invalid entry for spreading_algrithm or opt. Run with no command line arguments for help"
      quit(QuitFailure)
    try: iterations = paramStr(++p).parseInt()
    except:
      echo "Invalid entry for number of iterations. Run with no command line arguments for help"
      quit(QuitFailure)

    var graf = load(net_file, is_directed)
    graf.run(iterations, seed, spread)