#lang racket/base

(require (except-in racket-peg-ee #%peg-datum)
         racket-peg-ee/stx-token
         "define-peg-ast.rkt")

(define-peg test (alt "e1" "e2"))

(define-peg-ast raise raise-ast
  (seq "raise" (? (seq (: exn test) (? (seq "from" (: from test)))))))

(module+ test
  (require rackunit racket/list)

  (define example-stx
    (syntax->list #'(raise e1 from e2)))

  (check-equal?
    (parse-result-value (parse raise example-stx))
    (raise-ast
      (srcloc (syntax-source (car example-stx))
              16   ; line (1 indexed)
              21   ; column (0 indexed)
              362  ; character
              16)  ; span in characters
      (second example-stx)
      (fourth example-stx))))

