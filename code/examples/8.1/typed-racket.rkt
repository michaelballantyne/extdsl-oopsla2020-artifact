#lang typed/racket

(define-type Posn
    (case->
     [(List 'get-x) -> Number]
     [(List 'get-y) -> Number]
     [(List 'distance Posn) -> Number]))

(: new-posn (-> Number Number Posn))
(define (new-posn x y)
    (lambda (msg)
      (match msg
        [`(get-x) x]
        [`(get-y) y]
        [`(distance ,other)
         (sqrt (+ (sqr (- (other '(get-x)) x))
                  (sqr (- (other '(get-y)) y))))])))

(module+ test
  (require typed/rackunit)
  (check-equal?
    ((new-posn 1 3) (list 'distance (new-posn 4 5)))
    3.605551275463989))
