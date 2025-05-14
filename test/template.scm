(setup gauss-fluid
	   (data-dir . "data")
	   (verbatim . ("ollinsphere" . "ollinsphere-fluid"))
	   (editable . "fluid.par"))

(setup blastwave
	   (vars) ; none
	   (verbatim "ollinsphere") 
	   (editable "blastwave.par"))

(define gauss-fluid
  '((data-dir . "data")
	(verbatim ("ollinsphere" . "ollinsphere-fluid"))
	(editable "fluid.par")))
