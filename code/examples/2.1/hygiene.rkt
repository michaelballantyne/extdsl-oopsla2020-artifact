#lang racket/base

(require "figure-2/match-list.rkt")

(define (f l)
  (let ([v #t] [match-list-error #f])
    (match-list l [() match-list-error] [(first rest) v])))


(module+ test
  (require rackunit)
  (check-equal? (f '()) #f)
  (check-equal? (f (list 1 2 3)) #t))
