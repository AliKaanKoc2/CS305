(define s4
   (lambda (e)
      (cond
	( (number? e) e)
	( (not (list? e))           (error "s4: cannot evaluate -->" e))
        ( (> 2 (length e))          (error "s4: cannot evaluate -->" e))
	( (not (eq? (car e) '+))    (error "s4: cannot evaluate -->" e))
	( else (apply + (map s4 (cdr e))))
      )
   )
)
