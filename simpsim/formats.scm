(define-module (simpsim formats))

(use-modules (ice-9 format))

(define-public fortran-double
  (lambda (x)
	(let ((comps (string-split (format #f "~,16,2e" x) (lambda (c) (char=? c #\E)))))
	  (string-concatenate (list (car comps) "d" (cadr comps))))))

(define-public c-double-format
  (lambda (x)
	(format #f "~,16,2e" x)))
	

(define-public int-format 
  (lambda (x)
    (format #f "~d" (inexact->exact (ceiling x)))))

(define-public (array-format paren delim elem-format)
  (lambda (x)
	(format #f "~a ~a ~a ~a"
			(car paren) (elem-format (car x))
			(string-concatenate
			 (map (lambda (xx) (format #f "~a ~a" delim (elem-format xx)))
				  (cdr x)))
			(cdr paren))))
  
(define-public raw-format
  (lambda (x) x))

(define-public string-format
  (lambda (x) (format #f "\"~a\"" x)))

(define-public fortran-double-format
  (lambda (x)
	(string-map (lambda (c) (if (char=? c #\e) #\d
								c))
				(c-double-format x))))
