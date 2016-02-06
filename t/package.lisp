#|
  This file is a part of file-local-variable project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :file-local-variable.test
  (:use :cl
        :file-local-variable
        :fiveam
        :iterate :alexandria :trivia))
(in-package :file-local-variable.test)



(def-suite :file-local-variable)
(in-suite :file-local-variable)

;; run test with (run! test-name) 



(test file-local-variable
  (with-input-from-string (in (with-output-to-string (*standard-output*)
                                (compile-file "example/example.lisp")))
    (is (eq :compile-toplevel (read in)))
    (is (eq 'myhook (read in))))
  (with-input-from-string (in (with-output-to-string (*standard-output*)
                                (load (compile-file-pathname "example/example.lisp"))))
    (is (eq :load-toplevel (read in)))
    (is (eq 'myhook (read in)))))



