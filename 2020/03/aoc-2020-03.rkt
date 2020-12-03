#lang racket

;--- Day 3: Toboggan Trajectory ---

;With the toboggan login problems resolved, you set off toward the airport. While travel by toboggan might be easy, it's certainly not safe: there's very minimal steering and the area is covered in trees. You'll need to see which angles will take you near the fewest trees.
;
;Due to the local geology, trees in this area only grow on exact integer coordinates in a grid. You make a map (your puzzle input) of the open squares (.) and trees (#) you can see. For example:
;
;..##.......
;#...#...#..
;.#....#..#.
;..#.#...#.#
;.#...##..#.
;..#.##.....
;.#.#.#....#
;.#........#
;#.##...#...
;#...##....#
;.#..#...#.#
;These aren't the only trees, though; due to something you read about once involving arboreal genetics and biome stability, the same pattern repeats to the right many times:
;
;..##.........##.........##.........##.........##.........##.......  --->
;#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
;.#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
;..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
;.#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
;..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
;.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
;.#........#.#........#.#........#.#........#.#........#.#........#
;#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
;#...##....##...##....##...##....##...##....##...##....##...##....#
;.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->
;You start on the open square (.) in the top-left corner and need to reach the bottom (below the bottom-most row on your map).
;
;The toboggan can only follow a few specific slopes (you opted for a cheaper model that prefers rational numbers); start by counting all the trees you would encounter for the slope right 3, down 1:
;
;From your starting position at the top-left, check the position that is right 3 and down 1. Then, check the position that is right 3 and down 1 from there, and so on until you go past the bottom of the map.
;
;The locations you'd check in the above example are marked here with O where there was an open square and X where there was a tree:
;
;..##.........##.........##.........##.........##.........##.......  --->
;#..O#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
;.#....X..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
;..#.#...#O#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
;.#...##..#..X...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
;..#.##.......#.X#.......#.##.......#.##.......#.##.......#.##.....  --->
;.#.#.#....#.#.#.#.O..#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
;.#........#.#........X.#........#.#........#.#........#.#........#
;#.##...#...#.##...#...#.X#...#...#.##...#...#.##...#...#.##...#...
;#...##....##...##....##...#X....##...##....##...##....##...##....#
;.#..#...#.#.#..#...#.#.#..#...X.#.#..#...#.#.#..#...#.#.#..#...#.#  --->
;In this example, traversing the map using this slope would cause you to encounter 7 trees.
;
;Starting at the top-left corner of your map and following a slope of right 3 and down 1, how many trees would you encounter?

(struct map-grid (width height map)
  #:transparent)

(define map
  (call-with-input-file "input.txt"
    (lambda (in)
      (define map
        (for/vector ([line (in-lines in)])
          (for/vector ([char (in-string line)])
            (case char
              [(#\.) #f]
              [(#\#) #t]))))
      (map-grid (vector-length (vector-ref map 0))
                (vector-length map)
                map))))

(define (step map x y col-step row-step)
  (define new-x (remainder (+ x col-step) (map-grid-width map)))
  (define new-y (remainder (+ y row-step) (map-grid-height map)))
  (define row (vector-ref (map-grid-map map) new-y))
  (define col (vector-ref row new-x))
  (values new-x new-y col))

(define (check map col-step row-step)
  (let loop ([x 0]
             [y 0]
             [trees 0])
    (cond
      [(= y (sub1 (map-grid-height map))) trees]
      [else
       (define-values (new-x new-y tree?)
         (step map x y col-step row-step))
       (loop new-x new-y (if tree? (add1 trees) trees))])))

(check map 3 1)
; 259

;Time to check the rest of the slopes - you need to minimize the probability of a sudden arboreal stop, after all.
;
;Determine the number of trees you would encounter if, for each of the following slopes, you start at the top-left corner and traverse the map all the way to the bottom:
;
;Right 1, down 1.
;Right 3, down 1. (This is the slope you already checked.)
;Right 5, down 1.
;Right 7, down 1.
;Right 1, down 2.
;In the above example, these slopes would find 2, 7, 3, 4, and 2 tree(s) respectively; multiplied together, these produce the answer 336.
;
;What do you get if you multiply together the number of trees encountered on each of the listed slopes?

(* (check map 1 1)
   (check map 3 1)
   (check map 5 1)
   (check map 7 1)
   (check map 1 2))
; 2224913600
