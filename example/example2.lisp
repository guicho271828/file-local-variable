
(defpackage flv.example
  (:use :cl))
(in-package :flv.example)

(defun myhook (macrofn form env)
  (print form)
  (funcall macrofn form env))

(flv:file-local-bind *macroexpand-hook* 'myhook)

(eval-when (:compile-toplevel) (print :compile-toplevel))
(eval-when (:load-toplevel)    (print :load-toplevel))
(eval-when (:execute)          (print :execute))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (print *macroexpand-hook*))

