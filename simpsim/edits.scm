(define-module (simpsim edits))
  

(define (c-replace file varname valstr)
  (format #f "sed -i -e \"s/^\\(\\s*~a\\s*=\\s*\\)\\(.*\\)$/\\1~a/g\" \"~a\"~%"
		  varname valstr file))

(define (c-remove file var)
  (format #f "sed -i -e \"s/^\\(\\s*~a\\s*=\\s*\\)\\(.*\\)$//g\" \"~a\"~%"
		  var file))
				
(define (c-insert-when-absent file var)
  (format #f "grep \"^\\s*~a\\s*=\" \"~a\" > /dev/null || echo \"~a = \" >> \"~a\"~%"
		  var file
		  var file))

(define (rev-range k)
  (if (= k 0) '(0)
	  (cons k (rev-range (1- k)))))

(define (range k)
  (reverse (rev-range (1- k))))


(define-public (nested-c-replace-awk varchain val)
  (format #f "BEGIN { insertlevel = ~a} { if (/{/) {FS = \"{\" ; node[k] = $1; gsub(/\\s/, \"\", node[k]) ; k++ }} {if (/}/) k--}\
{if (k == insertlevel && ~a /^\\s*~a\\s*=/) {gsub(/=.*$/, \"= ~a\", $0)} ; print }"
		  (1- (length varchain))
		  (string-concatenate (map (lambda (x) (format #f "~a && " x))
								   (map (lambda (k) (format #f "node[~a] == \"~a\""
															k (list-ref varchain k)))
										(range (1- (length varchain))))))
		  (car (reverse varchain))
		  val))


(define-public (nested-c-search-awk varchain)
  (format #f "BEGIN {present = 0 ; insertlevel = ~a ; FS = \"{\"} { if (/{/) {node[k] = $1; gsub(/\\s/, \"\", node[k]) ; k++ }} {if (/}/) k--}\
{if (k == insertlevel && ~a /^\\s*~a\\s*=/) {present++}} END { if (present == 0) {exit 1} }"
		  (1- (length varchain))
		  (string-concatenate (map (lambda (x) (format #f "~a && " x))
								   (map (lambda (k) (format #f "node[~a] == \"~a\""
															k (list-ref varchain k)))
										(range (1- (length varchain))))))
		  (car (reverse varchain))))

(define-public (nested-c-insert-awk varchain val)
  (format #f "BEGIN {present = 0 ; insertlevel = ~a ; FS = \"{\"} { if (/{/) {node[k] = $1; gsub(/\\s/, \"\", node[k]) ; k++ }} {if (/}/) k--}\
 { print } {if (k == insertlevel && ~a present == 0) { printf \"~a = ~a\\n\" ; present++}} END { if (present == 0) {exit 1} }"
		  (1- (length varchain))
		  (string-concatenate (map (lambda (x) (format #f "~a && " x))
								   (map (lambda (k) (format #f "node[~a] == \"~a\""
															k (list-ref varchain k)))
										(range (1- (length varchain))))))
		  (car (reverse varchain))
		  val))

(define-public (nested-c-comment-awk varchain)
  (format #f "BEGIN { insertlevel = ~a} { if (/{/) {FS = \"{\" ; node[k] = $1; gsub(/\\s/, \"\", node[k]) ; k++ }} {if (/}/) k--}\
{if (k == insertlevel && ~a /^\\s*~a\\s*=/) {printf \"// %s\\n\" $0} else print }"
		  (1- (length varchain))
		  (string-concatenate (map (lambda (x) (format #f "~a && " x))
								   (map (lambda (k) (format #f "node[~a] == \"~a\""
															k (list-ref varchain k)))
										(range (1- (length varchain))))))
		  (car (reverse varchain))))


(define (nested-c-search file varchain)
  (format #f "awk '~a' ~a" (nested-c-search-awk varchain) file))

(define (nested-c-replace file varchain val)
  (format #f "awk '~a' ~a" (nested-c-replace-awk varchain val) file))

(define (nested-c-comment file varchain)
  (format #f "awk '~a' ~a" (nested-c-comment-awk varchain) file))

(define (nested-c-insert file varchain val)
  (format #f "awk '~a' ~a" (nested-c-insert-awk varchain val) file))

(define-public (generic-c varname val-format)
  (lambda (val)
	(let ((valstr (val-format val)))
	  (lambda (file)
		(if (eq? val 'none) (c-remove file varname)
			(string-concatenate (list (c-insert-when-absent file varname)
									  (c-replace file varname valstr))))))))
  
  
(define-public (nested-c varchain val-format)
  (lambda (val)
	(let ((valstr (val-format val)))
	(lambda (file)
	  (if (eq? val 'none) (nested-c-comment file varchain)
	   	  (format #f "(~a && ~a || ~a) > /tmp/paredit && mv /tmp/paredit ~a"
				  (nested-c-search file varchain)
				  (nested-c-replace file varchain valstr)
				  (nested-c-insert file varchain valstr)
				  file))))))

