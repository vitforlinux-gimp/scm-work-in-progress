;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; Revision: January 2012 - added Hungarian translation (thanks to petrikp)
;           March 2012   - added Polish (thanks to Mario)
;           January 2013 - added Russian translation (thanks to Leonid)
;           January 2013 - Serbian, Croatian, Slovenian, Macedonian (thanks to Skynet)
;           March 2013   - Swedish (thanks to Ullis)
;           April 2015   - Catalan (thanks to Xavier)
;           October 2023 - Ukrainian (PixLab)

; 'layout'
;   0 = Allow week 6
;   1 = Force week 6
;   2 = Wrap w6 to w1
;   3 = Wrap w6 to w5

; 2020/12/22 MrQ: fix up for Gimp 2.10
; gimp-image-get-item-position -> gimp-image-get-item-position
; gimp-image-lower-layer -> gimp-image-lower-item
; gimp-drawable-get-visible -> gimp-item-get-visible
; gimp-item-set-visible -> gimp-item-set-visible
; gimp-item-set-name -> gimp-item-set-name
; gimp-edit-named-paste-as-new -> gimp-edit-named-paste-as-new-image
;;  (gimp-rect-select image x y width height operation feather feather-radius) ->  (gimp-image-select-rectangle image operation x y width height)
;;  (gimp-selection-load channel) -> (gimp-image-select-item image operation=[CHANNEL-OP-ADD (0), CHANNEL-OP-SUBTRACT (1), CHANNEL-OP-REPLACE (2), CHANNEL-OP-INTERSECT (3)] item)
;; (gimp-image-insert-layer image layer position 0) -> (gimp-image-insert-layer image layer parent position)

