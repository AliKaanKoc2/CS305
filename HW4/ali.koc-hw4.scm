(define check-length?
	(lambda (inTriple count)
		(if (null? inTriple)
		    (= count 0)
		    (if (= count 0)
		       #f
		       (check-length? (cdr inTriple) (- count 1))))))


(define check-sides?
	(lambda (inTriple)
		(if (null? inTriple)
		    #t
		    (if (and (integer? (car inTriple)) (> (car inTriple) 0))
		    	(check-sides? (cdr inTriple))
			#f))))


(define check-triple?
	(lambda (tripleList)
   		(if (null? tripleList)
        	    #t
                    (if (and (list? (car tripleList))
                	(not (null? (car tripleList)))
                 	(check-length? (car tripleList) 3)
                 	(check-sides? (car tripleList)))
            	      (check-triple? (cdr tripleList))
                      #f))))


(define insert
  	(lambda (x sortedList)
	  	(if (null? sortedList)
	            (list x)
	            (if (<= x (car sortedList))
	     		(cons x sortedList)
			(cons (car sortedList) (insert x (cdr sortedList)))))))


(define sort-triple
	(lambda (inTriple)
	 	(if (null? inTriple)
		    '()
		    (insert (car inTriple) (sort-triple (cdr inTriple)))))) 


(define sort-all-triples
  	(lambda (tripleList)
    		(if (null? tripleList)
        	    '()
            	    (cons (sort-triple (car tripleList)) (sort-all-triples (cdr tripleList))))))


(define triangle?
	(lambda (triple)
		(> (+ (car triple) (cadr triple)) (caddr triple))))


(define filter-triangle
	(lambda (tripleList)
		(if (null? tripleList)
		    '()
		    (if (triangle? (car tripleList))
		      	(cons (car tripleList) (filter-triangle (cdr tripleList)))
			(filter-triangle (cdr tripleList))))))

(define pythagorean-triangle?
	(lambda (triple)
		(= (+ (* (car triple) (car triple)) (* (cadr triple) (cadr triple))) (* (caddr triple) (caddr triple)))))


(define filter-pythagorean
  	(lambda (tripleList)
		(if (null? tripleList)
		    '()
		    (if (pythagorean-triangle? (car tripleList))
		        (cons (car tripleList) (filter-pythagorean (cdr tripleList)))
			(filter-pythagorean (cdr tripleList))))))


(define get-area
	(lambda (triple)
	  	(/ (* (car triple) (cadr triple)) 2)))

(define insert-by-area
  	(lambda (triple sortedList)
	  	(if (null? sortedList)
		    (list triple)
		    (if (<= (get-area triple) (get-area (car sortedList)))
		      	(cons triple sortedList)
			(cons (car sortedList) (insert-by-area triple (cdr sortedList)))))))


(define sort-area
	(lambda (tripleList)
		(if (null? tripleList)
                    '()
		    (insert-by-area (car tripleList) (sort-area (cdr tripleList))))))


(define main-procedure
  (lambda (tripleList)
    (if (or (null? tripleList) (not (list? tripleList)))
        (error "ERROR305: the input should be a list full of triples")
        (if (check-triple? tripleList)
            (sort-area (filter-pythagorean (filter-triangle
              (sort-all-triples tripleList))))
            (error "ERROR305: the input should be a list full of triples")))))