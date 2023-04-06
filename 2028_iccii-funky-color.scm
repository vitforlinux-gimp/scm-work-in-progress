; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
; Funky color logo script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/12/03
;     - Initial relase
; version 0.1a by Iccii 2001/12/08
;     - Now only affects to selection area
;
; --------------------------------------------------------------------
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
;

(define (apply-easy-glowing-effect
			img
			img-layer
			blur)

  (let* (
         (img-width (car (gimp-drawable-width img-layer)))
         (img-height (car (gimp-drawable-height img-layer)))
         (layer (car (gimp-layer-new img img-width img-height RGBA-IMAGE
                                           "Base Layer" 100 NORMAL-MODE)))
         (layer-copy)

        )

    (gimp-image-resize img img-width img-height 0 0)
    (if (equal? (car (gimp-drawable-has-alpha img-layer)) FALSE)
        (gimp-layer-add-alpha img-layer))
    (gimp-image-add-layer img layer -1)
    (gimp-image-lower-layer img layer)
    (gimp-drawable-fill layer WHITE-FILL)
    (set! layer (car (gimp-image-merge-down img img-layer EXPAND-AS-NECESSARY)))
    (set! layer-copy (car (gimp-layer-copy layer TRUE)))
    (gimp-image-add-layer img layer-copy -1)
    (gimp-layer-set-mode layer-copy OVERLAY-MODE)
    (plug-in-gauss-iir2 1 img layer blur blur)
    (plug-in-gauss-iir2 1 img layer-copy (+ (/ blur 2) 1) (+ (/ blur 2) 1))
    (let* ((point-num 3)
           (control_pts (cons-array (* point-num 2) 'byte)))
       (aset control_pts 0 0)
       (aset control_pts 1 0)
       (aset control_pts 2 127)
       (aset control_pts 3 255)
       (aset control_pts 4 255)
       (aset control_pts 5 0)
       (gimp-curves-spline layer HISTOGRAM-VALUE (* point-num 2) control_pts)
       (gimp-curves-spline layer-copy HISTOGRAM-VALUE (* point-num 2) control_pts))
    (plug-in-gauss-iir2 1 img layer (+ (* blur 2) 1) (+ (* blur 2) 1))
    (let* ((point-num 4)
           (control_pts (cons-array (* point-num 2) 'byte)))
       (aset control_pts 0 0)
       (aset control_pts 1 0)
       (aset control_pts 2 63)
       (aset control_pts 3 255)
       (aset control_pts 4 191)
       (aset control_pts 5 0)
       (aset control_pts 6 255)
       (aset control_pts 7 255)
       (gimp-curves-spline layer HISTOGRAM-VALUE (* point-num 2) control_pts)
       (gimp-curves-spline layer-copy HISTOGRAM-VALUE (* point-num 2) control_pts))

    (list layer layer-copy)	; Return
  ) ; end of let*
) ; end of define


	;; 透明度をロゴに

(define (script-fu-funky-color-alpha
			img
			layer
			blur
			ft?
	)

  (gimp-image-undo-group-start img)
  (let* (
	 (old-fg (car (gimp-palette-get-foreground)))
	 (old-bg (car (gimp-palette-get-background)))
         (old-layer-name (car (gimp-drawable-get-name layer)))
         (layer-list (apply-easy-glowing-effect img layer blur))
	) ; end variable definition

    (gimp-drawable-set-name (car layer-list) old-layer-name)
    (gimp-drawable-set-name (cadr layer-list) "Change layer mode")
    (if (equal? (car (gimp-selection-is-empty img)) FALSE)
        (begin
          (gimp-selection-invert img)
          (gimp-edit-clear (cadr layer-list))
          (gimp-selection-invert img)))

    (if (= ft? TRUE)
    (gimp-image-flatten img)				;画像の統合
    )

    (gimp-palette-set-foreground old-fg)
    (gimp-palette-set-background old-bg)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)))

(script-fu-register "script-fu-funky-color-alpha"
  "<Image>/Script-Fu/Iccii's Effects/Funky Color..."
  "Create funky color logo image"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Dec"
  "RGB*"
  SF-IMAGE     "Image"		0
  SF-DRAWABLE  "Drawable"	0
  SF-ADJUSTMENT _"Blur Amount"	'(10 1 100 1 1 0 1)
  SF-TOGGLE     "Flatten?" FALSE
)


	;; ロゴ作成

(define (script-fu-funky-color-logo
			text
		 	size
			fontname
			base-color
			blur
	)

  (define (color-invert color)
    (list (- 255 (car color))
          (- 255 (cadr color))
          (- 255 (caddr color))))

  (let* (
	 (old-fg (car (gimp-palette-get-foreground)))
	 (old-bg (car (gimp-palette-get-background)))
         (img (car (gimp-image-new 256 256 RGB)))
         (padding (+ (max (* size 0.1) 5) (* 2 blur)))
         (text-color (color-invert base-color))
	) ; end variable definition

    (gimp-image-undo-disable img)
    (gimp-palette-set-foreground text-color)
    (let* ((text-layer (car (gimp-text-fontname img -1 0 0 text padding TRUE
                                                size PIXELS fontname)))
           (layer-list (apply-easy-glowing-effect img text-layer blur)))
      (gimp-layer-set-name (car layer-list) text)
      (gimp-layer-set-name (cadr layer-list) "Change layer mode"))
    (gimp-palette-set-foreground old-fg)
    (gimp-palette-set-background old-bg)
    (gimp-image-undo-enable img)
    (gimp-display-new img)))


(script-fu-register
  "script-fu-funky-color-logo"
  "<Toolbox>/Xtns/Script-Fu/Logos2/Funky Color..."
  "Create funky color logo image"
  "Iccii <iccii@hotmail.com>"
  "Iccii"
  "2001, Dec"
  ""
  SF-STRING     _"Text"		"Funky!"
  SF-ADJUSTMENT _"Font Size (pixels)"	'(150 2 1000 1 1 0 1)

  SF-FONT       _"Font"
	; Checking winsnap plug-in (Windows or not?)
(if (symbol-bound? 'extension-winsnap (the-environment))
	; For Windows user
		"Times New Roman-bold"
	; Default setting
		"cuneifont light"
)
  SF-COLOR      _"Base Color"	'(127 255 191)
  SF-ADJUSTMENT _"Blur Amount"	'(10 1 100 1 1 0 1)
)
