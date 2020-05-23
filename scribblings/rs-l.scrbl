#lang scribble/manual
@require[@for-label[rs-l
                    rs
                    racket/base
                    racket/list
                    racket/math]]

@title{rs-l : Loop and event library for rs}
@author{mcdejonge}


@defmodule[rs-l]

@section{Overview}

This package collects useful tools for creating loops and events for @hyperlink["https://pkgs.racket-lang.org/package/rs"]{rs - the Racket Sequencers}.

@section[#:tag "functions"]{Functions}

This section lists all the functions that are available.

@defproc[(rs-l-cond [proc procedure?]
                    [cond-proc procedure?]
                    [#:offset valid-offset? 0]) rs-e]

Returns an event that wraps the supplied procedure. The procedure is only called if cond-proc returns true. The procedure gets the step time as a parameter (so you can use the same procedure you would use in an rs-e event).

Here is an example of how you create an event that sets a MIDI cc value when @racket[(random 3)] is greater than 1:

@codeblock|{
(define cc1 (rs-m-event-cc instr 12 25))
(define cc1-cond
  (rs-l-cond
    (rs-e-fn cc1)
    (lambda ()
      (> (random 3) 1))))
}|

@defproc[(rs-l-process-seq [seq list?]
                           [proc procedure?]
                           [#:offset valid-offset? 0]) rs-e]

Every iteration proc is applied to seq before playing it. The result of the application is stored and serves as input to proc for the next iteration. Use this to create functions that create continuously changing sequences, such as rotating sequences.

@defproc[(rs-l-repeats [event rs-e?]
                       [repeat-proc procedure?]
                       [#:offset valid-offset? 0]) rs-e]

Return an event that creates a sub sequence in which the supplied event is repeated a number of times. How often the event is repeated is determined by the return value of repeat-proc. repeat-proc is called every time the event is called.

Here is an example where a note is repeated between 2 and 4 times. The number of times it is repeated is different every time the event is called:

@codeblock|{
(define note-rep
        (rs-l-repeats note-event
                      (lambda() (+ 2 (random 3)))))
}|

@defproc[(rs-l-rotate-left [seq list?]
                           [#:num-steps natural? 1]
                           [#:offset valid-offset? 0]) rs-e]
                           
@defproc[(rs-l-rotate-right [seq list?]
                            [#:num-steps natural? 1]
                            [#:offset valid-offset? 0]) rs-e]

These functions rotate the given sequence left or right, respectively, every time they're called.

Example:

@codeblock|{
(define seq (list note1 note2 note3))
(define seq-rotating (list (rs-l-rotate-left seq #:num-steps 2)))
}|

This rotates seq two steps to the left at the start of every iteration of the loop of the track it is assigned to.

The reason this works is that in rs sequences can have an arbitrary number of steps AND sequences can be nested. What happens is every iteration of the track loop the sequence "seq-rotating" is started, which has only one event, namely the event created by rs-l-rotate-left. This event returns another sequence, namely the list (note1 note2 note3 note4), which is rotated every time the event created by rs-l-rotate-left is called.

The result loooks like this:

@codeblock|{
(list note1 note2 note3)
(list note3 note1 note2)
(list note2 note3 note1)
(list note1 note2 note3)
;; ... etc

}|
@section{Changelog}

@itemlist[
    @item{@bold{2020-05-23} Initial release.}
]