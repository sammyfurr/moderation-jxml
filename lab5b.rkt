#lang racket
(require eopl)
(require racket/string)

(define the-lexical-spec
  '((whitespace (whitespace) skip)
    (jnumber ((or (concat "-" digit)
                 digit)
             (arbno digit)
             (or (concat "." digit (arbno digit))
                 (arbno digit))
             (or (concat (or "e" "E")
                         (or "-" "+")
                         (arbno digit))
                 (arbno digit))) number)
    (jstring ("\""
              (arbno ;;any
               (or
                      (concat "\\" "\"")
                      (concat "\\" "\\")
                      (concat "\\" "/")
                      (concat "\\" "b")
                      (concat "\\" "f")
                      (concat "\\" "r")
                      (concat "\\" "n")
                      (concat "\\" "t")
                      letter
                      digit
                      whitespace
                      ":"
                      ","
                      "."
                      "-")
                     ;;  (not (concat "\\" "\""))
                     ;;  (not (concat "\\" "\\"))
                     ;;  (not (concat "\\" "/"))
                     ;;  (not (concat "\\" "b"))
                     ;;  (not (concat "\\" "f"))
                     ;;  (not (concat "\\" "r"))
                     ;;  (not (concat "\\" "n"))
                     ;;  (not (concat "\\" "t")))
                     )
              "\"") string)
    (jtrue ("true") symbol)
    (jfalse ("false") symbol)
    (jnull ("null") symbol)))

(define the-grammar
  '((json ("[" (separated-list json ",") "]") jlist)
    (json ("{" (separated-list jstring ":" json ",") "}") jobj)
    (json (jnumber) numval)
    (json (jstring) stringval)
    (json (jtrue) trueval)
    (json (jfalse) falseval)
    (json (jnull) nullval)
    ))

(define-datatype json json?
  (jlist (j (list-of json?)))
  (jobj (n (list-of string?)) (v (list-of json?)))
  (numval (num number?))
  (stringval (s string?))
  (trueval (b symbol?))
  (falseval (b symbol?))
  (nullval (n symbol?)))

(define just-scan
    (sllgen:make-string-scanner the-lexical-spec the-grammar))

(define scan&parse
  (sllgen:make-string-parser the-lexical-spec the-grammar))

(define (camel-case j)
  (let ((r (regexp-match #px" \\w" j)))
    (if r
        (camel-case (string-replace j (car r) (string-upcase (substring (car r) 1))))
        j)))

(define (jstring-to-tag j f l)
  (camel-case (string-downcase (substring j f (- (string-length j) l)))))

(define (jstring-to-content j)
  (if (equal? (substring j 0 1) "\"")
      (substring j 1 (- (string-length j) 1))
      j))

(define (xml-obj-format n v)
  (if (null? n)
      ""
      (string-append
       (format "<~a>~a</~a>"
               (jstring-to-tag (car n) 1 1)
               (jstring-to-content (json->xml (car v) (car n)))
               (jstring-to-tag (car n) 1 1))
       (xml-obj-format (cdr n) (cdr v)))))

(define (xml-list-format l prev)
  (define (list-to-string l)
    (if (null? l)
        ""
        (string-append (car l) (list-to-string (cdr l)))))
  (list-to-string 
   (map (lambda (l)
          (format "<~a>~a</~a>"
                  (jstring-to-tag prev 1 2)
                  (json->xml l prev)
                  (jstring-to-tag prev 1 2))) l)))

(define (json->xml exp prev)
  (cases json exp 
         (jlist (j)
                (xml-list-format j prev))
         (jobj (n v) 
               (xml-obj-format n v))
         (numval (num) num)
         (stringval (s) s)
         (trueval (b) 'true)
         (falseval (b) 'false)
         (nullval (b) 'null)
         (else (error "not proper xml"))))

(define sammy
  "{\"Person\" : {
     \"Last Name\" : \"Furr\", 
     \"First Name\" : \"Samuel\",
     \"Formal Title\" : \"Mr.\",
     \"Address\" : {
      \"Street\" : \"15 Warren\",
      \"City\" : \"Kingston\",
      \"State\" : \"New York\",
      \"Zip\" : \"12401\"
      },
     \"Phone Numbers\" : [
      {\"type\" : \"home\", \"number\" : \"845 777 8888\"},
      {\"type\" : \"cell\", \"number\" : \"123 456 7890\"}
     ]
     }
    }")
(display (json->xml (scan&parse sammy) '()))
(newline)
(newline)

