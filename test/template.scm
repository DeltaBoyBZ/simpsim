(define gauss-fluid
  '((data-dir . "data")
	(carbons   ("ollinsphere" . "ollinsphere-fluid"))
	(editables (parfile (src . "fluid.par")
						(vars (num-points (type . double)
										  (default . 1000))
							  (grid-spacing (type . double)
											(default . 0.01)))))))
