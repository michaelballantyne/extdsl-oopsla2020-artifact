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
            ["--O0" "Set the optimization level to 0" 0]
            ["--O1" "Set the optimization level to 1" 1]
            ["--O2" "Set the optimization level to 2" 2]
            ["--O3" "Set the optimization level to 3" 3])]
  [link-flags (multi/o '() ["-l" l "Link with the library <l>"
                            (lambda (lst) (add-to-end lst l))])])

(module+ test
  (require rackunit)

  (check-equal?
    optimize-level
    3)
  (check-equal?
    link-flags
    '("ssh" "sqlite")))
