(defvar *db* NIL)

(defun make-cd (title artist rating ripped) ;;we make a cd
  (list :title title :artist artist :rating rating :ripped ripped))

(defun add-record (cd) ;; we had a record to DB
  (push cd *db*))

(defun dump-db () ;; pretty print of DB content
  (format t "~{~{~a:~10t~a~%~}~%~}" *db*))

(defun prompt-read (prompt) ;; helper fn: what dyawanna prompt?
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))

(defun prompt-for-cd () ;; create 1 CD, interactive way
  (make-cd
   (prompt-read "Title")
   (prompt-read "Artist")
   (or (parse-integer (prompt-read "Rating") :junk-allowed t) 0)
   (y-or-n-p "Ripped [y/n]: ")))

(defun add-cds () ;; wraper fn: add CDs to DB
  (loop (add-record (prompt-for-cd))
     (if (not (y-or-n-p "Another one? [y/n]: ")) (return))))

(defun save-db (filename) ;; save DB to file
  (with-open-file (out filename
		       :direction :output
		       :if-exists :supersede)
    (with-standard-io-syntax
      (print *db* out))))

(defun load-db (filename) ;; load DB from file
  (with-open-file (in filename)
    (with-standard-io-syntax
      (setf *db* (read in)))))

;; (defun select-by-artist ()
;;   (remove-if-not
;;    #'(lambda (cd) (equal (getf cd :artist) (prompt-read "Artist to look for?")))
;;    *db*))

(defun select (selector-fn) ;; select from DB
  (remove-if-not selector-fn *db*))

(defun where (&key title artist rating (ripped nil ripped-p)) ;; helper: prompt for DB fields, helps for the select fn above
  #'(lambda (cd)
      (and
       (if title    (equal (getf cd :title)  title)  t)
       (if artist   (equal (getf cd :artist) artist) t)
       (if rating   (equal (getf cd :rating) rating) t)
       (if ripped-p (equal (getf cd :ripped) ripped) t))))
