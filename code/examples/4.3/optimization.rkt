#lang racket/base

(require racket-peg-ee)

(define-peg comp-op
  (alt "==" ">=" "<=" "<" ">" "!=" "in" "not" "is"))
