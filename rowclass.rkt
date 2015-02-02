#lang racket

(module rowclass racket 
  (require db)
  
  (provide row-object%)
  (provide row-object-interface)
  (provide make-from)
  
  ; Class Interface
  (define row-object-interface (interface () get-attributes get-table-name))
  
  ; Populate a list of instances of a given class 
  ; (TODO: horrible little hack for default where which 
  ; pushes the work to the database)
  ; -> Void
  (define (make-from class dbc [where "1=1"]) 
    (let* ([class-ref (new class)]
           [query (~a (build-select (send class-ref get-attributes)) " FROM " (send class-ref get-table-name) " WHERE " where)])
      
      (map (lambda (row) 
             (apply make-object (append (list class) (vector->list row))))
           (query-rows dbc query))))
  
  ; Build a select statement for Mysql
  ; -> String
  (define (build-select attributes)
    (string-append "SELECT " (string-join attributes ",")))
  
  ; The Row Object definition to be extended
  ; by classes
  (define row-object% 
    (class object%
      
      ; Persist a single attribute
      ; -> Void
      (define/public (save-attr! dbc attr)
        (let ([query (~a "UPDATE " (send this get-table-name) " SET " attr "=?"  " WHERE id=" (get-field id this))])
          (query-exec dbc query (dynamic-get-field (string->symbol attr) this))))
      
      ; Persist all attributes
      ; -> Void
      (define/public (save! dbc)
        (let ([query (~a "UPDATE " (send this get-table-name) " SET " (send this build-update-references) " WHERE id=" (get-field id this))])
          (apply query-exec (append (list dbc query) (send this build-update-values)))))
      
      
      ; Initial insert into the database
      ; -> Void
      (define/public (create! dbc) 
        (let ([query (~a "INSERT INTO " (send this get-table-name) " SET " (send this build-update-references))])
          (apply query-exec (append (list dbc query) (send this build-update-values)))))
      
      ; Create a string for mysql with the list of attributes to be updated
      ; -> String
      (define/public (build-update-references)
        (string-join 
         (map (lambda (attr) 
                (string-append attr "=?")) 
              (send this get-attributes))
         ","))
      
      ; Build a list of values for all attributes
      ; -> List
      (define/public (build-update-values)
        (map (lambda (attr) 
               (dynamic-get-field (string->symbol attr) this)) 
             (send this get-attributes)))
      
      (super-new))))