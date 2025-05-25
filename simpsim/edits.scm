(define-module (simpsim edits))
  

(define-public c-style-param
  (lambda (var)
	(lambda (val)
	  (lambda (file)
		(format #f "sed -i -e \"s/^\\(\\s*~a\\s*=\\s*\\)\\(.*\\)$/\\1~a/g\" \"~a\"~%"
				var val file)))))

(define-public (remove-param var)
  (lambda (val)
	(lambda (file)
	  (format #f "sed -i -e \"s/^\\(\\s*~a\\s*=\\s*\\)\\(.*\\)$//g\" \"~a\"~%"
			  var file))))

(define-public (remove-when pred)
  (lambda (var)
	(lambda (val)
	  (lambda (file)
		(if (pred val)
			(((remove-param var) val) file)
			"")))))
				

(define-public (insert-when-absent var)
  (lambda (val)
	(lambda (file)
	  (format #f "grep \"^\\s*~a\\s*=\" \"~a\" || echo \"~a = ~a\" >> \"~a\"~%"
			  var file
			  var val file))))

(define-public (edit-compose . fs)
  (lambda (var)
	(lambda (val)
	  (lambda (file)
		(string-concatenate (map (lambda (f) (((f var) val) file))
								 fs))))))
