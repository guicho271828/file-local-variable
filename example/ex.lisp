

(defpackage file-local-variable.example
  (:use :cl))

(in-package :file-local-variable.example)

(defun myhook (macrofn form env)
  (print form)
  (funcall macrofn form env))

(flv:file-local-bind *macroexpand-hook* #'myhook)

(print *macroexpand-hook*)

(flv:file-local-unbind)
