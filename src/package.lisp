#|
  This file is a part of file-local-variable project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage file-local-variable
  (:use :cl :iterate :alexandria :trivia)
  (:nicknames :flv)
  (:import-from #+sbcl :sb-cltl2
                #+ccl :ccl
                :macroexpand-all)
  (:export
   #:file-local-bind
   #:file-local-unbind))

(in-package :file-local-variable)

;; sb-int:base-char-code-limit
;; char-code-limit

(defvar *dumb-readtable*
    (iter (with srt = (copy-readtable nil))
          (with rt = (copy-readtable nil))
          (for code from 0 below
               ;; #+sbcl sb-int:base-char-code-limit
               ;; #-(or sbcl)
               char-code-limit)
          (set-syntax-from-char (code-char code) #\Space rt srt)
          (finally (return rt))))

;; blah blah blah.

(defmacro file-local-bind (variable value &rest more &environment env)
  (recompile-with-flv (list* variable value more) env))

(defun recompile-with-flv (bindings env)
  (when *compile-verbose*
    (format t "~&~@<; ~@; rereading ~a ~@:>" *compile-file-pathname*)
    (format t "~&~<; binding: ~@; ~a to ~a ~@:>" bindings))
  (let* ((skipped 0)
         (expansions
          (progv (iter (for (var val) on bindings by #'cddr)
                       (collect var))
              (iter (for (var val) on bindings by #'cddr)
                    (collect (eval val)))
            (iter (with stage = :before)
                  (for form in-file *compile-file-pathname*)
                  (ematch* (form stage)
                    (((list* 'file-local-bind _) :before)
                     (when *compile-verbose*
                       (format t "~&~@<; ~@;skipped ~a forms. ~@:>" skipped)
                       (format t "~&~@<; ~@;file-local-bind found, compiling the remaining forms with variables bound. ~@:>"))
                     (setf stage :bound))
                    ((_ :before)
                     (when *compile-verbose*
                       (let ((*print-length* 2) (*print-level* 2))
                         (format t "~&~@<; ~@;skipping ~a ~@:>" form)))
                     (incf skipped))
                    ((_ :bound)
                     (when *compile-verbose*
                       (let ((*print-length* 2) (*print-level* 2))
                         (format t "~&~@<; ~@;expanding ~a ~@:>" form)))
                     (collect (macroexpand-all form env)))
                    (((list* 'file-local-bind _) _)
                     (error "Found a file-local-bind twice!")))))))
    (when *compile-verbose*
      (format t "~&~@<; ~@;read ~a forms.~@:>" (length expansions)))
    (prog1
      `(progn
         ,@expansions
         (eval-when (:compile-toplevel :load-toplevel :execute)
           (setf *readtable* *dumb-readtable*)))
      (when *compile-verbose*
        (format t "~&~@<; ~@;Resuming compilation while skipping these ~a forms. ~@:>" (length expansions))))))
