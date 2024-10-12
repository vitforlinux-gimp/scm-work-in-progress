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
; Version 0.1 - Simulating the 3 color technicolor technique
; 
;

(define (elsamuko-technicolor-3-color-next-gen aimg adraw
                                      redpart   ;redintensity
                                      greenpart ;greenintensity
                                      bluepart  ;blueintensity
                                      cyanfill magentafill yellowfill
                                      sharpen
                                      stretch
                                      retro
                                      extra)
  (let* ((img          (car (gimp-item-get-image adraw)))
         (owidth       (car (gimp-image-width img)))
         (oheight      (car (gimp-image-height img)))
         (sharpenlayer (car (gimp-layer-copy adraw FALSE)))
         (floatingsel  0)
         
         (redlayer     (car (gimp-layer-copy adraw FALSE)))
         (greenlayer   (car (gimp-layer-copy adraw FALSE)))
         (bluelayer    (car (gimp-layer-copy adraw FALSE)))
         (tmplayer     (car (gimp-layer-copy adraw FALSE)))
         (extralayer  0)
         (purplelayer  (car (gimp-layer-new img
                                            owidth 
                                            oheight
                                            1
                                            "Retro Layer" 
                                            100 
                                            LAYER-MODE-SUBTRACT-LEGACY)))
         
         ;         (redmultiplylayer   (car (gimp-layer-new img
         ;                                                  owidth 
         ;                                                  oheight
         ;                                                  1
         ;                                                  "Red Multiply" 
         ;                                                  redintensity
         ;                                                  LAYER-MODE-MULTIPLY-LEGACY)))
         ;         (greenmultiplylayer (car (gimp-layer-new img
         ;                                                  owidth 
         ;                                                  oheight
         ;                                                  1
         ;                                                  "Green Multiply" 
         ;                                                  greenintensity
         ;                                                  LAYER-MODE-MULTIPLY-LEGACY)))
         ;         (bluemultiplylayer  (car (gimp-layer-new img
         ;                                                  owidth 
         ;                                                  oheight
         ;                                                  1
         ;                                                  "Blue Multiply" 
         ;                                                  blueintensity
         ;                                                  LAYER-MODE-MULTIPLY-LEGACY)))
         
         ;decomposing filter colors, you may change these
         (red-R   redpart)
         (red-G   (/ (- 1 redpart)   2) )
         (red-B   (/ (- 1 redpart)   2) )
         
         (green-R (/ (- 1 greenpart) 2) )
         (green-G greenpart)
         (green-B (/ (- 1 greenpart) 2) )
         
         (blue-R  (/ (- 1 bluepart)  2) )
         (blue-G  (/ (- 1 bluepart)  2) )
         (blue-B  bluepart)
         )
    
    ; init
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
        )
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(255 255 255))
    
    ;extra color layer
    (if(= extra 1)
       (begin
         (gimp-image-insert-layer img tmplayer 0 0)
         (gimp-drawable-desaturate tmplayer DESATURATE-LIGHTNESS)
         (gimp-layer-set-mode tmplayer LAYER-MODE-GRAIN-EXTRACT-LEGACY)
         (gimp-edit-copy-visible img)
         (set! extralayer (car (gimp-layer-new-from-visible img img "Extra Color") ))
         (gimp-image-insert-layer img extralayer 0 0)
         (gimp-item-set-visible extralayer FALSE)
         (gimp-item-set-visible tmplayer FALSE)
         )
       )
    
    ;hide original layer
    (gimp-item-set-visible adraw FALSE)
    
    ;RGB filter
    (gimp-item-set-name bluelayer  "Blue -> Yellow")
    (gimp-item-set-name greenlayer "Green -> Magenta")
    (gimp-item-set-name redlayer   "Red -> Cyan")
    
    
    (gimp-image-insert-layer img greenlayer 0 -1)
    ;(gimp-image-insert-layer img greenmultiplylayer -1)
    ;(gimp-drawable-fill greenmultiplylayer FILL-TRANSPARENT)
    
    (gimp-image-insert-layer img bluelayer  0 -1)
    ;(gimp-image-insert-layer img bluemultiplylayer  -1)
    ;(gimp-drawable-fill bluemultiplylayer  FILL-TRANSPARENT)
    
    (gimp-image-insert-layer img redlayer   0 -1)
    ;(gimp-image-insert-layer img redmultiplylayer   -1)
    ;(gimp-drawable-fill redmultiplylayer   FILL-TRANSPARENT)
    
    
    (plug-in-colors-channel-mixer 1 img redlayer TRUE
                                  red-R red-G red-B ;R
                                  0 0 0 ;G
                                  0 0 0 ;B
                                  )
    (plug-in-colors-channel-mixer 1 img greenlayer TRUE
                                  green-R green-G green-B ;R
                                  0 0 0 ;G
                                  0 0 0 ;B
                                  )
    (plug-in-colors-channel-mixer 1 img bluelayer TRUE
                                  blue-R blue-G blue-B ;R
                                  0 0 0 ;G
                                  0 0 0 ;B
                                  )
    
    ;stretch contrast of filter layers
    (if(= stretch TRUE)
       (begin
         (gimp-selection-all img)
         (gimp-drawable-levels-stretch redlayer)
         (gimp-drawable-levels-stretch greenlayer)
         (gimp-drawable-levels-stretch bluelayer)
         )
       )
    
    ;colorize filter layers back
    (gimp-selection-all img)
    (gimp-context-set-paint-mode LAYER-MODE-SCREEN-LEGACY)
    (gimp-context-set-foreground cyanfill)
    ;(gimp-edit-bucket-fill redlayer   BUCKET-FILL-FG LAYER-MODE-SCREEN-LEGACY 100 0 FALSE 0 0)
    (gimp-drawable-edit-fill redlayer FILL-FOREGROUND)
    
    (gimp-context-set-foreground magentafill)
    ;(gimp-edit-bucket-fill greenlayer BUCKET-FILL-FG LAYER-MODE-SCREEN-LEGACY 100 0 FALSE 0 0)
    (gimp-drawable-edit-fill greenlayer FILL-FOREGROUND)
    
    (gimp-context-set-foreground yellowfill)
    ;(gimp-edit-bucket-fill bluelayer  BUCKET-FILL-FG LAYER-MODE-SCREEN-LEGACY 100 0 FALSE 0 0)
    (gimp-drawable-edit-fill bluelayer FILL-FOREGROUND)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
    
    (gimp-layer-set-mode redlayer   LAYER-MODE-MULTIPLY-LEGACY)
    (gimp-layer-set-mode greenlayer LAYER-MODE-MULTIPLY-LEGACY)
    (gimp-layer-set-mode bluelayer  LAYER-MODE-MULTIPLY-LEGACY)
    
    
    ;    ;add multiply layers
    ;    (gimp-selection-all img)
    ;    
    ;    (gimp-edit-copy redlayer)
    ;    (set! floatingsel (car (gimp-edit-paste redmultiplylayer TRUE)))
    ;    (gimp-floating-sel-anchor floatingsel)
    ;    
    ;    (gimp-edit-copy greenlayer)
    ;    (set! floatingsel (car (gimp-edit-paste greenmultiplylayer TRUE)))
    ;    (gimp-floating-sel-anchor floatingsel)
    ;    
    ;    (gimp-edit-copy bluelayer)
    ;    (set! floatingsel (car (gimp-edit-paste bluemultiplylayer TRUE)))
    ;    (gimp-floating-sel-anchor floatingsel)
    
    ;sharpness + contrast layer
    (if(> sharpen 0)
       (begin
         (gimp-image-insert-layer img sharpenlayer 0 0)
         (gimp-drawable-desaturate sharpenlayer DESATURATE-LIGHTNESS)
         (plug-in-unsharp-mask 1 img sharpenlayer 5 1 0)
         (gimp-layer-set-mode sharpenlayer LAYER-MODE-OVERLAY-LEGACY)
         (gimp-layer-set-opacity sharpenlayer sharpen)
         ;(set! floatingsel (car (gimp-layer-create-mask sharpenlayer 5)))
         ;(gimp-layer-add-mask sharpenlayer floatingsel)
         ;(gimp-invert floatingsel)
         )
       )
    
    ;set extra color layer on top
    (if(= extra 1)
       (begin
         (gimp-image-raise-item-to-top img extralayer)
         (gimp-layer-set-mode extralayer LAYER-MODE-GRAIN-MERGE-LEGACY)
         (gimp-item-set-visible extralayer TRUE)
         )
       )
    
    ;add 'retro' layer
    (if(= retro TRUE)
       (begin
         (gimp-image-insert-layer img purplelayer 0 -1)
         (gimp-drawable-fill purplelayer FILL-TRANSPARENT)
         (gimp-context-set-foreground '(62 25 55))
         (gimp-selection-all img)
         ;(gimp-edit-bucket-fill purplelayer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
	 (gimp-drawable-edit-fill purplelayer FILL-FOREGROUND)
         (gimp-selection-none img)
         (gimp-layer-set-opacity purplelayer 80)
         (gimp-layer-set-opacity redlayer 80)
         (gimp-layer-set-opacity bluelayer 80)
         (gimp-image-raise-item-to-top img purplelayer)
         )
       )
    
    ; tidy up
    (gimp-selection-none img)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(script-fu-register "elsamuko-technicolor-3-color-next-gen"
                    _"_Technicolor 3 Color Next Gen"
                    "Simulating Technicolor Film."
                    "elsamuko <elsamuko@web.de>"
                    "elsamuko"
                    "13/09/08"
                    "*"
                    SF-IMAGE       "Input image"      0
                    SF-DRAWABLE    "Input drawable"   0
                    SF-ADJUSTMENT _"Red Part of Red Filter"     '(1.2 0 2 0.1 0.2 1 0)
                    ;SF-ADJUSTMENT _"Red Multiply Opacity"     '(0 0 100 1 5 1 0)
                    
                    SF-ADJUSTMENT _"Green Part of Green Filter" '(1.2 0 2 0.1 0.2 1 0)
                    ;SF-ADJUSTMENT _"Green Multiply Opacity"   '(0 0 100 1 5 1 0)
                    
                    SF-ADJUSTMENT _"Blue Part of Blue Filter"   '(1.2 0 2 0.1 0.2 1 0)
                    ;SF-ADJUSTMENT _"Blue Multiply Opacity"    '(0 0 100 1 5 1 0)
                    
                    SF-COLOR      _"Recomposing Cyan"     '(0   255 255)
                    SF-COLOR      _"Recomposing Magenta"  '(255   0 255)
                    SF-COLOR      _"Recomposing Yellow"   '(255 255   0)
                    
                    SF-ADJUSTMENT _"Sharpen Opacity"      '(60 0 100 1 5 1 0)
                    SF-TOGGLE     _"Stretch Filters"       FALSE
                    SF-TOGGLE     _"Retro Colors"          TRUE
                    SF-TOGGLE     _"Extra Intensity"       TRUE
                    )

(script-fu-menu-register "elsamuko-technicolor-3-color-next-gen" _"<Image>/Colors")
