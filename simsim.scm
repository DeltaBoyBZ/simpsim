(define copy-file
  (lambda (src dst)
	(format #f "cp ~a ~a" src dst)))

(define append-newline
  (lambda (str)
	(string-concatenate (list str "\n"))))

(define setup-verbatim
  (lambda (setup)
	(cdr (assoc 'verbatim setup))))

(define setup-editable
  (lambda (setup)
	(cdr (assoc 'editable setup))))

(define setup-data-dir
  (lambda (setup)
	(cdr (assoc 'data-dir setup))))

(define src-file
  (lambda (dir src-dst)
	(format #f "~a/~a" dir
			(if (pair? src-dst)
				(car src-dst)
				src-dst))))

(define dst-file
  (lambda (dir src-dst)
	(format #f "~a/~a" dir
			(if (pair? src-dst)
				(cdr src-dst)
				src-dst))))

(define copy-files
  (lambda (src-dir dst-dir files)
	(let ((src (map (lambda (f) (src-file src-dir f)) files))
		  (dst (map (lambda (f) (dst-file dst-dir f)) files)))
	(string-concatenate (map append-newline
							 (map copy-file
								  src dst))))))

(define quick-replace
  (lambda (file search replace)
	(format #f "sed -i -e \"s/~a/~a/g\" ~a" search replace file)))

(define make-script
  (lambda (setup dst-dir)
	(let ((data-dir (setup-data-dir setup))
		  (verbatim (setup-verbatim setup))
		  (editable (setup-editable setup)))
	  (string-concatenate (list (copy-files data-dir dst-dir verbatim)
								(copy-files data-dir dst-dir editable))))))
	
(define-syntax setup
  (syntax-rules ()
    ((setup name ...)
     (define name ...))))
				   
