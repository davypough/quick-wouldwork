;;; Filename: ww-set.lisp

;;; User interface for resetting Wouldwork's search control parameters.

(in-package :ww)


(defmacro ww-set (param val)
  "Allows resetting of user parameters during and after loading."
  `(progn
     (check-problem-parameter ',param ',val)  ;catch syntax errors before setting
     (case ',param
       ((*depth-cutoff* *tree-or-graph* *solution-type*
         *progress-reporting-interval* *randomize-search* *branch*)
          (setf ,param ',val)
          (unless *ww-loading*
            (save-globals))
          ',val)
       (*debug*
         (when *ww-loading*
           (error "Please remove (ww-set *debug* ~S) from the current problem specification file.
                   Instead, enter it at the REPL after loading/staging)." ',val))
         (setf ,param ',val)
         (if (or (> *debug* 0) *probe*)
           (pushnew :ww-debug *features*)
           (setf *features* (remove :ww-debug *features*)))
         (save-globals)
         (with-silenced-compilation
           (asdf:compile-system :wouldwork :force t)
           (asdf:load-system :wouldwork)))
       (*probe*
         (destructuring-bind (action instantiations depth &optional (count 1)) ',val
           (declare (ignore action instantiations depth))
           (setf ,param ',val)
           (setf *debug* 0)
           (setf *counter* count)
           (unless *ww-loading*
             (save-globals)))
         ',val)
       ;(*threads*
       ;    (cond ((member :sbcl *features*)
       ;             (format t "~%*threads* cannot be changed with ww-set.")
       ;             (format t "~%Instead, set its value in the file ww-settings.lisp, and then exit and restart SBCL.~2%"))
       ;          (t (format t "~%Note that multi-threading is not available unless running SBCL.~2%"))))
       ((*problem-name* *problem-type*)
          (if *ww-loading*
            (setf ,param ',val)
            (format t "~%Please set the parameter ~A in the problem specification file, not in the REPL.~%" ',param))))))
