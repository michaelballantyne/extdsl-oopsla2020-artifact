#lang racket/base

(require (except-in racket-peg-ee #%peg-datum)
         racket-peg-ee/stx-token)

(struct ast [srcloc] #:transparent)
(struct raise-ast ast [exn from] #:transparent) ; a structure with a super type, `ast`

(define-peg test (alt "e1" "e2"))

(define-peg raise
  (=> (:src-span srcloc
         (seq "raise" (? (seq (: exn test) (? (seq "from" (: from test)))))))
      (raise-ast srcloc exn from)))

(module+ test
  (require rackunit racket/list)

  (define example-stx
    (syntax->list #'(raise e1 from e2)))

  (check-equal?
    (parse-result-value (parse raise example-stx))
    (raise-ast
      (srcloc (syntax-source (car example-stx))
              20   ; line (1 indexed)
              21   ; column (0 indexed)
              509  ; character
              16)  ; span in characters
      (second example-stx)
      (fourth example-stx))))
