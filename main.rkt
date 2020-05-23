#lang racket/base

(require rs
         racket/contract/base
         racket/contract/region
         racket/list
         racket/math)

(provide rs-l-cond
         rs-l-process-seq
         rs-l-repeats
         rs-l-rotate-left
         rs-l-rotate-right)

(define (valid-offset? offset)
  (and (number? offset)
       (< offset 1)
       (> offset -1)))

(define/contract (rs-l-cond proc cond-proc #:offset [offset 0])
  (->* (procedure? procedure?)
       (#:offset valid-offset?) rs-e?)
  ;; Return an event that wraps the supplied procedure. The procedure
  ;; is only called if cond-proc returns true. The procedure gets the
  ;; step time as a parameter (so you can use the same procedure you
  ;; would use in an rs-e event).
  (rs-e-create #:fn (lambda (step-time)
                      (when (cond-proc)
                        (proc step-time)))
               #:offset offset))

(define/contract (rs-l-repeats event repeat-proc #:offset [offset 0])
  (->* (rs-e? procedure?)
       (#:offset valid-offset?) rs-e?)
  ;; Return an event that creates a sub sequence in which the supplied
  ;; rs-e event is repeated the number of times that the repeat-proc
  ;; procedure returns. 
  (rs-e-create #:fn 
               (for/list ([i (repeat-proc)])
                 event) 
               #:offset offset))

(define/contract (rs-l-process-seq seq proc #:offset [offset 0])
  (->* (list? procedure?)
       (#:offset valid-offset?) rs-e?)
  ;; Every iteration apply proc to the sequence before playing it. The
  ;; result is stored and serves as the starting point for the next
  ;; iteration.
  (define current-seq seq)
  (define process-proc
    (lambda (step-time)
      (set! current-seq (proc current-seq))
      (rs-t-play-seq! current-seq step-time)))
  (rs-e-create #:fn process-proc
               #:offset offset))

(define/contract (rs-l-rotate-left seq #:num-steps [num-steps 1] #:offset [offset 0])
  (->* (list?)
       (#:num-steps natural? #:offset valid-offset?) rs-e?)
  ;; Every iteration the sequence is rotated num-steps steps to the
  ;; left.
  (rs-l-process-seq seq
                    (lambda (seq-in-lambda)
                      (define reversed (reverse seq-in-lambda))
                      (reverse
                       (append (take-right reversed num-steps) (drop-right reversed num-steps))))
                    #:offset offset))

(define/contract (rs-l-rotate-right seq #:num-steps [num-steps 1] #:offset [offset 0])
  (->* (list?)
       (#:num-steps natural? #:offset valid-offset?) rs-e?)
  ;; Every iteration the sequence is rotated num-steps steps to the
  ;; right.
  (rs-l-process-seq seq
                    (lambda (seq-in-lambda)
                      (append (take-right seq-in-lambda num-steps) (drop-right seq-in-lambda num-steps)))
                    #:offset offset))

