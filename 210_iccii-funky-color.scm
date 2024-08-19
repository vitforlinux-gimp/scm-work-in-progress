;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

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
; version 299 for Gimp 2.10 and 2.99.19 AUG 2024 vittforlinux
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
         (img-width (car (gimp-drawable-get-width img-layer)))
         (img-height (car (gimp-drawable-get-height img-layer)))
         (layer (car (gimp-layer-new img img-width img-height RGBA-IMAGE
                                           "Base Layer" 100 LAYER-MODE-NORMAL-LEGACY)))
         (layer-copy)

        )

    (gimp-image-resize img img-width img-height 0 0)
    (if (equal? (car (gimp-drawable-has-alpha img-layer)) FALSE)
        (gimp-layer-add-alpha img-layer))
    (gimp-image-insert-layer img layer 0 -1)
    (gimp-image-lower-item img layer)
    (gimp-drawable-fill layer FILL-WHITE)
    (set! layer (car (gimp-image-merge-down img img-layer EXPAND-AS-NECESSARY)))
    (set! layer-copy (car (gimp-layer-copy layer TRUE)))
    (gimp-image-insert-layer img layer-copy 0 -1)
    (gimp-layer-set-mode layer-copy LAYER-MODE-OVERLAY-LEGACY)
    (plug-in-gauss-iir2 1 img layer blur blur)
    (plug-in-gauss-iir2 1 img layer-copy (+ (/ blur 2) 1) (+ (/ blur 2) 1))
    (let* ((point-num 3)
           (control_pts (cons-array (* point-num 2) 'byte)))
       (aset control_pts 0 0)
       (aset control_pts 1 0)
       (aset control_pts 2 0.498039215686)
       (aset control_pts 3 1)
       (aset control_pts 4 1)
       (aset control_pts 5 0)
       (gimp-drawable-curves-spline layer HISTOGRAM-VALUE (* point-num 2) control_pts)
       (gimp-drawable-curves-spline layer-copy HISTOGRAM-VALUE (* point-num 2) control_pts))
    (plug-in-gauss-iir2 1 img layer (+ (* blur 2) 1) (+ (* blur 2) 1))
    (let* ((point-num 4)
           (control_pts (cons-array (* point-num 2) 'byte)))
       (aset control_pts 0 0)
       (aset control_pts 1 0)
       (aset control_pts 2 0.247058823529)
       (aset control_pts 3 1)
       (aset control_pts 4 0.749019607843)
       (aset control_pts 5 0)
       (aset control_pts 6 1)
       (aset control_pts 7 1)
       (gimp-drawable-curves-spline layer HISTOGRAM-VALUE (* point-num 2) control_pts)
       (gimp-drawable-curves-spline layer-copy HISTOGRAM-VALUE (* point-num 2) control_pts))

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
	 (old-fg (car (gimp-context-get-foreground)))
	 (old-bg (car (gimp-context-get-background)))
         (old-layer-name (car (gimp-drawable-get-name layer)))
         (layer-list (apply-easy-glowing-effect img layer blur))
	) ; end variable definition

    (gimp-item-set-name (car layer-list) old-layer-name)
    (gimp-item-set-name (cadr layer-list) "Change layer mode")
    (if (equal? (car (gimp-selection-is-empty img)) FALSE)
        (begin
          (gimp-selection-invert img)
          (gimp-drawable-edit-clear (cadr layer-list))
          (gimp-selection-invert img)))

    (if (= ft? TRUE)
    (gimp-image-flatten img)				;画像の統合
    )

    (gimp-context-set-foreground old-fg)
    (gimp-context-set-background old-bg)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)))

(script-fu-register "script-fu-funky-color-alpha"
  "Funky Color ALPHA..."
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
(script-fu-menu-register "script-fu-funky-color-logo-alpha"
                         "<Image>Script-Fu/Iccii's Effects")

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
	 (old-fg (car (gimp-context-get-foreground)))
	 (old-bg (car (gimp-context-get-background)))
         (img (car (gimp-image-new 256 256 RGB)))
         (padding (+ (max (* size 0.1) 5) (* 2 blur)))
         (text-color (color-invert base-color))
	) ; end variable definition

    (gimp-image-undo-disable img)
    (gimp-context-set-foreground text-color)
    (let* ((text-layer (car (gimp-text-fontname img -1 0 0 text padding TRUE
                                                size PIXELS fontname)))
           (layer-list (apply-easy-glowing-effect img text-layer blur)))
      (gimp-item-set-name (car layer-list) text)
      (gimp-item-set-name (cadr layer-list) "Change layer mode"))
    (gimp-context-set-foreground old-fg)
    (gimp-context-set-background old-bg)
    (gimp-image-undo-enable img)
    (gimp-display-new img)))


(script-fu-register
  "script-fu-funky-color-logo"
  "Funky Color TEXT..."
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

(script-fu-menu-register "script-fu-funky-color-logo"
                         "<Image>/File/Create/Logos")
