#lang racket/base

(require
  racket-peg-ee
  (prefix-in core: racket-peg-ee/core)
  (for-syntax racket/base syntax/parse))

(provide define-peg-ast (struct-out ast))

(struct ast [srcloc] #:transparent)

(define-for-syntax (find-parse-var-bindings stx)
  (syntax-parse stx
    #:literal-sets (peg-literals)
    [core:eps '()]
    [(core:seq e1 e2)
     (append (find-parse-var-bindings #'e1)
             (find-parse-var-bindings #'e2))]
    [(core:alt e1 e2)
     (append (find-parse-var-bindings #'e1)
             (find-parse-var-bindings #'e2))]
    [(core:* e) (find-parse-var-bindings #'e)]
    [(core:! e) '()]
    [(core:: x e) (list #'x)]
    [(core:=> pe e) '()]
    [(core:text t) '()]
    [(core:token f) '()]
    [(core:char f) '()]
    [name:id '()]
    [(core::src-span v e) (find-parse-var-bindings #'e)]
    [_ (raise-syntax-error #f "not a core peg form" this-syntax)]))

(define-syntax define-peg-ast
  (lambda (stx)
    (syntax-parse stx
      [(_ peg-name:id ast-name:id p:peg)
       (define/syntax-parse (_ p^ _) (local-expand-peg #'(=> p (void))))
       (define/syntax-parse (var ...)
         (find-parse-var-bindings #'p^))
       #'(begin
           (struct ast-name ast [var ...] #:transparent)
           (define-peg peg-name
             (=> (:src-span srcloc p^) (ast-name srcloc var ...))))])))
