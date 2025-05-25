(load "../simpsim.scm")

(format #t
		(make-export "/tmp/simpsim" '("bruh"
									  (files "template.scm"
											 "sub/ammend.scm"
											 ("sub/instance.scm" . "dub/instance.scm"))
									  (dirs "my-bruh")
							 (meta (branch . "$(git branch --show-current)")
								   (date . "$(date)")
								   (seconds . "$(date +%s)")
								   (head . "$(git rev-parse HEAD)")))))
					
