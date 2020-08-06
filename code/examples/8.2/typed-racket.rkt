#lang typed/racket

(require type-expander (for-syntax syntax/parse racket))

(define-type-expander fn-obj
  (syntax-parser
    [(_ [name (-> arg ... ret)] ...)
     #'(case->
        [(List 'name arg ...) -> ret] ...)]))

(define-type Posn
  (fn-obj
   [get-x (-> Number)]
   [get-y (-> Number)]
   [distance (-> Posn Number)]))

(: new-posn (-> Number Number Posn))
(define (new-posn x y)
  (λ (msg)
    (match msg
      [`(get-x) x]
      [`(get-y) y]
      [`(distance ,other)
       (sqrt (+ (sqr (- (other '(get-x)) x))
                (sqr (- (other '(get-y)) y))))])))

(module+ test
  (require typed/rackunit)

  (check-equal?
    ((new-posn 1 2) (list 'distance (new-posn 0 0)))
    2.23606797749979))

