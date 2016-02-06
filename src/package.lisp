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

(setf (fdefinition 'read-original) (fdefinition 'read))
(setf (fdefinition 'read-char-original) (fdefinition 'read-char))

(defun skip-and-read (n &rest args)
  "Overriding READ does not work, since SBCL uses internal %read-preserving-whitespace."
  (unwind-protect
      (let ((*read-suppress* t))
        (dotimes (i n)
          (print (apply #'read-original args))))
    (#+sbcl sb-ext:without-package-locks
     #-sbcl progn
     (setf (fdefinition 'read)
           (fdefinition 'read-original)))))

(defun skip-and-read-char (n &rest args)
  "Overriding READ-CHAR does not work either, since it has a buffer and several characters are already read."
  (unwind-protect
      (progn
        (dotimes (i n)
          (print (apply #'read-char-original args)))
        (print (apply #'read-char-original args)))
    (#+sbcl sb-ext:without-package-locks
     #-sbcl progn
     (setf (fdefinition 'read-char)
           (fdefinition 'read-char-original)))))

(defun skip-and-read (n &rest args)
  (unwind-protect
      (let ((*read-suppress* t))
        (dotimes (i n)
          (print (apply #'read-original args))))
    (#+sbcl sb-ext:without-package-locks
     #-sbcl progn
     (setf (fdefinition 'read)
           (fdefinition 'read-original)))))

(defmacro file-local-bind (variable value &rest more &environment env)
  (recompile-with-flv (list* variable value more) env))

(defun recompile-with-flv (bindings env)
  (format t "~&; rereading file ~s" *compile-file-pathname*)
  (progv (iter (for (var val) on bindings by #'cddr)
               (collect var))
      (iter (for (var val) on bindings by #'cddr)
            (collect (eval var)))
    (with-open-file (in *compile-file-pathname* :direction :input)
      (print (file-length in))
      (let* ((skipped 0)
             (start 0)
             (end 0)
             (expansions
              (iter (with stage = :before)
                    (for form in-stream in)
                    (ematch* (form stage)
                      (((list* 'file-local-bind _) :before)
                       (setf start (file-position in))
                       (format t "~&; skipped ~a forms." skipped)
                       (format t "~&; file-local-bind found, compiling the remaining forms with variables bound")
                       (setf stage :bound))
                      ;; (((list* 'file-local-unbind _) :bound)
                      ;;  (format t "~&; file-local-unbind found, checking the remaining forms")
                      ;;  (setf stage :after))
                      ((_ :before)
                       (let ((*print-length* 2) (*print-level* 1))
                         (format t "~&; skipping ~a" form))
                       (incf skipped))
                      ((_ :bound)
                       (let ((*print-length* 2) (*print-level* 1))
                         (format t "~&; expanding ~a" form))
                       (collect (macroexpand-all form env)))
                      (((list* 'file-local-bind _) _)
                       (error "Found a file-local-bind twice!"))
                      ;; ((_ :after)
                      ;;  (error "Found a form after file-local-unbind!"))
                      ;; (((list* 'file-local-unbind _) :before)
                      ;;  (error "Found a file-local-unbind before file-local-bind!"))
                      )
                    (finally
                     (setf end (file-position in))
                     ;; (unless (eq stage :after)
                     ;;   (error "missing ~A!" 'file-local-unbind))
                     ))))
        (format t "~&; read ~a forms (char ~a - ~a, ~a characters)." (length expansions) start end (- end start))
        (prog1
          (print
           `(progn
              ,@expansions
              (eval-when (:compile-toplevel :load-toplevel :execute)
                (#+sbcl sb-ext:without-package-locks
                        #-sbcl progn
                        (setf (fdefinition 'read-char) (curry #'skip-and-read-char ,(- end start)))))))
          (format t "~&; Resuming compilation while skipping them"))))))

#+nil
(defmacro file-local-unbind ()
  (#+sbcl sb-ext:without-package-locks
   #-sbcl progn
   (setf (fdefinition 'read)
         (fdefinition 'read-original))))
