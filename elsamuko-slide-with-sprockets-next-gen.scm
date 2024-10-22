; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
; http://www.gnu.org/licenses/gpl-3.0.html
;
; Copyright (C) 2008 elsamuko <elsamuko@web.de>
;
; Version 0.1 - Simulating a complete exposed film strip.
; Version 0.2 - Optional sh shade thanks to Frank Ludwig
; Version Next Gen 22 ott 2024 - vitforlinux
;
; Fix code for gimp 2.99.6 working in 2.10

(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))
(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))




(define (elsamuko-sprocketholes-next-gen aimg adraw phototext dx1 dx2 font framenumber framenumberhole firstsh shcolor letteringcolor)
  (let* ((img (car (gimp-item-get-image adraw)))
         (owidth (car (gimp-image-get-width img)))
         (oheight (car (gimp-image-get-height img))) ;35mm
         (mm (/ oheight 35)) ;1 mm
         (framewidth (* 38 mm)) ;width of a single frame
         (shheight (* 3 mm)) ;sh = sprocketholes
         (shwidth (* 2 mm))
         (shradius (* 0.5 mm))
         (bordertosh (* 2 mm)) ;first row
         (bordertosh2 (- oheight (+ bordertosh shheight))) ;second row
         (shdistance (/ framewidth 8)) ;4.75mm
         (shgap (- shdistance shwidth)) ;2.75 mm
         (distancetofirstsh (* firstsh mm))
         (distancetofirstnumber (+ distancetofirstsh shwidth (* (- framenumberhole 1) shdistance)))
         (numberofshs (/ owidth shdistance))
         (numberofframes (/ owidth framewidth))
         (holenumber 0)
         (textlength (string-length phototext))
         (x 0) ;helper var
         (shlayer (car (gimp-layer-new img
                                       owidth 
                                       oheight
                                       1
                                       "Sprocket Holes" 
                                       100 
                                       LAYER-MODE-NORMAL-LEGACY)))
         (smearlayer (car (gimp-layer-new img
                                          owidth 
                                          oheight
                                          1
                                          "Smearing" 
                                          100 
                                          LAYER-MODE-ADDITION-LEGACY)))
         (smearlayer2 (car (gimp-layer-new img
                                           owidth 
                                           oheight
                                           1
                                           "Smearing2" 
                                           100 
                                           LAYER-MODE-GRAIN-MERGE-LEGACY)))
         (letteringlayer (car (gimp-layer-new img
                                              owidth 
                                              oheight
                                              1
                                              "Lettering" 
                                              100 
                                              LAYER-MODE-ADDITION-LEGACY)))
         )
    
    ; init
    ;http://www.imageaircraft.com.au/DXsim/
    (define (gimp-dx-select aimg x0 y0 width height dx1 dx2 framenumber A)
      (let*	((blockwidth (/ width 31)) 
                 (blockheight (/ height 2))
                 (iter 0)
                 (iter2 0)
                 )
        ;begin
        (set! iter 0)
        (while (<= iter 4)
               (dx-block-select aimg x0 y0 blockwidth blockheight iter 0)
               (set! iter (+ iter 1))
               )
        (set! iter 0)
        (while (<= iter 4)
               (dx-block-select aimg x0 y0 blockwidth blockheight iter 1)
               (set! iter (+ iter 2))
               )
        ;upper row
        (set! iter 6)
        (while (<= iter 30)
               (dx-block-select aimg x0 y0 blockwidth blockheight iter 0)
               (set! iter (+ iter 2))
               )
        ;dx1
        (set! iter 6)
        (set! iter2 64)
        (binary-block-select aimg x0 y0 blockwidth blockheight iter iter2 dx1)
        ;dx2
        (set! iter 14)
        (set! iter2 8)
        (binary-block-select aimg x0 y0 blockwidth blockheight iter iter2 dx2)
        ;framenumber
        (set! iter 18)
        (set! iter2 32)
        (binary-block-select aimg x0 y0 blockwidth blockheight iter iter2 framenumber)
        ;A
        (if (= A 1)
            (dx-block-select aimg x0 y0 blockwidth blockheight 24 1)
            )
        ;parity bit
        (if (odd? (+ dx1 dx2 framenumber A))
            (dx-block-select aimg x0 y0 blockwidth blockheight 26 1)
            )
        ;end
        (dx-block-select aimg x0 y0 blockwidth blockheight 29 0)
        (dx-block-select aimg x0 y0 blockwidth blockheight 28 1)
        (dx-block-select aimg x0 y0 blockwidth blockheight 30 1)
        )
      )
    
    (define (triangle_array x0 y0 x1 y1 x2 y2)
      (let* ((n_array (cons-array 6 'double)))
        (aset n_array 0 x0 )
        (aset n_array 1 y0 )
        (aset n_array 2 x1)
        (aset n_array 3 y1)
        (aset n_array 4 x2)
        (aset n_array 5 y2)
        n_array)
      )
    
    (define (binary-block-select aimg x0 y0 blockwidth blockheight iter iter2 dx)
      (if (> dx 0.5)
          (begin
            (if (>= dx iter2) 
                ( begin 
                   (dx-block-select aimg x0 y0 blockwidth blockheight iter 1)
                   (binary-block-select aimg x0 y0 blockwidth blockheight (+ iter 1) (/ iter2 2) (- dx iter2))
                   )
                ( begin 
                   (binary-block-select aimg x0 y0 blockwidth blockheight (+ iter 1) (/ iter2 2) dx)
                   )
                )
            )
          )
      )
    
    (define (dx-block-select aimg x0 y0 blockwidth blockheight x y);x=0..30 y=0..1
      (let*	((startx (+ x0 (* x blockwidth))) 
                 (starty (+ y0 (* y blockheight)))
                 )
        (gimp-image-select-rectangle aimg CHANNEL-OP-ADD startx starty (+ blockwidth 1) (+ blockheight 2))
        )
      )
    
    
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
        )
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(255 255 255))
    
    ;add lettering
    (gimp-image-insert-layer img letteringlayer 0 -1)
    (gimp-drawable-fill letteringlayer FILL-TRANSPARENT)
    (gimp-context-set-foreground letteringcolor)
    
    (set! x framenumber)
    (set! framenumber (- framenumber 1))
    
    (while (< framenumber (+ x numberofframes))
           
           ;top phototext
           (gimp-floating-sel-anchor
            (car (gimp-text-fontname img
                                     letteringlayer
                                     (+ (- distancetofirstnumber (* (* 1 mm) (- (/ textlength 2) 1)))
                                        (* (- framenumber (- x 0.5)) framewidth)
                                        ) ;centering the photo text
                                     0
                                     phototext
                                     0 TRUE
                                     (* 1.5 mm) PIXELS
                                     font )))
           
           ;top framenumber
           (gimp-floating-sel-anchor
            (car (gimp-text-fontname img
                                     letteringlayer
                                     (+ distancetofirstnumber (* (- framenumber x) framewidth))
                                     0.0
                                     (number->string framenumber)
                                     0 TRUE
                                     (* 2 mm) PIXELS
                                     font )))
           
           ;down framennumber
           (gimp-floating-sel-anchor
            (car (gimp-text-fontname img
                                     letteringlayer
                                     (+ distancetofirstnumber (* (- framenumber x) framewidth))
                                     (* 0.94 oheight)
                                     (number->string framenumber)
                                     0 TRUE
                                     (* 2 mm) PIXELS
                                     font )))
           
           ;dx
           (gimp-dx-select img
                           (+ (+ distancetofirstnumber (- shdistance (* 0.5 mm)) ) (* (- framenumber x) framewidth))
                           (* 0.94 oheight)
                           (* 13 mm)
                           (* 2.2 mm)
                           dx1 dx2 framenumber 0) ;dx1 dx2 fn A
           ;(gimp-edit-bucket-fill letteringlayer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
	   (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)(gimp-drawable-edit-bucket-fill letteringlayer FILL-FOREGROUND 0 100)
	   
           (gimp-selection-none img)
           
           ;framenumberA
           (gimp-floating-sel-anchor
            (car (gimp-text-fontname img
                                     letteringlayer
                                     (+ (+ distancetofirstnumber mm) (* (- framenumber (- x 0.5)) framewidth))
                                     (* 0.945 oheight)
                                     (string-append (number->string framenumber) "A")
                                     0 TRUE
                                     (* 1.5 mm) PIXELS
                                     font )))
           
           ;triangle
           (gimp-image-select-polygon img CHANNEL-OP-ADD 6
                             (triangle_array (+ (- distancetofirstnumber mm) (* (- framenumber (- x 0.5)) framewidth))
                                             (* 0.945 oheight)
                                             (+ (+ distancetofirstnumber (* 0.7 mm)) (* (- framenumber (- x 0.5)) framewidth))
                                             (+ (* 0.945 oheight) (* 0.75 mm))
                                             (+ (- distancetofirstnumber  mm) (* (- framenumber (- x 0.5)) framewidth))
                                             (+ (* 0.945 oheight) (* 1.5 mm))
                                             )) 
           ;(gimp-edit-bucket-fill letteringlayer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
	   (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)(gimp-drawable-edit-bucket-fill letteringlayer FILL-FOREGROUND 0 100)
           (gimp-selection-none img)
           
           ;dxA
           (gimp-dx-select img
                           (+ (+ distancetofirstnumber (- shdistance (* 0.5 mm)) ) (* (- framenumber (- x 0.5)) framewidth))
                           (* 0.94 oheight)
                           (* 13 mm)
                           (* 2.2 mm)
                           dx1 dx2 framenumber 1) ;dx1 dx2 fn A
           ;(gimp-edit-bucket-fill letteringlayer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
	   (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)(gimp-drawable-edit-bucket-fill letteringlayer FILL-FOREGROUND 0 100)
           (gimp-selection-none img)
           
           (set! framenumber (+ framenumber 1))
           )
    
    ;add new layer and set sprocket holes
    (gimp-image-insert-layer img shlayer 0 -1)
    (gimp-drawable-fill shlayer FILL-TRANSPARENT)
    
    (while (< holenumber (+ numberofshs 5))
           (set! x ( + distancetofirstsh (* holenumber shdistance) ))
           (gimp-image-select-round-rectangle img CHANNEL-OP-ADD
                                   x bordertosh 
                                   shwidth shheight 
                                   shradius shradius)
           (gimp-image-select-round-rectangle img CHANNEL-OP-ADD
                                   x bordertosh2
                                   shwidth shheight 
                                   shradius shradius)
           (set! holenumber (+ holenumber 1))
           )
    ;    (gimp-context-set-foreground letteringcolor)
    ;    (gimp-edit-bucket-fill shlayer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
    ;    (gimp-selection-shrink img 1)
    (gimp-context-set-foreground shcolor)
    ;(gimp-edit-bucket-fill shlayer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)(gimp-drawable-edit-fill shlayer FILL-FOREGROUND)
    ;smear sprocket holes
    (gimp-image-insert-layer img smearlayer 0 -1)
    (gimp-image-lower-item img smearlayer)
    (gimp-drawable-fill smearlayer FILL-TRANSPARENT)
    (gimp-selection-grow img (* 0.2 mm))
    (gimp-selection-feather img (* 1 mm))
    (gimp-context-set-foreground letteringcolor)
    ;(gimp-edit-bucket-fill smearlayer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)(gimp-drawable-edit-fill smearlayer FILL-FOREGROUND)
    
    (gimp-selection-grow img (* 0.2 mm))
    (gimp-image-insert-layer img smearlayer2 0 -1)
    (gimp-image-lower-item img smearlayer2)
    (gimp-drawable-fill smearlayer2 FILL-TRANSPARENT)
    (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
    (begin (gimp-edit-copy adraw)
    (gimp-floating-sel-anchor (car (gimp-edit-paste smearlayer2 TRUE))))
    (begin (gimp-edit-copy 1 (vector adraw))
	   	       (let* (
           (pasted (gimp-edit-paste smearlayer2 FALSE))
           (num-pasted (car pasted))
           (floating-sel (aref (cadr pasted) (- num-pasted 1)))
          )
     (gimp-floating-sel-anchor floating-sel)
    )))
    
    ;tidy up
    (gimp-selection-none img)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(script-fu-register "elsamuko-sprocketholes-next-gen"
                    _"_Photo with Sprocketholes Next Gen"
                    "Simulating a complete exposed film strip."
                    "elsamuko <elsamuko@web.de>"
                    "elsamuko"
                    "13/08/08"
                    "*"
                    SF-IMAGE       "Input image"          0
                    SF-DRAWABLE    "Input drawable"       0
                    SF-STRING     _"Text" "GC 400-8 KODAK"
                    SF-ADJUSTMENT _"DX1" '(82 0 126 1 3 0 1)
                    SF-ADJUSTMENT _"DX2" '(3 0 15 1 3 0 1)
                    SF-FONT       _"Font" "Monospace Bold"
                    SF-ADJUSTMENT _"Number of first frame" '(18 0 36 1 3 0 1)
                    SF-ADJUSTMENT _"Sprocketholes till first frame" '(1 1 8 1 3 0 1)
                    SF-ADJUSTMENT _"First hole after x mm" '(1 -2.5 2.5 0.5 1 1 1)
                    SF-COLOR      _"Sprocket Hole Color" '(0 0 0)
                    SF-COLOR      _"Sprocket Hole Shade" '(237 156 0)
                    )
(script-fu-menu-register "elsamuko-sprocketholes-next-gen" _"<Image>/Filters/Decor")
