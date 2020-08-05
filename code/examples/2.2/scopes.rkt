#lang racket

(require macro-debugger/expand
         debug-scopes
         racket/runtime-path)

(define-runtime-path p "../2.1/figure-2/match-list.rkt")
(namespace-require 'racket/base)
(namespace-require `(file ,(path->string p)))

(displayln
  (+scopes
    (expand-only
      '(let ([v #t] [match-list-error #f])
         (match-list l [() match-list-error] [(first rest) v]))
      (list (eval '#'match-list)))))

(print-full-scopes)