; 2023/10/06 -> on GIMP 2.10.34
; Last modification PixLab
; Added Translation: Ukrainian (PixLab) 
; Increase Years up to 2150 
; Change labels to be a lot more descriptive
; Change default values, added sliders

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-base-type)) (define gimp-image-get-base-type gimp-image-base-type)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))
(cond ((not (defined? 'gimp-text-get-extents-fontname)) (define (gimp-text-get-extents-fontname efn1 efn2 PIXELS efn3) (gimp-text-get-extents-font efn1 efn2 efn3))))

(cond ((not (defined? 'gimp-image-get-selected-drawables)) (define gimp-image-get-selected-drawables gimp-image-get-active-drawable)))
(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image 1 (vector drawable)))))

(define sg-calendar-languages '("English"       "German"          "Italian"         "Spanish"   
                                "French"        "Hungarian"       "Polish"          "Ukrainian" 
                                "Russian"       "Serbian latin"   "Serbian cyrilic" "Croatian"  
                                "Slovenian"     "Macedonian"      "Swedish"         "Catalan") )

;; Each of the following translations are comprised of a list of:
;;   (months) (days) (day-abbreviations)
;; If the day-abbreviations is #f then the letters-in-day parameter is
;; used to generate the abbreviation from the full day name.
;; 
;; Languages appear in the order that they were contributed.
;;
(define sg-calendar-translations
  '(( ; "English" 
         ("January"      "February"     "March"       "April" 
          "May"          "June"         "July"        "August"
          "September"    "October"      "November"    "December")
         ("Monday"       "Tuesday"      "Wednesday"   "Thursday"
          "Friday"       "Saturday"     "Sunday")
          #f)
    ( ; "German" 
        ("Januar"        "Februar"      "März"        "April"
         "Mai"           "Juni"         "Juli"        "August" 
         "September"     "Oktober"      "November"    "Dezember")
        ("Montag"        "Dienstag"     "Mittwoch"    "Donnerstag" 
         "Freitag"       "Samstag"      "Sonntag")
        #f)
    ( ; "Italian" 
        ("Gennaio"       "Febbraio"     "Marzo"       "Aprile" 
         "Maggio"        "Giugno"       "Luglio"      "Agosto" 
         "Settembre"     "Ottobre"      "Novembre"    "Dicembre")
        ("Lunedi"        "Martedi"      "Mercoledi"   "Giovedi" 
         "Venerdi"       "Sabato"       "Domenica")
        #f)
    ( ; "Spanish"
        ("Enero"         "Febrero"      "Marzo"       "Abril" 
         "Mayo"          "Junio"        "Julio"       "Agosto" 
         "Septiembre"    "Octubre"      "Noviembre"   "Diciembre")
        ("Lunes"         "Martes"       "Miercoles"   "Jueves" 
         "Viernes"       "Sabado"       "Domingo")
        #f)
    ( ; "French"
        ("Janvier"       "Février"      "Mars"        "Avril"
         "Mai"           "Juin"         "Juillet"     "Août" 
         "Septembre"     "Octobre"      "Novembre"    "Décembre")
        ("Lundi"         "Mardi"        "Mercredi"    "Jeudi" 
         "Vendredi"      "Samedi"       "Dimanche")
        #f)
    ( ; "Hungarian"
        ("Január"        "Február"      "Március"     "Április" 
         "Május"         "Június"       "Július"      "Augusztus" 
         "Szeptember"    "Október"      "November"    "December")
        ("vasárnap"      "hétfő"        "kedd"        "szerda" 
         "csütörtök"     "péntek"       "szombat")
        #f)
    ( ; "Polish"
        ("Styczeń"       "Luty"         "Marzec"      "Kwiecień" 
         "Maj"           "Czerwiec"     "Lipiec"      "Sierpień" 
         "Wrzesień"      "Październik"  "Listopad"    "Grudzień")
        ("Poniedziałek"  "Wtorek"       "Środa"       "Czwartek" 
         "Piątek"        "Sobota"       "Niedziela")
        #f)
    (  ; "Ukrainian"
         ("Січень"      "Лютий"       "Березень"    "Квітень" 
          "Травень"     "Червень"     "Липень"      "Серпень" 
           "Вересень"   "Жовтень"     "Листопад"    "Грудень" )
          ("Понеділок"  "Вівторок"    "Середа"      "Четвер" 
           "П'ятниця"   "Субота"      "Неділя" )
         #f)
    ( ; "Russian"
        ("Январь"        "Февраль"      "Март"        "Апрель" 
         "Май"           "Июнь"         "Июль"        "Август" 
         "Сентябрь"      "Октябрь"      "Ноябрь"      "Декабрь")
        ("Понедельник"   "Вторник"      "Среда"       "Четверг"
         "Пятница"       "Суббота"      "Воскресенье")
        #f)
    ( ; "Serbian latin"
        ("Januar"        "Februar"      "Mart"        "April"
         "Maj"           "Jun"          "Jul"         "Avgust"
         "Septembar"     "Oktobar"      "Novembar"    "Decembar")
        ("Ponedeljak"    "Utorak"       "Sreda"       "Četvrtak" 
         "Petak"         "Subota"       "Nedelja")
        #f)
    ( ; "Serbian cyrilic"
        ("Јануар"        "Фебруар"      "Март"        "Април"
         "Мај"           "Јун"          "Јул"         "Август"
         "Септембар"     "Октобар"      "Новембар"    "Децембар")
        ("Понедељак"     "Уторак"       "Среда"       "Четвртак"
         "Петак"         "Субота"       "Недеља")
        #f)
    ( ; "Croatian"
        ("Siječanj"      "Veljača"      "Ožujak"      "Travanj"
         "Svibanj"       "Lipanj"       "Srpanj"      "Kolovoz"
         "Rujan"         "Listopad"     "Studeni"     "Prosinac")
        ("Ponedjeljak"   "Utorak"       "Srijeda"     "Četvrtak" 
         "Petak"         "Subota"       "Nedjelja")
        #f)
    ( ; "Slovenian"
        ("Januar"        "Februar"      "Marec"       "April"
         "Maj"           "Junij"        "Julij"       "Avgust"
         "September"     "Oktober"      "November"    "December")
        ("Ponedeljek"    "Torek"        "Sreda"       "Četrtek" 
         "Petek"         "Sobota"       "Nedelja")
        #f)
    ( ; "Macedonian"
        ("Коложег"       "Сечко"        "Цутар"       "Тревен"
         "Косар"         "Жетвар"       "Златец"      "Житар"
         "Гроздобер"     "Листопад"     "Студен"      "Снежник")
        ("Понеделник"    "Вторник"      "Среда"       "Четврток"
         "Петок"         "Сабота"       "Недела")
        #f)
    ( ; "Swedish"
        ("Januari"       "Februari"     "Mars"        "April" 
         "Maj"           "Juni"         "Juli"        "Augusti" 
         "September"     "Oktober"      "November"    "December")
        ("Måndag"        "Tisdag"       "Onsdag"      "Torsdag"
         "Fredag"        "Lördag"       "Söndag")
        #f)
    ( ; "Catalan"
        ("Gener"         "Febrer"       "Març"        "Abril" 
         "Maig"          "Juny"         "Juliol"      "Agost" 
         "Setembre"      "Octubre"      "Novembre"    "Desembre")
        ("Dilluns"       "Dimarts"      "Dimecres"    "Dijous"
         "Divendres"     "Dissabte"     "Diumenge")
        ("DL" "DT" "DC" "DJ" "DV" "DS" "DG"))
    ))

;; Perform a crude search for the largest font that will fit within
;; the cell (this algorithm could be better!)
;
(define (sg-calendar-calc-fontsize text font fontsize% width height)
  (let* ((fontsize 6) ;; minimum possible fontsize
         (extents nil)
         (last-extents nil)
         (last-fontsize 3)
         (adjust 2) )
    (set! extents (gimp-text-get-extents-fontname text fontsize PIXELS font))
    (set! width (* width fontsize% 0.01))
    (set! height (* height fontsize% 0.01))
    (while (and (<> last-fontsize fontsize) (not (equal? extents last-extents)))
      (if (or (> (car extents) width) (> (cadr extents) height))
        (begin 
          (set! fontsize last-fontsize)
          (set! adjust (+ (* (- adjust 1) 0.5) 1)) )
        (begin
          (set! last-extents extents)
          (set! last-fontsize fontsize) ) )
      (set! fontsize (truncate (* fontsize adjust)))
      (set! extents (gimp-text-get-extents-fontname text fontsize PIXELS font)) )
    (max fontsize 6) ) )
  

(define (script-fu-sg-calendar image drawable lang month year sunday? 
                               letters-in-day layout text-font number-font 
                               fontsize% justify? border border-color gravity)
  ;; 'leap-year' returns one if given year is a leap year, else zero
  ;
  (define (leap-year yy) 
    (if (= (modulo yy 4) 0)
      (if  (or (> (modulo yy 100) 0) (= (modulo yy 400) 0))
        1
        0 )
      0 ) )

  ;; Given a Gregorian date, the following computes the number of days that have elapsed since
  ;; March 1st, 0000. This date is chosen as an absolute reference
  ;; so that leap days occur at the "end of the year" (simplifying 
  ;; calculations). For lack of a better name, I shall call this a
  ;; "martius date" after the Roman word for the month of March.
  ;
  (define (gregorian->martius yy mm dd)
    (set! mm (modulo (+ mm 9) 12))
    (set! yy (- yy (truncate (/ mm 10))))
    (inexact->exact (+ (trunc (* 365 yy)) 
                       (trunc (/ yy 4)) 
                       (- (trunc (/ yy 100))) 
                       (trunc (/ yy 400)) 
                       (round (* mm 30.6)) dd -1 )) )

  ;; Given a Gregorian date, return the day of the week (0=Sunday, 1=Monday,...)
  ;
  (define (day-of-week yy mm dd)
    (modulo (+ (gregorian->martius yy mm dd) 3) 7) )

  ;; The following converts from an absolute number of days since 
  ;; March 1st, 0000 (i.e., a "martius date") to a Gregorian date
  ;; A list is returned containing '(year month day)
  ;
  (define (martius->gregorian mdays)
    (let* ((yy 0)
           (mm 0)
           (mi 0)
           (dd 0) )
      (set! yy (truncate (+ (/ mdays 365.2425) (/ 1.4780 365.2425))))
      (set! dd (- mdays (truncate (* yy 365.2425))))
      (when (< dd 0)
        (set! yy (- yy 1))
        (set! dd (- mdays (truncate (* yy 365.2425)))) )
      (set! mi (inexact->exact (truncate (/ (+ 0.52 dd) 30.60))))
      (set! mm (+ (modulo (+ mi 2) 12) 1))
      (set! yy (+ yy (truncate (/ (+ mi 2) 12))))
      (set! dd (+ (- dd (round (* mi 30.6))) 1))
      (list yy mm dd) ) )

  ;; Create a list of floats evenly distributed between start and end
  ;
  (define (algebraic-prog start end elements)
    (let ((elements (inexact->exact elements))
          (incr (if (zero? start)
                  (/ end (- elements 1))
                  (/ (- (/ end start) 1) (- elements 1)) ) ) )
      (let 
        loop ((cnt (- elements 1))
              (lis (if (zero? start)
                     '(0)
                     '(1) ) ) )
        (if (zero? cnt)
          (if (zero? start)
            (reverse lis)
            (map * (reverse lis) (make-list elements start)) )
          (loop (- cnt 1) (cons (+ (car lis) incr) lis)) ) ) ) )

  ;; Create a frame layer for a cell
  ;
  (define (create-cell-frame x y w h)
    (let* ((frame-layer (car (gimp-layer-new image 
                                             w h 
                                             RGBA-IMAGE "Cell #1" 
                                             100 LAYER-MODE-NORMAL-LEGACY ))) )
      (gimp-drawable-fill frame-layer FILL-TRANSPARENT)
      (gimp-image-insert-layer image frame-layer 0 0)
      (gimp-layer-set-offsets frame-layer x y)
      (gimp-image-select-rectangle image  CHANNEL-OP-REPLACE (+ x border) (+ y border) (- w (* 2 border)) (- h (* 2 border)))
      (gimp-selection-invert image)
      (gimp-context-set-background border-color)
      (gimp-drawable-edit-fill frame-layer FILL-BACKGROUND)
      (gimp-selection-none image)
      frame-layer ) )
  
  ;; Create the text layer for a cell-frame
  ;
  (define (create-cell-text text font fontsize gravity frame-layer)
    (let* ((text-layer (car (gimp-text-fontname image -1 
                                                0 0 
                                                text (* 2 border) 
                                                TRUE fontsize 
                                                PIXELS font )))
           (x-align 0)
           (y-align 0) )
      (if (or (= gravity 0) (= gravity 1) (= gravity 2))
        (set! y-align -1)
        (when (or (= gravity 6) (= gravity 7) (= gravity 8))
          (set! y-align 1) ) )
      (if (or (= gravity 0) (= gravity 3) (= gravity 6))
        (set! x-align -1)
        (when (or (= gravity 2) (= gravity 5) (= gravity 8))
          (set! x-align 1) ) )
      (fu-align-layers frame-layer text-layer x-align y-align)
      text-layer
      )
    )

  ;; align layer(s) with a base-layer (layers can be either a single layer or a list of layers)
  ;; vert-align and horiz-align
  ;;  -1 = LEFT, 0 = CENTER, 1 = RIGHT
  ;
  (define (fu-align-layers base-layer layers vert-align horiz-align)
    (let* ((anchor-x (car (gimp-drawable-get-offsets base-layer)))
           (anchor-y (cadr (gimp-drawable-get-offsets base-layer)))
           (width (car (gimp-drawable-get-width base-layer)))
           (height (car (gimp-drawable-get-height base-layer))) )
      (unless (pair? layers)
        (set! layers (list layers)) )
      (if (>= vert-align 0)
        (if (= vert-align 0)
          (set! anchor-x (+ anchor-x (/ width 2)))
          (set! anchor-x (+ anchor-x width)) ) )
      (if (>= horiz-align 0)
        (if (= horiz-align 0)
          (set! anchor-y (+ anchor-y (/ height 2)))
          (set! anchor-y (+ anchor-y height)) ) )
      (while (pair? layers)
        (let* (
            (layer (car layers))
            (ref-x (car (gimp-drawable-get-offsets layer)))
            (ref-y (cadr (gimp-drawable-get-offsets layer)))
            (orig-x ref-x)
            (orig-y ref-y)
            (offset-x 0)
            (offset-y 0)
            )
          (set! width (car (gimp-drawable-get-width layer)))
          (set! height (car (gimp-drawable-get-height layer)))
          (if (>= vert-align 0)
            (if (= vert-align 0)
              (set! ref-x (+ ref-x (/ width 2)))
              (set! ref-x (+ ref-x width))
              )
            )
          (if (>= horiz-align 0)
            (if (= horiz-align 0)
              (set! ref-y (+ ref-y (/ height 2)))
              (set! ref-y (+ ref-y height))
              )
            )
          (set! offset-x (+ orig-x (- anchor-x ref-x)))
          (set! offset-y (+ orig-y (- anchor-y ref-y)))
          (gimp-layer-set-offsets layer offset-x offset-y)
          )
        (set! layers (cdr layers))
        )
      )
    )
  ;; return a list of visible layers
  ;
  (define (fu-get-visible-layers image)
    (let loop ((layers (vector->list (cadr (gimp-image-get-layers image))))
               (viewables nil) )
      (if (null? layers)
        (if (null? viewables)
          '()
          (reverse viewables) )
        (loop (cdr layers)
              (if (zero? (car (gimp-item-get-visible (car layers))))
                viewables
                (cons (car layers) viewables) ) ) ) ) )
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main definition starts here ;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (let* ((bg-layer 0)
         (x1 0)
         (x2 0)
         (y1 0)
         (y2 0)
         (X's '())
         (Y's '()) 
         (x's '())
         (y's '())
         (row 0)
         (total-rows 6)
         (col 0)
         (text-fontsize 6)
         (number-fontsize 6)
         (firstday (day-of-week year (+ month 1) 1))
         (days-in-month (vector 31 (+ 28 (leap-year year)) 31 30 31 30 31 31 30 31 30 31))
         (i 0)
         (frames nil)
         (frame-layer 0)
         (cal-days nil)
         (dates-layer 0)
         (visibles '())
         (buffer "")
         (layers nil)
         (orig-bg (car (gimp-context-get-background)))
         (orig-sel 0)
         (months (list->vector (car (list-ref sg-calendar-translations lang))))
         (weekday-strings (list->vector (cond  
                                          ((caddr (list-ref sg-calendar-translations lang)))
                                          (else
                                             (map (lambda (x) 
                                                    (substring x 
                                                               0 
                                                               (min (+ letters-in-day 1)
                                                                    (string-length x))))
                                                  (cadr (list-ref sg-calendar-translations
                                                                  lang)))))))
         )
    (gimp-context-push)
    (gimp-image-undo-group-start image)
	
    (if (not (= RGB (car (gimp-image-get-base-type image))))
			 (gimp-image-convert-rgb image))

    (set! orig-sel (car (gimp-selection-save image)))
    	        	(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
	(set! buffer (car (gimp-edit-named-copy drawable "buffer")))
    (set! buffer (car (gimp-edit-named-copy 1 (vector drawable) "buffer"))))
    (set! bg-layer (car (gimp-edit-named-paste drawable buffer FALSE)))
    (gimp-floating-sel-to-layer bg-layer)
    (gimp-buffer-delete buffer)
    (let loop ((pos (- (car (gimp-image-get-item-position image drawable)) 1)))
      (if (zero? pos)
       ; #t
        (begin 
          (gimp-image-lower-item image bg-layer)
          (loop (- pos 1)) )))

    (set! x1 (+ border (car (gimp-drawable-get-offsets bg-layer))))
    (set! x2 (- (+ x1 (car (gimp-drawable-get-width bg-layer))) (* 2 border)))
    (set! y1 (+ border (cadr (gimp-drawable-get-offsets bg-layer))))
    (set! y2 (- (+ y1 (car (gimp-drawable-get-height bg-layer))) (* 2 border)))
    (set! X's (map round (algebraic-prog x1 x2 8)))
    (set! Y's (map round (algebraic-prog y1 y2 7))) ;; 1 row for header + five rows for weeks 
    (set! x's X's)
    (set! y's Y's)
    (set! visibles (fu-get-visible-layers image))
    (unless (= sunday? TRUE)
       (set! firstday (modulo (- firstday 1) 7))
      )
    (when (or (= layout 1) (and (= layout 0) (> (+ firstday (vector-ref days-in-month month)) 35)))
      (set! Y's (map round (algebraic-prog y1 y2 8))) ;; 1 row for header + six rows for weeks 
      (set! y's Y's)
      (set! total-rows 7)
      )
    ;; Add header row with day labels
    ;; Determine fontsize for days
    (set! text-fontsize (apply min (map (lambda (text)
                               (sg-calendar-calc-fontsize text 
                                              text-font 
                                              80 
                                              (- (cadr X's) (car X's) (* 2 border)) 
                                              (- (cadr Y's) (car Y's) (* 2 border)) ) )
                             (vector->list weekday-strings) ) ) )
    (gimp-progress-update (/ 1 (* total-rows 7)))
    (set! x's X's)
    (while (< i 7)
      (set! frames (cons (create-cell-frame (car x's) ; cell upper-left x
                                             (car y's) ; cell upper-left y
                                             (round (- (cadr x's) (car x's))) ; width
                                             (round (- (cadr y's) (car y's)))) ; height
                                             frames))
      (set! cal-days (cons (create-cell-text (vector-ref weekday-strings (modulo (- i sunday? ) 7))
                                             text-font
                                             text-fontsize 
                                             7 ;; center text in cell
                                             (car frames)) 
                                             cal-days ))
      (set! i (+ i 1))
      (gimp-progress-update (/ (+ i 1) (* total-rows 7)))
      (set! x's (cdr x's))
      )
    (set! row (+ row 1))
    (set! y's (cdr y's))
    (set! x's X's)
    (set! i 0)

    ;; Determine fontsize for numbers
    (if (< fontsize% 80)
      (set! number-fontsize (sg-calendar-calc-fontsize "30" number-font fontsize% (- (cadr X's) (car X's) (* 4 border))  (- (cadr Y's) (car Y's) (* 4 border))))
      (set! number-fontsize (sg-calendar-calc-fontsize "30" number-font fontsize% (- (cadr X's) (car X's) (* 2 border))  (- (cadr Y's) (car Y's) (* 2 border))))
      )
    ;; create grid of "cells"
    ;; grid contains cells for the days
    ;; Each cell has a transparent layer with optional border and
    ;; valid days have a text layer holding the day number. 
    ;; the day of the month is "0" if cell is not in month
    ;; 
    (if (= layout 2) 
      (while (> (- (+ firstday (vector-ref days-in-month month)) i) 35)
        (set! frames (cons (create-cell-frame (car x's) ; cell upper-left x
                                               (car y's) ; cell upper-left y
                                               (round (- (cadr x's) (car x's))) ; width
                                               (round (- (cadr y's) (car y's)))) ; height
                                               frames))
        (let* (
            (date (+ (- 36 firstday) i))
            (date-str (number->string date))
            )
          (set! cal-days (cons (create-cell-text date-str number-font number-fontsize gravity (car frames)) cal-days))
          )
        (set! i (+ i 1))
        (gimp-progress-update (/ (+ i 8) (* total-rows 7)))
        (set! x's (cdr x's))
        (set! col (+ col 1))
        )
      )
    (let* (
        (bindle-x (car x's))
        )
      (while (< i firstday)
        (set! i (+ i 1))
        (gimp-progress-update (/ (+ i 8) (* total-rows 7)))
        (set! x's (cdr x's))
        )
      (unless (= i col)
        (set! frames (cons (create-cell-frame bindle-x ; cell upper-left x
                                               (car y's) ; cell upper-left y
                                               (round (- (car x's) bindle-x)) ; width
                                               (round (- (cadr y's) (car y's)))) ; height
                                               frames))
        (set! col i)
        )
      )
    (while (< row total-rows)
      (while (and (< col 7) (< i (+ (vector-ref days-in-month month) firstday)))
        (set! frames (cons (create-cell-frame (car x's) ; cell upper-left x
                                               (car y's) ; cell upper-left y
                                               (round (- (cadr x's) (car x's))) ; width
                                               (round (- (cadr y's) (car y's)))) ; height
                                               frames))
        (let* (
            (date (+ (- i firstday) 1))
            (date-str (if (and (= justify? TRUE) (< date 10))
                          (string-append " " (number->string date))
                          (number->string date)))
            (double-day 0)
            (cal-day 0)
            )
          (set! cal-day (create-cell-text date-str number-font number-fontsize gravity (car frames)))
          (if (= layout 3) ;; if needed, squeeze two dates into text cell (e.g., 23/30, 24/31)
            (when (and (> (+ firstday (vector-ref days-in-month month)) 35) 
                       (= row 5)
                       (<= (+ date 7) (vector-ref days-in-month month)))

              (gimp-drawable-edit-clear cal-day)
              (set! double-day (create-cell-text date-str number-font (* number-fontsize 0.5) 0 cal-day))
              (set! cal-day (car (gimp-image-merge-down image double-day EXPAND-AS-NECESSARY)))
              (set! double-day (create-cell-text (number->string (+ date 7)) number-font (* number-fontsize 0.5) 8 cal-day))
              (set! cal-day (car (gimp-image-merge-down image double-day EXPAND-AS-NECESSARY)))
              )
            )
          (set! cal-days (cons cal-day cal-days))
          )
        (set! i (+ i 1))
        (gimp-progress-update (/ (+ i 8) (* total-rows 7)))
        (set! x's (cdr x's))
        (set! col (+ col 1))
        )
      (unless (or (< i (+ (vector-ref days-in-month month) firstday)) (= col 7))
        (let* (
            (bindle-x (car x's))
            )
          (while (< col 7)
            (set! i (+ i 1))
            (set! x's (cdr x's))
            (set! col (+ col 1))
            )
          (set! frames (cons (create-cell-frame bindle-x ; cell upper-left x
                                                 (car y's) ; cell upper-left y
                                                 (round (- (car x's) bindle-x)) ; width
                                                 (round (- (cadr y's) (car y's)))) ; height
                                                 frames))
          (set! i (+ i 1))
          (set! x's (cdr x's))
          (set! col (+ col 1))
          (if (= col 7)
            (set! col 0)
            )
          )
        )
      (set! row (+ row 1))
      (set! col 0)
      (set! x's X's)
      (set! y's (cdr y's))
      )
    (gimp-image-set-active-layer image bg-layer)
    (set! frame-layer (car (gimp-layer-new-from-drawable bg-layer image)))
    (gimp-image-insert-layer image frame-layer 0 0)
    (gimp-layer-add-alpha frame-layer)
    (gimp-selection-none image)
    (gimp-drawable-edit-clear frame-layer)
    (gimp-context-set-background border-color)
    (gimp-image-select-rectangle image  CHANNEL-OP-REPLACE x1 y1 (round (- x2 x1)) (round (- y2 y1)))
    (gimp-selection-invert image)
    (unless (= border 0)
      (gimp-drawable-edit-fill  frame-layer FILL-BACKGROUND)
      )
    (map (lambda (x) (gimp-item-set-visible x FALSE)) visibles)
    (map (lambda (x) (gimp-item-set-visible x FALSE)) cal-days)
    (set! frame-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
    (gimp-item-set-visible frame-layer FALSE)
    (map (lambda (x) (gimp-item-set-visible x TRUE)) cal-days)
    (set! dates-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
    (gimp-layer-resize dates-layer
                       (car (gimp-drawable-get-width frame-layer))
                       (car (gimp-drawable-get-height frame-layer))  
                       (- (car (gimp-drawable-get-offsets dates-layer)) (car (gimp-drawable-get-offsets frame-layer)))
                       (- (cadr (gimp-drawable-get-offsets dates-layer)) (cadr (gimp-drawable-get-offsets frame-layer))))
    (map (lambda (x) (gimp-item-set-visible x TRUE)) visibles)
    (gimp-item-set-visible frame-layer TRUE)
    (gimp-item-set-name dates-layer (string-append (vector-ref months month) ", " (number->string year)))
    (gimp-item-set-name frame-layer (vector-ref months month))
    (gimp-context-set-background orig-bg)
    (gimp-progress-update 1)
    (gimp-displays-flush)
    (gimp-context-pop)
    (gimp-image-select-item image 0 orig-sel)
    (gimp-image-remove-channel image orig-sel)
    (gimp-image-remove-layer image bg-layer)
    (gimp-image-set-active-layer image drawable)
    (gimp-image-undo-group-end image)
    (list dates-layer frame-layer)
    )
  )

(define (script-fu-sg-calendar-year orig-image orig-drawable 
                                    lang 
                                    year
                                    start-month
                                    end-month
                                    num-cols 
                                    padding
                                    sunday? letters-in-day layout text-font number-font fontsize% justify? border border-color gravity)
  (define (algebraic-prog start end elements)
    (let ((elements (inexact->exact elements))
          (incr (if (zero? start)
                  (/ end (- elements 1))
                  (/ (- (/ end start) 1) (- elements 1)) ) ) )
      (let 
        loop ((cnt (- elements 1))
              (lis (if (zero? start)
                     '(0)
                     '(1) ) ) )
        (if (zero? cnt)
          (if (zero? start)
            (reverse lis)
            (map * (reverse lis) (make-list elements start)) )
          (loop (- cnt 1) (cons (+ (car lis) incr) lis)) ) ) ) )
  ; adjust input parameter so january is now first month        
  ; Remember: december was first in the SF-OPTION list so that 
  ;           the default setting would be Jan to Dec 
  (set! end-month (modulo (pred end-month) 12)) 
                                                
  (let* ((image 0)
         (orig-x (car (gimp-drawable-get-offsets orig-drawable)))
         (orig-y (cadr (gimp-drawable-get-offsets orig-drawable)))
         (orig-sel 0)
         (bounds (gimp-drawable-mask-intersect orig-drawable))
         (buffer "")
         (layer 0)
         (display 0) )
    (gimp-image-undo-group-start orig-image)
	
    (if (not (= RGB (car (gimp-image-get-base-type orig-image))))
			 (gimp-image-convert-rgb orig-image))

    (set! orig-sel (car (gimp-selection-save orig-image)))
    (unless (= (car (gimp-selection-is-empty orig-image)) TRUE)
      (set! bounds (cdr bounds))
      (set! orig-x (+ orig-x (car bounds)))
      (set! orig-y (+ orig-y (cadr bounds)))
      (gimp-image-select-rectangle orig-image CHANNEL-OP-REPLACE orig-x orig-y (caddr bounds) (cadddr bounds)) )
      	(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
(set! buffer (car (gimp-edit-named-copy orig-drawable "buffer")))
    (set! buffer (car (gimp-edit-named-copy 1 (vector orig-drawable) "buffer"))))
    (set! image (car (gimp-edit-named-paste-as-new-image buffer)))
    (gimp-image-undo-disable image)
    (set! display (car (gimp-display-new image)))
    (set! layer (car (gimp-image-get-active-layer image)))
    (gimp-buffer-delete buffer)
    (let* ((num-months (succ (modulo (- end-month start-month) 12)))
           (num-cols (min (truncate num-cols) num-months))
           (width (car (gimp-drawable-get-width layer)))
           (height (car (gimp-drawable-get-height layer)))
           (x 0)
           (y 0)
           (w (floor (/ width num-cols)))
           (num-rows (ceiling (/ num-months num-cols)))
           (h (floor (/ height num-rows)))
           (w-sel (/ (- width (* width padding 0.01)) num-cols))
           (h-sel w-sel) ; assume square month initially
           (x-offsets '())
           (y-offsets '())
           (temp-layer 0)
           (month-index 0)
           (month-fontsize 6)
           (extents '()) )
      (when (< h (+ h-sel (* h-sel padding 0.01))) ; shrink month height to make room for banner
        (set! h-sel (- h (* h padding 0.009))) ; increase vertical padding a bit
        (set! w-sel h-sel) ; re-calculate horizontal layout
        )
      (set! month-fontsize (apply min (map (lambda (text) 
                                               (sg-calendar-calc-fontsize text text-font 100 w-sel (- h h-sel)) )
                                           (car (list-ref sg-calendar-translations lang)) )))
      (set! y (+ (cadr (gimp-text-get-extents-fontname (caar (list-ref sg-calendar-translations lang))
                                                       month-fontsize 
                                                       PIXELS 
                                                       text-font ))
                 2) )
      (set! y-offsets (if (> num-rows 1)
                        (map truncate (algebraic-prog y (- height h-sel) num-rows))
                        (list y) ))
      (while (pair? y-offsets)
        (set! x-offsets (if (> num-cols 1)
                          (map truncate (algebraic-prog 0 (- width w-sel) num-cols))
                          (list (/ (- width w-sel) 2)) ))
        (while (and (pair? x-offsets) (< month-index num-months))
          (set! x (car x-offsets))
          (set! y (car y-offsets))
          (gimp-image-select-rectangle image  CHANNEL-OP-REPLACE x y w-sel h-sel)
	        	(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
		(set! buffer (car (gimp-edit-named-copy layer "buffer")))
          (set! buffer (car (gimp-edit-named-copy 1 (vector layer) "buffer"))))
          (gimp-floating-sel-to-layer (car (gimp-edit-named-paste layer buffer FALSE)))
          (set! temp-layer (car (gimp-image-get-active-layer image)))
          (gimp-buffer-delete buffer)
          (let ((month (modulo (+ start-month month-index) 12)))
            (script-fu-sg-calendar image temp-layer lang month year sunday? 
                                   letters-in-day layout text-font number-font 
                                   fontsize% justify? border border-color gravity)
            (gimp-image-remove-layer image temp-layer)
            (set! extents (gimp-text-get-extents-fontname (list-ref (car (list-ref sg-calendar-translations lang)) month) 
                                                          month-fontsize 
                                                          PIXELS 
                                                          text-font ))
            (set! temp-layer (car (gimp-text-fontname image -1 
                                                      (+ x (/ (- w-sel (car extents)) 2))
                                                      (- y (cadr extents) (/ (cadddr extents) -2))
                                                      (list-ref (car (list-ref sg-calendar-translations lang)) month)
                                                      0 TRUE 
                                                      month-fontsize PIXELS text-font ))))
          (set! x-offsets (cdr x-offsets))
          (set! month-index (succ month-index)) )
        (set! y-offsets (cdr y-offsets)) ) )
    ;; Now, transfer the rendered layers to original image
    (gimp-selection-none image)
    (let loop ((layers (cdr (reverse (vector->list (cadr (gimp-image-get-layers image))))))
               (target-layer orig-drawable) )
      (if (null? layers)
        ; #t
        (begin
          (let ((x (car (gimp-drawable-get-offsets (car layers))))
                (y (cadr (gimp-drawable-get-offsets (car layers))))
                (pos (car (gimp-image-get-item-position orig-image target-layer))) )
            (set! target-layer (car (gimp-layer-new-from-drawable (car layers) orig-image)))
            (gimp-image-insert-layer orig-image target-layer 0 pos)
            (gimp-layer-set-offsets target-layer (+ orig-x x) (+ orig-y y)) )
          (loop (cdr layers) target-layer) ) ) )
          
    (gimp-image-select-item orig-image 0 orig-sel)
    (gimp-image-remove-channel orig-image orig-sel)
    (gimp-image-set-active-layer orig-image orig-drawable)
    (gimp-image-undo-group-end orig-image)
    ;(gimp-display-delete display)
    (gimp-displays-flush)
    )
  )

(script-fu-register "script-fu-sg-calendar"
  "Gs Calendar Month (No Ctrl+Z)..."
  "Generate a calendar overlay for current layer"
  "Saul Goode"
  "Saul Goode"
  "10/26/09, updated Jan 2012"
  "*"
  SF-IMAGE    "Image"    0
  SF-DRAWABLE "Drawable"  0
  SF-OPTION "Calendar language" sg-calendar-languages
  SF-OPTION "Month" (caar sg-calendar-translations)
  SF-ADJUSTMENT "Year (can throw error after 2050)" '( 2024 1753 2150 1 10 0 0 )
  SF-TOGGLE "Sunday first day of the week?" FALSE
  SF-OPTION "Day naming format (1, 2 or 3 letters)" '("S M T ..." "Su Mo Tu ..." "Sun Mon Tue ...")
  SF-OPTION "Date Grid layout (6 rows or 5 rows)" '( "Allow 6-week span" "Force 6-week span" "Wrap Week 6 to Week 1" "Wrap Week 6 to Week 5")
  SF-FONT "Text font (for the days)" "Sans" 
  SF-FONT "Number font (for the date)" "Sans" 
  SF-ADJUSTMENT "Font Size (% of maximum)" '( 50 0 100 1 10 0 0)
  SF-TOGGLE "Right Justify: Affect numbers with 1 digit" TRUE
  SF-ADJUSTMENT "Grid border width" '( 1 0 5 1 1 0 0 )
  SF-COLOR "Grid border color" '(0 0 0)
  SF-OPTION "Date Position" '( "top-left" "top-center" "top-right" "left-center" "center" "right-center" "bottom-left" "bottom-center" "bottom-right")
  )
(script-fu-menu-register "script-fu-sg-calendar"
  "<Image>/Filters/Render/Calendar"
  )


(script-fu-register "script-fu-sg-calendar-year"
  "Gs Calendar Year (month to month)..."
  "Generate a calendar for current layer"
  "Saul Goode"
  "Saul Goode"
  "Dec 2010, updated Jan 2012"
  "*"
  SF-IMAGE    "Image"    0
  SF-DRAWABLE "Drawable"  0
  SF-OPTION "Calendar language" sg-calendar-languages
  SF-ADJUSTMENT "Year (can throw error after 2050)" '( 2024 1753 2150 1 10 0 0 )
  SF-OPTION "Start Month" (caar sg-calendar-translations)
  SF-OPTION "End Month" (cons (car (last (caar sg-calendar-translations))) 
                              (butlast (caar sg-calendar-translations)))
  SF-ADJUSTMENT "Columns (do NOT use 12)" '( 4 1 12 1 10 0 0 )
  SF-ADJUSTMENT "Padding (% space/banner between rows)" '( 10 0 80 1 10 0 0 )
  SF-TOGGLE "Sunday first day of the week?" FALSE
  SF-OPTION "Day naming format (1, 2 or 3 letters)" '("S M T ..." "Su Mo Tu ..." "Sun Mon Tue ...")
  SF-OPTION "Date Grid layout (6 rows or 5 rows)" '( "Allow 6-week span" "Force 6-week span" "Wrap Week 6 to Week 1" "Wrap Week 6 to Week 5")
  SF-FONT "Text font (for days/months)" "Sans" 
  SF-FONT "Number font (for the dates)" "Sans" 
  SF-ADJUSTMENT "Font Size (% of maximum)" '( 50 0 100 1 10 0 0)
  SF-TOGGLE "Right Justify: Affect numbers with 1 digit" TRUE
  SF-ADJUSTMENT "Grid border width" '( 1 0 5 1 1 0 0 )
  SF-COLOR "Grid border color" '(0 0 0)
  SF-OPTION "Date Position" '( "top-left" "top-center" "top-right" "left-center" "center" "right-center" "bottom-left" "bottom-center" "bottom-right")
  )
(script-fu-menu-register "script-fu-sg-calendar-year"
  "<Image>/Filters/Render/Calendar"
  )

