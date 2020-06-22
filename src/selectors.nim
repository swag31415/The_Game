## To select a subset of a given list of integers

import sequtils
import random

randomize()

type
  Selector = proc(a: openarray[int]): seq[int]

proc first*(): Selector =
  return proc(a: openarray[int]): seq[int] =
    @[a[0]] # Return the first one

proc random*(count: int): Selector =
  return proc(a: openarray[int]): seq[int] =
    result = @a # Set result to equal the given sequence
    shuffle(result) # Shuffle the result
    result.delete(count, result.high) # Keep only the first `count` numbers

proc percent*(prob: range[0.0..1.0]): Selector =
  return proc(a: openarray[int]): seq[int] =
    a.filter(proc(x: int): bool =
      rand(0.0..1.0) < prob
    )