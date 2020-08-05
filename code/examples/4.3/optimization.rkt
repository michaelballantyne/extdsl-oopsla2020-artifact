#lang racket/base

(require racket-peg-ee)

(define-peg comp-op
  (alt "<" ">" "==" ">=" "<=" "!=" "in" (seq "not" "in") (seq "is" "not") "is"))
