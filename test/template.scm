(use-modules (ice-9 format)
			 (simpsim edits))

(define (fortran-double f)
  (lambda (x) (f (let ((comps (string-split (format #f "~,4,2e" x) (lambda (c) (char=? c #\E)))))
				   (string-concatenate (list (car comps) "d" (cadr comps)))))))

(define (int-format f)
  (lambda (x)
    (f (format #f "~d" (inexact->exact (ceiling x))))))

(define (raw-format f) f)
  

(define gauss-fluid
  `((data-dir . "os-fluid")
	(carbons   "ollinsphere-fd")
	(editables (parfile (src . "fluid.par")
						(edits (grid-points-total . ,(int-format (c-style-param "Nrtotal"))))))))

