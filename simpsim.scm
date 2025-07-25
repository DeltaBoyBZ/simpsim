(define-module (simpsim))


(use-modules (srfi srfi-1))

(define assoc-or
  (lambda (key lst default)
	(let ((cand (assoc key lst)))
	  (if cand (cdr cand)
		  default))))
				
(define copy-file
 (lambda (src dst)
	(format #f "cp ~a ~a~%" src dst)))

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

(define carbon-src 
  (lambda (carbon)
    (if (pair? carbon) (car carbon)
      carbon)))

(define carbon-dst
  (lambda (carbon)
    (if (pair? carbon) (cdr carbon)
      (carbon-src carbon))))

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

(define editable-format
  (lambda (edit type)
	(cdr (assoc type (cdr (assoc 'format (cdr edit)))))))

(define (editable-edits edit)
  (assoc-or 'edits (cdr edit) '()))

(define (edit-id edit)
  (car edit))

(define (edit-proc edit)
  (cdr edit))

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

(define (export-id export)
  (car export))

(define (export-files export)
  (assoc-or 'files (cdr export) '()))

(define (export-dirs export)
  (assoc-or 'dirs (cdr export) '()))

(define (export-file-src file)
  (if (pair? file) (car file)
	  file))

(define (export-file-dst file)
  (if (pair? file) (cdr file)
	  (export-file-src file)))

(define (export-meta export)
  (assoc-or 'meta (cdr export) '()))

(define (meta-id meta)
  (car meta))

(define (meta-entry meta)
  (cdr meta))

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
	(string-concatenate (append	(map (lambda (dst-subdir)
									   (format #f "mkdir -p \"~a/~a\"~%"
											   dst-dir dst-subdir))
									 (delete-duplicates (map dirname dst-lst)))
								(map (lambda (src dst)
									   (copy-file src dst))
									 (map (prepend-dir src-dir) src-lst)
									 (map (prepend-dir dst-dir) dst-lst))))))
									

(define quick-replace
  (lambda (file search replace)
	(format #f "sed -i -e \"s/~a/~a/g\" ~a~%" search replace file)))

(define replace-in-file
  (lambda (file search-lst replace-lst)
	(string-concatenate
	 (map (lambda (s r)
			(quick-replace file s r))
		  search-lst
		  replace-lst))))

(define carbons-script
  (lambda (carbons data-dir run-dir)
	(copy-files data-dir run-dir
				(map carbon-src carbons)
				(map carbon-dst carbons))))

(define editables-script
  (lambda (editables data-dir run-dir)
	(copy-files data-dir run-dir
				(map editable-src editables)
				(map editable-dst editables))))

  
(define (ammendment-script ammend editables data-dir run-dir)
  (let* ((editable (assoc (ammendment-editable ammend) editables))
		 (edits    (editable-edits editable))
		 (vars     (ammendment-vars ammend)))
	(string-concatenate (map (lambda (f)
							   (f ((prepend-dir run-dir) (editable-dst editable))))
							 (map (lambda (edit-id edit-val)
									((edit-proc (assoc edit-id edits)) edit-val))
								  (map ammendment-var-from vars)
								  (map ammendment-var-to vars))))))
								 
							 														 
														 
					
(define-public make-script
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
									(ammendment-script ammend editables data-dir run-dir))
								  ammendments)))))))

(define (make-meta meta)
  (format #f "echo \"~a\" >> \"$SIMPSIM_EXPORT/meta/~a\"~%"
		  (meta-entry meta) (meta-id meta)))

(define (basename str)
  (car (reverse (string-split str (lambda (x) (char=? #\/ x))))))

(define (dirname str)
  (string-concatenate (map (lambda (x) (string-concatenate (list x "/")))
						   (reverse (cdr (reverse (string-split str (lambda (x) (char=? #\/ x)))))))))

(define-public make-export
  (lambda (root export)
	(string-concatenate
	 (append (list
			  (format #f "SIMPSIM_EXPORT=\"~a/~a-$(uuidgen)\"~%"
					  root (export-id export))
			  "mkdir -p \"$SIMPSIM_EXPORT/meta\"\n")
			 (append (map (lambda (meta) (make-meta meta))
						  (cons `(project . ,(export-id export))
								(export-meta export)))
					 (map (lambda (src dst) (format #f "cp -r ~a \"$SIMPSIM_EXPORT/~a\"~%"
													src dst))
						  (map export-file-src (export-dirs export))
						  (map export-file-dst (export-dirs export)))
					 (map (lambda (dir) (format #f "mkdir -p \"$SIMPSIM_EXPORT/~a\"~%" dir))
						  (delete-duplicates (filter (lambda (x) (> (string-length x) 0))
													 (map dirname
														  (map export-file-dst (export-files export))))))
					 (map (lambda (src dst) (format #f "cp ~a \"$SIMPSIM_EXPORT/~a\"~%"
													src dst))
						  (map export-file-src (export-files export))
						  (map export-file-dst (export-files export))))))))
						  

	
