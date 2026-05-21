(define error-value?
  (lambda (x)
    (eq? x 'ERROR)))
 
(define get-operator
  (lambda (op)
    (cond
      ((eq? op '+) +)
      ((eq? op '-) -)
      ((eq? op '*) *)
      ((eq? op '/) /)
      (else 'ERROR))))
 
(define get-value
  (lambda (var env)
    (cond
      ((null? env) 'ERROR)
      ((eq? var (caar env)) (cdar env))
      (else (get-value var (cdr env))))))
 
(define extend-env
  (lambda (var val old-env)
    (cons (cons var val) old-env)))
 
(define has-error?
  (lambda (lst)
    (cond
      ((null? lst) #f)
      ((error-value? (car lst)) #t)
      (else (has-error? (cdr lst))))))
 
(define define-expr?
  (lambda (e)
    (and (list? e)
         (= (length e) 3)
         (eq? (car e) 'define)
         (symbol? (cadr e)))))
 
(define eval-if 
  (lambda (e env)
    (if (not (= (length e) 4))
        'ERROR
        (let ((result (s7 (cadr e) env)))
          (if (error-value? result)
              'ERROR
              (if (= result 0)
                  (s7 (cadddr e) env)
                  (s7 (caddr e) env)))))))
        
(define cond-helper
  (lambda (clauses env)
    (cond
      ((null? clauses) 'ERROR)
      ((eq? (caar clauses) 'else) (s7 (cadar clauses) env))
      (else
        (let ((test-val (s7 (caar clauses) env)))
          (cond
            ((error-value? test-val) 'ERROR)
            ((= test-val 0) (cond-helper (cdr clauses) env))
            (else                  (s7 (cadar clauses) env))))))))

(define eval-cond
  (lambda (e env)
    (cond-helper (cadr e) env)))

; ---- let, let* implementation ----

(define valid-bindings?
  (lambda (bindings)
    (cond
      ((null? bindings) #t)
      ((not (and (list? (car bindings))
                 (= (length (car bindings)) 2)
                 (symbol? (caar bindings))))
       #f)
      (else (valid-bindings? (cdr bindings))))))

(define name-in?
  (lambda (name bindings)
    (cond
      ((null? bindings) #f)
      ((eq? name (caar bindings)) #t)
      (else (name-in? name (cdr bindings))))))

(define duplicate?
  (lambda (bindings)
    (cond
      ((null? bindings) #f)
      ((name-in? (caar bindings) (cdr bindings)) #t)
      (else (duplicate? (cdr bindings))))))

(define make-let-env
  (lambda (bindings outer-env)
    (if (null? bindings)
        outer-env
        (extend-env (caar bindings)                             ; name                         
                (s7 (cadar bindings) outer-env)                 ; value of the name
                (make-let-env (cdr bindings) outer-env))))) 

(define eval-let  
  (lambda (e env)
    (cond
      ((not (valid-bindings? (cadr e))) 'ERROR)
      ((duplicate? (cadr e))            'ERROR)
      (else (s7 (caddr e) (make-let-env (cadr e) env))))))

(define make-let*-env
  (lambda (bindings outer-env)
    (if (null? bindings)
        outer-env
        (make-let*-env (cdr bindings) 
        (extend-env (caar bindings)                                 ; name                         
                    (s7 (cadar bindings) outer-env)                 ; value of the name
                    outer-env))))) 

(define eval-let*
  (lambda (e env)
    (cond
      ((not (valid-bindings? (cadr e))) 'ERROR)
      (else (s7 (caddr e) (make-let*-env (cadr e) env))))))

(define s7
  (lambda (e env)
    (cond
      ((number? e) e)
      ((symbol? e) (get-value e env))
      ((not (list? e)) 'ERROR)
      ((not (> (length e) 1)) 'ERROR)
      ((eq? (car e) 'if)   (eval-if   e env))
      ((eq? (car e) 'cond) (eval-cond e env))
      ((eq? (car e) 'let)  (eval-let  e env))
      ((eq? (car e) 'let*) (eval-let* e env))
      (else
       (let ((operator (get-operator (car e))))
         (if (error-value? operator)
             'ERROR
             (let ((operands (map (lambda (x) (s7 x env)) (cdr e))))
               (if (has-error? operands)
                   'ERROR
                   (apply operator operands)))))))))
 
(define repl
  (lambda (env)
    (display "cs305> ")
    (let ((expr (read)))
      (cond
        ((define-expr? expr)
         (let ((val (s7 (caddr expr) env)))
           (display "cs305: ")
           (if (error-value? val)
               (let* ((d1 (display "ERROR")) (d2 (newline))) (repl env))
               (let* ((d1 (display (cadr expr))) (d2 (newline)))
                 (repl (extend-env (cadr expr) val env))))))

                
        (else
         (let ((val (s7 expr env)))
           (display "cs305: ")
           (if (error-value? val)
               (display "ERROR")
               (display val))
           (newline)
           (repl env)))))))
 
(define cs305
  (lambda ()
    (repl '())))