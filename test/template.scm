(use-modules (ice-9 format))

(define fortran-double
  (lambda (x)
	(let ((comps (string-split (format #f "~,4,2e" x) (lambda (c) (char=? c #\E)))))
	  (string-concatenate (list (car comps) "d" (cadr comps))))))

(define gauss-fluid
  `((data-dir . "data")
	(carbons   ("ollinsphere" . "ollinsphere-fluid"))
	(editables (parfile (src . "fluid.par")
						(vars (num-points (type . double)
										  (default . 1000))
							  (grid-spacing (type . double)
											(default . 0.01))
							  (cfl (type . double)
								   (default . 0.1)))
						(format (double . ,fortran-double))))))
