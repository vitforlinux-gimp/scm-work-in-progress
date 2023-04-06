;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Night Sky (image/alpha/logo)
; Version 2.2 (for Gimp 2.2) - 16 Sep. 2007
; 
;
; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
;
; Render night skies with figurative stars
; Copyright (C) 2003-2007 Eric Lamarque
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
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

(define (real-night img star-color sky-color do-merge)
  (define (randots img layer number tileable)
    (let* ((remaining-points number)
         (width (if (= tileable FALSE) (car (gimp-image-width img))
                    (- (car (gimp-image-width img))
		       (cadr (gimp-brushes-get-brush)))))
         (height (if (= tileable FALSE) (car (gimp-image-height img))
                    (- (car (gimp-image-height img))
		       (caddr (gimp-brushes-get-brush)))))
         )

    (while (> remaining-points 0)
      (let* ((point (cons-array 2 'double)))
	(if (= tileable FALSE)
           (begin
              (aset point 0 (rand width))
              (aset point 1 (rand height)))
           (begin
              (aset point 0 (+ (rand width) 
                             (/ (cadr (gimp-brushes-get-brush)) 2)))
              (aset point 1 (+ (rand height)
                             (/ (caddr (gimp-brushes-get-brush)) 2)))))

        (gimp-paintbrush-default layer 2 point)

        (set! remaining-points (- remaining-points 1))
      )
    )

  )
  )

  (let* ((width (car (gimp-image-width img)))
         (height (car (gimp-image-height img)))
         (black-layer (car (gimp-layer-new img width height RGBA-IMAGE
          "Black" 100 LAYER-MODE-NORMAL-LEGACY)))
         (star-layer (car (gimp-layer-new img width height RGBA-IMAGE
          "Stars" 100 LAYER-MODE-NORMAL-LEGACY)))
         (glowleft-layer 0)
         (glowright-layer 0)
         (glowup-layer 0)
         (glowdown-layer 0)
         (n-little-stars (/ width 4))  ; little tip to adapt number of stars
         (n-mean-stars (/ n-little-stars 2))
         (n-big-stars (/ n-mean-stars 4))
         (sky-layer (car (gimp-layer-new img width height RGBA-IMAGE
          "Sky" 100 LAYER-MODE-NORMAL-LEGACY)))
         (skymask-layer (car (gimp-layer-create-mask sky-layer ADD-MASK-WHITE)))
	     (old-fg (car (gimp-palette-get-foreground)))
	     (old-bg (car (gimp-palette-get-background)))
         (old-brush (car (gimp-brushes-get-brush))))

    ; add new layers to image
    (gimp-image-insert-layer img black-layer 0 -1)
    (gimp-image-insert-layer img star-layer 0 -1)
    (gimp-image-insert-layer img sky-layer 0 -1)

    ; clear all layer
    (gimp-selection-invert img)
	(gimp-drawable-edit-clear black-layer) 
	(gimp-drawable-edit-clear star-layer) 
	(gimp-drawable-edit-clear sky-layer) 
    (gimp-selection-invert img)
	(gimp-drawable-edit-clear black-layer) 
	(gimp-drawable-edit-clear star-layer) 
	(gimp-drawable-edit-clear sky-layer) 

	; black background
	(gimp-palette-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill black-layer FOREGROUND-FILL)

	; stars
   	(gimp-palette-set-foreground star-color)
    (gimp-brushes-set-brush "Circle (01)")
	(randots img star-layer n-little-stars FALSE)
    (gimp-brushes-set-brush "Circle (03)")
	(randots img star-layer n-mean-stars FALSE)
    (gimp-brushes-set-brush "Circle (05)")
	(randots img star-layer n-big-stars FALSE)

	; glowing
	(set! glowleft-layer (car (gimp-layer-copy star-layer FALSE)))
    (gimp-image-insert-layer img glowleft-layer 0 -1)
	(plug-in-mblur 1 img glowleft-layer 0 10 0 0 0)
	(set! glowright-layer (car (gimp-layer-copy star-layer FALSE)))
    (gimp-image-insert-layer img glowright-layer 0 -1)
	(plug-in-mblur 1 img glowright-layer 0 10 180 0 0)
	(set! glowup-layer (car (gimp-layer-copy star-layer FALSE)))
    (gimp-image-insert-layer img glowup-layer 0 -1)
	(plug-in-mblur 1 img glowup-layer 0 10 90 0 0)
	(set! glowdown-layer (car (gimp-layer-copy star-layer FALSE)))
    (gimp-image-insert-layer img glowdown-layer 0 -1)
	(plug-in-mblur 1 img glowdown-layer 0 10 270 0 0)

    (gimp-image-raise-layer-to-top img star-layer)

	; blue atmosphere
	(gimp-palette-set-foreground sky-color)
	(gimp-drawable-edit-fill sky-layer FOREGROUND-FILL)

	; atmosphere dim with height
    (gimp-palette-set-default-colors) ; generate segfault

    (gimp-image-add-layer-mask img sky-layer skymask-layer)
    (gimp-edit-blend skymask-layer BLEND-FG-BG-RGB NORMAL-MODE 
		GRADIENT-LINEAR 100 0 REPEAT-NONE
		FALSE FALSE 3 0.20 TRUE 1 1 1 height)

    (gimp-image-raise-layer-to-top img sky-layer)

	(if (= do-merge TRUE)
	  (let* ((merged-layer 0))
         (set! merged-layer (car (gimp-image-merge-down img sky-layer
			CLIP-TO-IMAGE)))
         (set! merged-layer (car (gimp-image-merge-down img merged-layer
			CLIP-TO-IMAGE)))
         (set! merged-layer (car (gimp-image-merge-down img merged-layer
			CLIP-TO-IMAGE)))
         (set! merged-layer (car (gimp-image-merge-down img merged-layer
			CLIP-TO-IMAGE)))
         (set! merged-layer (car (gimp-image-merge-down img merged-layer
			CLIP-TO-IMAGE)))
         (set! merged-layer (car (gimp-image-merge-down img merged-layer
			CLIP-TO-IMAGE)))
		 (gimp-item-set-name merged-layer "Night sky")
      )
    )

    (gimp-brushes-set-brush old-brush)
	(gimp-palette-set-foreground old-fg)
	(gimp-palette-set-background old-bg)

    (gimp-displays-flush)
  )
)

(define (script-fu-nuit width height star-color sky-color do-merge)
  (let* ((img (car (gimp-image-new width height RGB))))

	(gimp-image-undo-disable img)

    (gimp-selection-all img)

    (real-night img star-color sky-color do-merge)

    (gimp-selection-none img)

    (gimp-image-clean-all img)
	(gimp-image-undo-enable img)
	(gimp-display-new img)
))

(define (script-fu-context-night img layer star-color sky-color do-merge)
	(gimp-undo-push-group-start img)
    (real-night img star-color sky-color do-merge)
    (gimp-image-undo-group-end img)
)

(script-fu-register "script-fu-context-night"
		_"<Image>/Script-Fu/Render/Night sky"
		"Night Sky"
		"Eric Lamarque <eric_lamarque(a)yahoo.fr>"
		"Eric Lamarque"
		"October 2003"
		"RGB*"
		SF-IMAGE "Image" 0
        	SF-DRAWABLE "Drawable" 0
		SF-COLOR _"Star color" '(255 255 255)
		SF-COLOR _"Sky color" '(31 17 221)
		SF-TOGGLE _"Merge layer?" TRUE
)

(script-fu-register "script-fu-nuit"
		"<Toolbox>/Xtns/Script-Fu/Misc/Night sky"
		"Night Sky"
		"Eric Lamarque <eric_lamarque(a)yahoo.fr>"
		"Eric Lamarque"
		"October 2003"
		""
		SF-ADJUSTMENT _"Width" '(400 1 2048 1 10 0 1)
		SF-ADJUSTMENT _"Height" '(400 1 2048 1 10 0 1)
		SF-COLOR _"Star color" '(255 255 255)
		SF-COLOR _"Sky color" '(31 17 221)
		SF-TOGGLE _"Merge layer?" TRUE
)

(define (script-fu-nightsky-logo text size font star-color sky-color bgcolor scolor sblur soff transparent)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
	  (text-layer (car (gimp-text-fontname img -1 0 0 text (+ (/ size 12) 4) TRUE size PIXELS font)))
	  (width (+ 20 (car (gimp-drawable-get-width text-layer))))
	  (height (+ 20 (car (gimp-drawable-get-height text-layer))))
	  (bg-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                     "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	  (s-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                     "Shadow" 100 LAYER-MODE-NORMAL-LEGACY)))
 	  (old-fg (car (gimp-palette-get-foreground)))
 	  (old-bg (car (gimp-palette-get-background)))
	  (shou)
	  (f-layer)
    )

	(gimp-image-undo-disable img)
	(gimp-image-resize img width height 0 0)

    (set! width (car (gimp-image-width img)))		;add
    (set! height (car (gimp-image-height img)))		;add

	; add layer to image
    (gimp-image-insert-layer img bg-layer 0 -1)
;;(if (= FALSE transparent)
;;(begin
    (gimp-image-resize img (+ (+ width soff) (* sblur 1.1)) (+ (+ height soff) (* sblur 1.1)) (/ (* sblur 1.1) 2) (/ (* sblur 1.1) 2))
    (gimp-layer-resize text-layer (+ (+ width soff) (* sblur 1.1)) (+ (+ height soff) (* sblur 1.1)) (/ (* sblur 1.1) 2) (/ (* sblur 1.1) 2))
    (gimp-layer-resize bg-layer (+ (+ width soff) (* sblur 1.1)) (+ (+ height soff) (* sblur 1.1)) (/ (* sblur 1.1) 2) (/ (* sblur 1.1) 2))
;;))

	; fill background with active background color or clear it
    (gimp-selection-all img)
    (if (= transparent FALSE)
	(begin
	(gimp-palette-set-background bgcolor)
        (gimp-drawable-edit-fill bg-layer FILL-BACKGROUND)
	)
	(gimp-drawable-edit-clear bg-layer)
	)

    (gimp-layer-translate text-layer 10 10)		;moved(NO CHANGE!)

	(gimp-selection-layer-alpha text-layer)		;moved
	(real-night img star-color sky-color TRUE)	;moved
	(gimp-selection-none img)

;;    (if (= transparent FALSE)
;;	(begin
	(gimp-image-insert-layer img s-layer 0 1) ;add
	(gimp-layer-resize s-layer (+ (+ width soff) (* sblur 1.1)) (+ (+ height soff) (* sblur 1.1)) 0 0)
	(gimp-drawable-edit-clear s-layer)			;add
	(gimp-selection-layer-alpha text-layer)
	(gimp-palette-set-foreground scolor)
;	(gimp-drawable-edit-fill bg-layer FOREGROUND-FILL)		;none
	(gimp-drawable-edit-fill s-layer FOREGROUND-FILL)		;add
	(gimp-selection-none img)

	(if (>= sblur 1) (plug-in-gauss-rle2 1 img s-layer sblur sblur))	;changed
	(gimp-layer-translate s-layer soff soff)	;add
	(gimp-selection-none img)
;;    ))

;    (gimp-layer-set-name (car (gimp-image-merge-visible-layers img CLIP-TO-IMAGE)) "Night sky text")
    (set! f-layer (car (gimp-image-merge-visible-layers img CLIP-TO-IMAGE)))
    (gimp-layer-set-name f-layer "Night sky text")

;;    (if (= transparent FALSE)
;;	(begin
    (set! width (car (gimp-image-width img)))			;add
    (set! height (car (gimp-image-height img)))			;add
    (if (>= soff sblur ) (set! shou sblur)			;add
	(set! shou soff)					;add
    )								;add
    (gimp-image-resize img (- width (/ shou 2))  (- height (/ shou 2)) (- 0 (/ shou 2)) (- 0 (/ shou 2)))	;add
    (gimp-layer-resize f-layer (- width (/ shou 2))  (- height (/ shou 2)) (- 0 (/ shou 2)) (- 0 (/ shou 2)))	;add
;;    ))

	(gimp-image-undo-enable img)
    (gimp-palette-set-foreground old-fg)
    (gimp-palette-set-background old-bg)
    (gimp-image-clean-all img)

    (gimp-displays-flush)
	(gimp-display-new img)
  )
)

(script-fu-register "script-fu-nightsky-logo"
		"<Toolbox>/Xtns/Script-Fu/Logos/Night sky"
		"Render a night sky in a logo"
		"Eric Lamarque <eric_lamarque(a)yahoo.fr>"
		"Eric Lamarque"
		"October 2003"
		""
		SF-TEXT _"Text" "NIGHT SKY"
		SF-ADJUSTMENT _"Font Size (pixels)" '(100 2 1000 1 10 0 1)
		SF-FONT _"Font" "RoostHeavy"
		SF-COLOR _"Star color" '(255 255 255)
		SF-COLOR _"Sky color" '(38 63 127)
		SF-COLOR _"Background color" '(255 255 255)
		SF-COLOR _"Shadow color" '(0 0 0)
		SF-ADJUSTMENT _"Shadow blur" '(10 0 100 1 10 0 1)
		SF-ADJUSTMENT _"Shadow offset" '(3 0 100 1 10 0 1)
		SF-TOGGLE "Transparent?" FALSE
)

