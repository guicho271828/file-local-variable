#|
  This file is a part of file-local-variable project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#

#|
  File-local variable independent from ASDF

  Author: Masataro Asai (guicho2.71828@gmail.com)
|#



(in-package :cl-user)
(defpackage file-local-variable-asd
  (:use :cl :asdf))
(in-package :file-local-variable-asd)


(defsystem file-local-variable
  :version "0.1"
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :license "LLGPL"
  :depends-on (:iterate :alexandria :trivia)
  :components ((:module "src"
                :components
                ((:file "package"))))
  :description "File-local variable independent from ASDF"
  :in-order-to ((test-op (load-op :file-local-variable.test))))
