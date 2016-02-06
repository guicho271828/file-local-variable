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

;; blah blah blah.

(setf (fdefinition 'read-original) #'read)

(defun skip-and-read (n &rest args)
  (unwind-protect
      (progn
        (let ((*read-suppress* t))
          (dotimes (i n)
            (apply #'read args)))
        (apply #'read args))
    (setf (fdefinition 'read)
          (fdefinition 'read-original))))

(defmacro file-local-bind (variable value &rest more &environment env)
  (recompile-with-flv (list* variable value more) env))

(defun recompile-with-flv (bindings env)
  (progv (iter (for (var val) on bindings by #'cddr)
               (collect var))
      (iter (for (var val) on bindings by #'cddr)
            (collect (eval var)))
    (let ((expansions
           (iter (with stage = :before)
                 (for form in-file *compile-file-pathname*)
                 (ematch* (form stage)
                   (((list* 'file-local-bind _) :before)
                    (setf stage :bound))
                   (((list* 'file-local-unbind _) :bound)
                    (setf stage :after))
                   ((_ :before)
                    (let ((*print-length* 2) (*print-level* 1))
                      (format *standard-output* "~&; skipping ~a" form)))
                   ((_ :bound)
                    (collect (macroexpand-all form env)))
                   ((_ :after)
                    (error "Found a form after file-local-unbind!"))
                   (((list* 'file-local-bind _) _)
                    (error "Found a file-local-bind twice!"))
                   (((list* 'file-local-unbind _) :before)
                    (error "Found a file-local-unbind before file-local-bind!")))
                 (finally
                  (unless (eq stage :after)
                    (error "missing ~A!" 'file-local-unbind))))))
      `(progn
         ,@expansions
         (eval-when (:compile-toplevel :load-toplevel :execute)
           (#+sbcl sb-ext:without-package-locks
            #-sbcl progn
            (setf (fdefinition 'read) (curry #'skip-and-read ,(length expansions)))))))))

(defmacro file-local-unbind ()
  (#+sbcl sb-ext:without-package-locks
   #-sbcl progn
   (setf (fdefinition 'read)
         (fdefinition 'read-original))))
