#lang racket
(require "match-list.rkt")
(define (append l1 l2)
  (match-list l1
    [() l2]
    [(head rest) (cons head (append rest l2))]))

(module+ test
  (require rackunit)
  (check-equal? (append '(1 2) '(3 4))
                '(1 2 3 4)))
