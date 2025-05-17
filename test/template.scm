(use-modules (ice-9 format))

(define fortran-double
  (lambda (x)
	(let ((comps (string-split (format #f "~,4,2e" x) (lambda (c) (char=? c #\E)))))
	  (string-concatenate (list (car comps) "d" (cadr comps))))))

(define int-format
  (lambda (x)
    (format #f "~d" (inexact->exact (ceiling x)))))

(define raw-format
  (lambda (x) x))

(define gauss-fluid
  `((data-dir . "os-fluid")
	(carbons   "ollinsphere-fd")
	(editables (parfile (src . "fluid.par")
						(vars (grid-points-total (type . int)
										  (default . 1003))
                (time-steps (type . int)
                            (default . 1000))
							  (grid-spacing (type . double)
											(default . 0.01))
							  (cfl (type . double)
								   (default . 0.1))
                (fluid-method (type . raw)
                              (default . "mp5"))
                (fluid-limiter (type . raw)
                               (default . "minmod")))
						(format (double . ,fortran-double)
                    (raw . ,raw-format)
                    (int . ,int-format))))))
