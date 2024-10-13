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
; Copyright (C) 2009 elsamuko <elsamuko@web.de>
;
; Version 0.1 - first version
; Version 0.2 - added smoothness and contrast option
; version 0.3 - added lines smoothness and edge detection option
; Version Next Gen Fix for Gimp 2.99.19 - 13 ott 2024 - vitforlinux

; Fix code for gimp 2.99.6 working in 2.10

(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(define (elsamuko-che-guevara-next-gen aimg adraw
                              ssmooth sthreshhold
                              lsmooth lthreshhold
                              contrast edge color)
  (let* ((img (car (gimp-item-get-image adraw)))
         (owidth (car (gimp-image-get-width img)))
         (oheight (car (gimp-image-get-height img)))
         (colorlayer (car (gimp-layer-new img
                                          owidth 
                                          oheight
                                          1
                                          "Color" 
                                          100 
                                          LAYER-MODE-NORMAL-LEGACY)))
         (shadowlayer 0)
         (lineslayer 0)
         )
    
    ; init
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
        )
    (gimp-context-set-foreground color)
    (gimp-context-set-background '(255 255 255))
    
    ;set smoothness
    (if (> ssmooth 0)
        (plug-in-gauss 1 img adraw ssmooth ssmooth 0)
        )
    
    ;add color layer
    (gimp-image-insert-layer img colorlayer 0 -1)
    (gimp-drawable-fill colorlayer FILL-TRANSPARENT)
    (gimp-selection-all img)
    ;(gimp-edit-bucket-fill colorlayer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
    (gimp-drawable-edit-fill colorlayer FILL-FOREGROUND)
    (gimp-selection-none img)
    
    ;copy and add original image two times
    (set! shadowlayer (car (gimp-layer-copy adraw FALSE)))
    (set! lineslayer (car (gimp-layer-copy adraw FALSE)))
    (gimp-image-insert-layer img shadowlayer 0 -1)
    (gimp-image-insert-layer img lineslayer 0 -1)
    (gimp-item-set-name shadowlayer "Shadow")
    (gimp-item-set-name lineslayer "Lines")
    
    ;threshhold on shadow layer
    (gimp-drawable-threshold shadowlayer 0 (/ sthreshhold 255) 1)
    (gimp-layer-set-mode shadowlayer LAYER-MODE-MULTIPLY-LEGACY)
    
    ;high contrast, edge detection and threshhold on lines layer
    (if (> contrast 0)
        (plug-in-unsharp-mask 1 img lineslayer 60 contrast 0)
        )
    
    ;edge detection
    (if (= edge 0) (plug-in-neon 1 img lineslayer 5 0))
    (if (= edge 1) (plug-in-sobel 1 img lineslayer 1 1 1))

    (gimp-drawable-invert lineslayer TRUE)
    (gimp-drawable-levels-stretch lineslayer)
    
    (if (> lsmooth 0)
        (begin
          (plug-in-gauss 1 img lineslayer lsmooth lsmooth 0)
          )
        )
    (gimp-drawable-threshold lineslayer 0 (/ lthreshhold 255) 1)
    (gimp-layer-set-mode lineslayer LAYER-MODE-MULTIPLY-LEGACY)
    
    ; tidy up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(script-fu-register "elsamuko-che-guevara-next-gen"
                    _"_Che Guevara Next Gen"
                    "Shadow Style Portrait."
                    "elsamuko <elsamuko@web.de>"
                    "elsamuko"
                    "19/02/2009"
                    "*"
                    SF-IMAGE       "Input image"          0
                    SF-DRAWABLE    "Input drawable"       0
                    SF-ADJUSTMENT _"Shadow Smoothness"  '(3 0 10 0.2 1 1 0)
                    SF-ADJUSTMENT _"Shadow Threshhold"  '(128 0 255 1 10 0 0)
                    SF-ADJUSTMENT _"Lines Smoothness"   '(5 0 10 0.2 1 1 0)
                    SF-ADJUSTMENT _"Lines Threshhold"   '(180 0 255 1 10 0 0)
                    SF-ADJUSTMENT _"Lines Contrast"     '(0 0 10 0.1 1 1 0)
                    SF-OPTION     _"Edge Detection"     '("Neon"
                                                          "Sobel")
                    SF-COLOR      _"Background Color"   '(255 0 0)
                    )

(script-fu-menu-register "elsamuko-che-guevara-next-gen" _"<Image>/Filters/Artistic")
