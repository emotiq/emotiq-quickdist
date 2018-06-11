;;; -*- Mode: LISP; Syntax: COMMON-LISP -*-
(defsystem "emotiq-quickdist"
  :version "0.0.2"
  :depends-on (quickdist  ;; <https://github.com/emotiq/quickdist/tree/master>
               puri
               zs3
               simple-date-time
               cl-ppcre)
  :in-order-to ((test-op (test-op "emotiq-quickdist/t")))
  :components ((:module package
                        :pathname "./"
                        :components ((:file "package")))
               (:module source
                        :depends-on (package)
                        :pathname "./"
                        :components ((:file "git")
                                     (:file "emotiq-quickdist")))))

(defsystem "emotiq-quickdist/localhost"
  :depends-on (hunchentoot
               emotiq-quickdist)
  :components ((:module source
                        :pathname "./"
                        :components ((:file "localhost")))))
                        
(defsystem "emotiq-quickdist/t"
  :defsystem-depends-on (prove-asdf)
  :depends-on (emotiq-quickdist prove)
  :perform (asdf:test-op (o c) (uiop:symbol-call :prove-asdf :run-test-system c))
  :components ((:module test
                        :pathname "t/"
                        :components ((:test-file "base")))))

