#|
  This file is a part of file-local-variable project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#


(in-package :cl-user)
(defpackage file-local-variable.test-asd
  (:use :cl :asdf))
(in-package :file-local-variable.test-asd)


(defsystem file-local-variable.test
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :description "Test system of file-local-variable"
  :license "LLGPL"
  :depends-on (:file-local-variable
               :fiveam)
  :components ((:module "t"
                :components
                ((:file "package"))))
  :perform (load-op :after (op c) (eval (read-from-string "(every #'fiveam::TEST-PASSED-P (5am:run! :file-local-variable))"))
))
