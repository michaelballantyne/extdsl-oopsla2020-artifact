#lang racket/base

(require racket-peg-ee)

(use-literal-token-interpretation syntax-token)

(struct ast [srcloc] #:transparent)

; stub `test` production
(define-peg test (alt "e1" "e2"))

(struct raise-ast ast [exn from] #:transparent) ; a structure with a super type, `ast`
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
              22   ; line (1 indexed)
              21   ; column (0 indexed)
              526  ; character
              16)  ; span in characters
      (second example-stx)
      (fourth example-stx))))
