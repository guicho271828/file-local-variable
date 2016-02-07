
(defpackage flv.example
  (:use :cl))
(in-package :flv.example)

(defun myhook (macrofn form env)
  (print form)
  (funcall macrofn form env))

(flv:file-local-bind *macroexpand-hook* 'myhook
                     *read-default-float-format* 'double-float)

(eval-when (:compile-toplevel) (print :compile-toplevel))
(eval-when (:load-toplevel)    (print :load-toplevel))
(eval-when (:execute)          (print :execute))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (print '#.*macroexpand-hook*)         ; 'myhook
  (print (type-of 3.0)))                ; 'double-float

