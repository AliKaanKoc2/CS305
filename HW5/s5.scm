(define get-operator 
  (lambda (opsymbol)
    (cond 
      ( (eq? opsymbol '+) +)
      ( (eq? opsymbol '*) *)
      ( (eq? opsymbol '-) -)
      ( (eq? opsymbol '/) /)
      ( else (error "s5: unknown operator -->" opsymbol))
    ) 
  )
)

(define s5
   (lambda (e)
      (cond
	( (number? e) e)
	( (not (list? e))    (error "s5: cannot evaluate -->" e))
        ( (> 2 (length e))   (error "s5: cannot evaluate -->" e))
	( else 
	  (let (
		 (operator (get-operator (car e)))
		 (operands (map s5 (cdr e)))
	       )
	       (apply operator operands)
	  )
      )
   )
)
