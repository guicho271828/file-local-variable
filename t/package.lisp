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

  )



