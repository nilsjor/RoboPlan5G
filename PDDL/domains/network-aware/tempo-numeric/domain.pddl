(define (domain floor-grid)
(:requirements
 :strips
 :equality
 :typing
 :negative-preconditions
 :durative-actions
 :fluents
)
(:types
 grid - location
 radio-dot - radio
 robot crate - object
)
(:predicates
 (at-loc ?o - object ?x - location)
 (connected ?x ?y - location)
 (clear ?x - location)
 (carrying ?robot - robot ?c - crate)
 (free ?robot - robot)
)
(:functions
 (prbs-free ?radio - radio) - number
 (prbs-assigned ?radio - radio ?robot - robot ) - number
 (prbs-required ?radio - radio ?loc - location) - number
 (prbs-max) - number
 (total-cost) - number
)
(:durative-action pick
 :parameters (?r - robot ?x - location ?c - crate)
 :duration (= ?duration 0.1)
 :condition (and
  (at start (at-loc ?r ?x))
  (at start (at-loc ?c ?x))
  (at start (free ?r)))
 :effect (and
  (at start (not (at-loc ?c ?x)))
  (at end (carrying ?r ?c))
  (at start (not (free ?r)))
 )
)
(:durative-action drop
 :parameters (?r - robot ?x - location ?c - crate)
 :duration (= ?duration 0.1)
 :condition (and
  (over all (at-loc ?r ?x))
  (at start (carrying ?r ?c))
 )
 :effect (and
  (at start (not (carrying ?r ?c)))
  (at end (at-loc ?c ?x))
  (at end (free ?r))
 )
)
(:durative-action wait
 :parameters (?r - robot ?x - location)
 :duration (= ?duration 1)
 :condition (over all (at-loc ?r ?x))
 :effect (at end (increase (total-cost) 1))
)
(:durative-action move
 :parameters (?robot - robot ?from ?to - location ?radio - radio)
 :duration (= ?duration 1)
 :condition (and
  (at start (at-loc ?robot ?from))
  (over all (connected ?to ?from))
  (at end (clear ?to))
  (at start (>=
    (prbs-assigned ?radio ?robot)
    (prbs-required ?radio ?to)))
  (at start (>=
    (prbs-assigned ?radio ?robot)
    (prbs-required ?radio ?from)))
 )
 :effect (and
  (at end (at-loc ?robot ?to))
  (at start (not (at-loc ?robot ?from)))
  (at end (clear ?from))
  (at start (not (clear ?to)))
  (at end (increase
    (total-cost)
    (prbs-assigned ?radio ?robot)))
  (at end (increase
    (prbs-free ?radio)
    (prbs-assigned ?radio ?robot)))
  (at end (assign (prbs-assigned ?radio ?robot) 0))
 )
)
(:durative-action assign-prb
 :parameters (?robot - robot ?radio - radio)
 :duration (= ?duration 0.001)
 :condition (and
  (at start (< (prbs-assigned ?radio ?robot) (prbs-max)))
  (at start (> (prbs-free ?radio) 0))
 )
 :effect (and
  (at start (decrease (prbs-free ?radio) 1))
  (at start (increase (prbs-assigned ?radio ?robot) 1))
 )
)
)