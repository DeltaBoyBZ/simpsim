(define-module (simpsim formats))

(use-modules (ice-9 format))

(define-public (fortran-double f)
  (lambda (x)
	(f (let ((comps (string-split (format #f "~,16,2e" x) (lambda (c) (char=? c #\E)))))
		 (string-concatenate (list (car comps) "d" (cadr comps)))))))

(define-public (c-double-format f)
  (lambda (x)
	(f (format #f "~,16,2e" x))))
	

(define-public (int-format f)
  (lambda (x)
    (f (format #f "~d" (inexact->exact (ceiling x))))))
