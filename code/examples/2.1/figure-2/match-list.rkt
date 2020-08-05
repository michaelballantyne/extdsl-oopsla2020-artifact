#lang racket
(require (for-syntax syntax/parse))
(provide match-list)

(define (match-list-error) (error 'match-list "expected a pair or empty list"))

(define-syntax match-list
  (lambda (stx)
    (syntax-parse stx
      [(_ e:expr [() null-body ...+] [(a:id d:id) pair-body ...+])
       #'(let ([v e])
           (cond [(null? v) null-body ...]
                 [(pair? v) (let ([a (car v)] [d (cdr v)]) pair-body ...)]
                 [else (match-list-error)]))])))
