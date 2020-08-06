#lang racket/base

(require
  cmdline-ee
  rackunit)

(define (add-to-end lst item)
  (append lst (list item)))

(module configure-runtime racket/base
  (current-command-line-arguments
    #("--O3" "-l" "ssh" "-l" "sqlite")))

(define/command-line-options
  #:options
  [optimize-level
    (choice/o #:default 0
            (numbered-flags/f "--O" [0 3] "optimization level"))]
  [link-flags (list/o "-l" l "Link with the library <l>")])

(module+ test
  (require rackunit)

  (check-equal?
    optimize-level
    3)
  (check-equal?
    link-flags
    '("ssh" "sqlite")))
