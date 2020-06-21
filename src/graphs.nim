## Graphs

import tables

type
  Node* = object
    fail: bool # Used as a marker for nodes that have *just* failed and have yet to report it
    score: int
    adj: seq[int] # The id's of nodes they "know"
  Graph* = Table[int, Node] # Just a lookup table for all the nodes