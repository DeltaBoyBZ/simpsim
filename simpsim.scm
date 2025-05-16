(define assoc-or
  (lambda (key lst default)
	(let ((cand (assoc key lst)))
	  (if cand (cdr cand)
		  default))))
				
(define copy-file
  (lambda (src dst)
	(format #f "cp ~a ~a" src dst)))

(define append-newline
  (lambda (str)
	(string-concatenate (list str "\n"))))

(define template-carbons
  (lambda (template)
	(cdr (assoc 'carbons template))))

(define template-editables
  (lambda (template)
	(cdr (assoc 'editables template))))

(define template-data-dir
  (lambda (template)
	(cdr (assoc 'data-dir template))))

(define editable-id
  (lambda (edit)
	(car edit)))

(define editable-src
  (lambda (edit)
	(cdr (assoc 'src (cdr edit)))))

(define editable-dst
  (lambda (edit)
	(assoc-or 'dst (cdr edit) (editable-src edit))))

(define editable-vars
  (lambda (edit)
	(cdr (assoc 'vars (cdr edit)))))

(define var-id
  (lambda (var)
	(car var)))

(define var-name
  (lambda (var)
	(assoc-or 'name (cdr var) (symbol->string (var-id var)))))

(define var-type
  (lambda (var)
	(cdr (assoc 'type (cdr var)))))


(define ammendment-editable
  (lambda (ammend)
	(cdr (assoc 'editable ammend))))

(define ammendment-vars
  (lambda (ammend)
	(cdr (assoc 'vars ammend))))

(define ammendment-var-from
  (lambda (var)
	(car var)))

(define ammendment-var-to
  (lambda (var)
	(cdr var)))

(define instance-run-dir
  (lambda (instance)
	(cdr (assoc 'run-dir instance))))

(define instance-template
  (lambda (instance)
	(cdr (assoc 'template instance))))

(define instance-ammendments
  (lambda (instance)
	(cdr (assoc 'ammendments instance))))

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

(define prepend-dir
  (lambda (dir)
	(lambda (fname)
	  (string-concatenate (list dir "/" fname)))))

(define copy-files
  (lambda (src-dir dst-dir src-lst dst-lst)
	(string-concatenate (map append-newline
							 (map (lambda (src dst)
									(copy-file src dst))
								  (map (prepend-dir src-dir) src-lst)
								  (map (prepend-dir dst-dir) dst-lst))))))
									

(define quick-replace
  (lambda (file search replace)
	(format #f "sed -i -e \"s/~a/~a/g\" ~a" search replace file)))

(define replace-in-file
  (lambda (file search-lst replace-lst)
	(string-concatenate
	 (map append-newline
		  (map (lambda (s r)
				 (quick-replace file s r))
			   search-lst
			   replace-lst)))))

(define carbons-script
  (lambda (carbons data-dir run-dir)
	(copy-files data-dir run-dir
				(map car carbons)
				(map cdr carbons))))

(define editables-script
  (lambda (editables data-dir run-dir)
	(copy-files data-dir run-dir
				(map editable-src editables)
				(map editable-dst editables))))

  
(define ammendments-script
  (lambda (ammendments editables data-dir run-dir)
	(string-concatenate (map (lambda (ammend)
							   (let ((edit (assoc (ammendment-editable ammend) editables)))
								 (replace-in-file ((prepend-dir run-dir) (editable-dst edit))
												  (map (lambda (varid)
														 (string-concatenate (list "\\`"
																				   (var-name (assoc varid (editable-vars edit)))
																				   "\\`")))
													   (map ammendment-var-from (ammendment-vars ammend)))
												  (map (lambda (x) (format #f "~a"x))
													   (map ammendment-var-to   (ammendment-vars ammend))))))
							 ammendments))))
														 
														 
					
(define make-script
  (lambda (instance)
	(let ((template (instance-template instance))
		  (ammendments (instance-ammendments instance)))
	  (let ((data-dir (template-data-dir template))
			(run-dir  (instance-run-dir instance))
			(carbons (template-carbons template))
			(editables (template-editables template)))
		(string-concatenate (append
							 (list (format #f "mkdir -p ~a~%" run-dir)
								   (carbons-script carbons data-dir run-dir)
								   (editables-script editables data-dir run-dir))
							 (map (lambda (ammend)
									(ammendments-script ammend editables data-dir run-dir))
								  ammendments)))))))

	
