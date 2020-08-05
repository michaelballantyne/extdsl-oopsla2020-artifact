#lang racket
(require (except-in racket-peg-ee #%peg-datum)
         racket-peg-ee/simple-tokens
         racket-peg-ee/string-token)

(struct binop-ast [lhs op rhs] #:transparent)

(define (left-associate-binops e1 op* e*)
  (foldl (lambda (op e base) (binop-ast base op e))
    e1 op* e*))

(define-peg term (predicate-token number?))

(define-peg arith-expr-leftrec
  (alt term
       (=> (seq (: e1 arith-expr-leftrec) (: op (alt "+" "-")) (: e2 term))
           (binop-ast e1 op e2))))
