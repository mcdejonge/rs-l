;; info.rkt
#lang info
(define collection "rs-l")
(define deps '("base"
               "rackunit"
               "rs"))
(define scribblings '(("scribblings/rs-l.scrbl" )))
(define build-deps '("scribble-lib" "racket-doc"))
