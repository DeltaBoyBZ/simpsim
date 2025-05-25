(define-module (simpsim edits))
  

(define-public (c-style-param var)
  (lambda (val)
	(lambda (file)
	  (format #f "sed -i -e \"s/^\\(\\s*~a\\s*=\\s*\\)\\(.*\\)$/\\1~a/g\" \"~a\"~%"
			  var val file))))
