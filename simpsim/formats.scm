(define-module (simpsim formats))

(use-modules (ice-9 format))

(define-public (fortran-double f)
  (lambda (x)
	(f (let ((comps (string-split (format #f "~,16,2e" x) (lambda (c) (char=? c #\E)))))
		 (string-concatenate (list (car comps) "d" (cadr comps)))))))

(define-public c-double-format
  (lambda (x)
	(format #f "~,16,2e" x)))
	

(define-public int-format 
  (lambda (x)
    (format #f "~d" (inexact->exact (ceiling x)))))

(define-public raw-format
  (lambda (x) x))

(define-public fortran-double-format
  (lambda (x)
	(string-map (lambda (c) (if (char=? c #\e) #\d
								c))
				(c-double-format x))))
