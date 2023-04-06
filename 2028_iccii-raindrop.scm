; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
; Raindrop effect script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/01/30
;     - Initial relase
;       This is "FIXME" version, which is spaghetti program code
; version 0.2  by Iccii 2001/02/09
;     - Add to offset in highlight option
; version 0.2a by Iccii 2001/02/23
;     - Sorry, I had some mistakes, now fixed
; version 0.2b by Iccii 2001/02/24
;     - Highlight offset is set by persent instead of pixel
; version 0.3  by Iccii 2001/03/27
;     - Add the reflect-width setting
;     - Use Pattern as background
;     - Clean up code and more proofing
; version 0.3a by Iccii 2001/03/30
;     - Make better (speed up)
; version 0.3b by Iccii 2001/04/02
;     - Make better (cleanup code)
; version 0.3c by Iccii 2001/04/10
;     - Fix the layer mask problem (Thanks, Kajiyama)
; version 0.3d by Iccii 2001/05/25
;     - A bit better
; version 0.3e by Iccii 2001/06/21
;     - Minor fix
; version 0.3f by Iccii 2001/07/01
;     - bug fix (if image size doesn't equal to drawable size in alpha-logo)
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



	; 水玉(水滴)のような効果
(define (apply-raindrop-logo-effect20
		img				; IMAGE
		logo-layer		; DRAWABLE (レイヤー)
		text-color		; 水玉の色
		light			; 光の方向 (0-360度)
		blur			; シャドゥ、ハイライトのぼかし半径
		hi-width		; ハイライト幅 (%)
		hi-offset		; ハイライトのオフセット (%)
		hi-option		; ハイライト作成法オプション
		sh-offset		; シャドゥのオフセット
		reflect-width	; 表面反射のバンド幅
		antialias		; アンチエイリアスの有効/無効
)

 (let* (
        (layer-color 0)			;2.4追加
        (mask-color 0)			;2.4追加
        (logo-selection 0)		;2.4追加
        (old-bg 0)			;2.4追加
        (logo-layer-blur 0)		;2.4追加
        (hilight-width 0)		;2.4追加
        (hi-xoffset 0)			;2.4追加
        (hi-yoffset 0)			;2.4追加
        (mask-hilight2 0)		;2.4追加
        )

	; 前処理
	(set! layer-color (car (gimp-layer-copy logo-layer TRUE)))
	(gimp-image-add-layer img layer-color -1)
	(gimp-drawable-set-name layer-color "Color adjust")
	(set! mask-color (car (gimp-layer-create-mask layer-color 5)))
	(gimp-layer-add-mask layer-color mask-color)
	(gimp-layer-set-preserve-trans logo-layer FALSE)
	(gimp-selection-layer-alpha logo-layer)
	(gimp-selection-grow img reflect-width)
	(gimp-edit-fill logo-layer WHITE-FILL)
	(if (eqv? antialias TRUE)
	    (gimp-selection-feather img (/ blur 5)))
	(set! logo-selection (car (gimp-selection-save img)))
	(gimp-selection-invert img)
	(set! old-bg (car (gimp-palette-get-background)))
	(gimp-palette-set-background '(0 0 0))
	(gimp-edit-fill logo-layer BACKGROUND-FILL)
	(gimp-palette-set-background old-bg)
	(gimp-selection-none img)
	(set! logo-layer-blur (car (gimp-layer-copy logo-layer TRUE)))
	(gimp-image-add-layer img logo-layer-blur -1)
	(plug-in-gauss-iir2 1 img logo-layer-blur blur blur)

	; 処理の本体部分
 (let* ((old-fg (car (gimp-palette-get-foreground)))
		(old-bg (car (gimp-palette-get-background)))
		(radians (/ (* 2 *pi* light) 360))
		(sh-xoffset (* sh-offset (cos radians)))
		(sh-yoffset (* sh-offset (sin radians)))
		(layer-value        (car (gimp-layer-copy logo-layer TRUE)))
		(layer-hilight      (car (gimp-layer-copy logo-layer TRUE)))
		(layer-hilight-inn  (car (gimp-layer-copy logo-layer-blur TRUE)))
		(layer-shadow       (car (gimp-layer-copy logo-layer-blur TRUE)))
		(layer-shadow-inn   (car (gimp-layer-copy logo-layer-blur TRUE)))
		(mask-hilight       (car (gimp-layer-create-mask layer-hilight 5)))
		(mask-hilight-inn   (car (gimp-layer-create-mask layer-hilight-inn ADD-BLACK-MASK)))
		(mask-shadow        (car (gimp-layer-create-mask layer-shadow ADD-BLACK-MASK)))
		(mask-shadow-inn    (car (gimp-layer-create-mask layer-shadow-inn ADD-BLACK-MASK))))

	; 各レイヤーの準備
	(gimp-drawable-set-name layer-value       "Value layer")
	(gimp-drawable-set-name layer-hilight     "Highlight layer")
	(gimp-drawable-set-name layer-hilight-inn "Highlight inner")
	(gimp-drawable-set-name layer-shadow      "Drop shadow")
	(gimp-drawable-set-name layer-shadow-inn  "Inner shadow")

	(gimp-image-add-layer img layer-shadow-inn -1)
	(gimp-image-add-layer img layer-shadow -1)
	(gimp-image-add-layer img layer-hilight-inn -1)
	(gimp-image-add-layer img layer-hilight -1)
	(gimp-image-add-layer img layer-value -1)

	; レイヤーマスクを追加する
	(gimp-layer-add-mask layer-hilight mask-hilight)
	(gimp-layer-add-mask layer-hilight-inn mask-hilight-inn)
	(gimp-layer-add-mask layer-shadow mask-shadow)
	(gimp-layer-add-mask layer-shadow-inn mask-shadow-inn)
	(gimp-selection-load logo-selection)
	(gimp-edit-fill mask-hilight-inn WHITE-FILL)
	(gimp-edit-fill mask-shadow WHITE-FILL)
	(gimp-edit-fill mask-shadow-inn WHITE-FILL)
	(gimp-selection-none img)


	; 色反転、色付け、レイヤーモードの変更、ずらしを行う
	(gimp-invert layer-hilight-inn)
	(gimp-invert mask-shadow)
	(gimp-palette-set-foreground text-color)
	(gimp-drawable-fill layer-color FOREGROUND-FILL)
	(gimp-layer-set-mode layer-value ADDITION-MODE)
	(gimp-layer-set-mode layer-hilight SCREEN-MODE)
	(gimp-layer-set-mode layer-hilight-inn SCREEN-MODE)
	(gimp-layer-set-mode layer-shadow SUBTRACT-MODE)
	(gimp-layer-set-mode layer-shadow-inn MULTIPLY-MODE)
	(gimp-layer-set-mode layer-color NORMAL-MODE)
	(gimp-drawable-offset layer-hilight-inn FALSE OFFSET-BACKGROUND (- sh-xoffset) (- sh-yoffset))
	(gimp-drawable-offset layer-shadow      FALSE OFFSET-TRANSPARENT sh-xoffset sh-yoffset)
	(gimp-drawable-offset layer-shadow-inn  FALSE OFFSET-BACKGROUND sh-xoffset sh-yoffset)

	; ハイライトレイヤーの処理
	(gimp-selection-load mask-hilight)
	(gimp-selection-sharpen img)
	(set! hilight-width 0)
	(while (eqv? (car (gimp-selection-is-empty img)) FALSE)
	(gimp-selection-shrink img 1)
	(set! hilight-width (+ hilight-width 1)))
	(gimp-selection-none img)
	(set! hi-xoffset (- (/ (* (* hi-offset (cos radians)) hilight-width) 100)))
	(set! hi-yoffset (- (/ (* (* hi-offset (sin radians)) hilight-width) 100)))
	(gimp-drawable-offset layer-hilight FALSE OFFSET-BACKGROUND hi-xoffset hi-yoffset)
	(gimp-drawable-offset mask-hilight  FALSE OFFSET-BACKGROUND hi-xoffset hi-yoffset)
	(cond
	  ((eqv? hi-option 0)	; 縮めるとき
	    (begin
	  (gimp-selection-load mask-hilight)
	  (gimp-selection-invert img)
	  (gimp-selection-grow img (/ (* hilight-width (- 100 hi-width)) 100))
	  (gimp-palette-set-foreground '(0 0 0))
	  (gimp-edit-fill layer-hilight FOREGROUND-FILL)
	  (gimp-selection-none img)
	  (plug-in-gauss-iir2 1 img layer-hilight (* 0.8 blur) (* 0.8 blur))
	  (gimp-layer-remove-mask layer-hilight MASK-APPLY)))
	  ((eqv? hi-option 1)	; オフセットのとき...さらなる改良が必要
        (begin
	  (gimp-drawable-offset layer-hilight FALSE OFFSET-BACKGROUND
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (- (cos radians)))
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (- (sin radians))))
	  (gimp-drawable-offset mask-hilight FALSE OFFSET-BACKGROUND
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (cos radians))
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (sin radians)))
	  (gimp-layer-remove-mask layer-hilight MASK-APPLY)
	  (plug-in-gauss-iir2 1 img layer-hilight (* 0.8 blur) (* 0.8 blur)))))
	  (set! mask-hilight2 (car (gimp-layer-create-mask logo-layer ADD-BLACK-MASK)))
	  (gimp-layer-add-mask layer-hilight mask-hilight2)
	  (gimp-selection-load logo-selection)
	  (gimp-edit-fill mask-hilight2 WHITE-FILL)
	  (gimp-selection-none img)


	; 最後の調整
	(gimp-selection-none img)
	(gimp-layer-set-opacity layer-value 15)
	(gimp-layer-set-opacity layer-hilight 90)
	(gimp-layer-set-opacity layer-hilight-inn 90)
	(gimp-layer-set-opacity layer-shadow 80)
	(gimp-layer-set-opacity layer-shadow-inn 80)

	; 終わり
	(gimp-image-remove-layer img logo-layer)
	(gimp-image-remove-layer img logo-layer-blur)
	(gimp-image-remove-channel img logo-selection)
	(gimp-image-set-active-layer img layer-value)
	(gimp-palette-set-background old-bg)
	(gimp-palette-set-foreground old-fg)
)			;2.4追加
))


	; 透明度をロゴに
(define (script-fu-raindrop-logo-alpha
		img
		text-layer
		text-color
		light
		blur
		hi-width
		hi-offset
		hi-option
		sh-offset
		reflect-width
		antialias)

 (let* ((width  (car (gimp-drawable-width  text-layer)))
		(height (car (gimp-drawable-height text-layer)))
		(bg-layer (car (gimp-layer-new img (+ width (* 4 sh-offset)) (+ height (* 4 sh-offset)) RGBA-IMAGE "BG layer" 100 NORMAL-MODE))))
		(gimp-image-undo-group-start img)
		(gimp-image-resize img (+ width (* 4 sh-offset)) (+ height (* 4 sh-offset)) (* sh-offset 2) (* sh-offset 2))	;changed
		(gimp-layer-resize text-layer (+ width (* 4 sh-offset)) (+ height (* 4 sh-offset)) (* sh-offset 2) (* sh-offset 2))	;add
		(if (< 0 (car (gimp-layer-get-mask text-layer)))
		  (begin
		  (gimp-layer-remove-mask text-layer MASK-APPLY)
		  (gimp-displays-flush)	))	; why I need this call?
		(gimp-layer-set-preserve-trans text-layer TRUE)
		(gimp-selection-none img)
		(gimp-edit-fill text-layer 2)
		(apply-raindrop-logo-effect20 img text-layer
		 text-color light blur hi-width hi-offset hi-option sh-offset reflect-width antialias)
		(gimp-image-undo-group-end img)
		(gimp-displays-flush)))

(script-fu-register
	"script-fu-raindrop-logo-alpha"
	_"<Image>/Script-Fu/AlphaToLogo/Rain drop..."
	"Creates a logo like a raindrop"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"Mar, 2001"
	"RGBA"
    SF-IMAGE			"Image"			0
	SF-DRAWABLE		"Drawable"		0
	SF-COLOR		_"Base Color"		'(0 63 255)
	SF-ADJUSTMENT		"lighting angle"	'(45 0 360 1 10 0 0)
	SF-ADJUSTMENT		"blur radius"		'(10 1 50 1 5 0 0)
	SF-ADJUSTMENT		"higlight width (%)"	'(30 0 100 1 5 0 0)
	SF-ADJUSTMENT		"higlight offset (%)"	'(40 0 100 1 5 0 0)
	SF-OPTION		"higlight option"	'(_"shrink" _"staggering")
	SF-ADJUSTMENT		"shadow offset"		'(5 0 50 1 5 0 1)
	SF-ADJUSTMENT		_"reflections width"	'(5 0 50 1 5 0 1)
	SF-TOGGLE		_"antialias"		FALSE)


	; ロゴ作成
(define (script-fu-raindrop-logo
		text
		font-size
		fontname
		text-color
		pattern
		light
		blur
		hi-width
		hi-offset
		hi-option
		sh-offset
		reflect-width
		antialias)

 (let* ((img (car (gimp-image-new 256 256 RGB)))
		(text-layer (car (gimp-text-fontname img -1 0 0
						  text (+ 20 reflect-width) TRUE font-size PIXELS fontname)))
		(width  (car (gimp-drawable-width  text-layer)))
		(height (car (gimp-drawable-height text-layer)))
		(bg-layer (car (gimp-layer-new img (+ width sh-offset) (+ height sh-offset) RGBA-IMAGE "Background" 100 NORMAL-MODE)))
		(old-pattern (car (gimp-patterns-get-pattern))))

	(gimp-image-undo-disable img)
	(gimp-image-resize img (+ width sh-offset) (+ height sh-offset) 0 0)		;changed
	(gimp-layer-resize text-layer (+ width sh-offset) (+ height sh-offset) 0 0)	;add
	(gimp-layer-set-preserve-trans text-layer TRUE)
	(gimp-edit-fill text-layer WHITE-FILL)
	(gimp-image-add-layer img bg-layer -1)
	(gimp-selection-all img)
	(gimp-patterns-set-pattern pattern)
	(gimp-edit-bucket-fill bg-layer 2 0 100 255 FALSE 1 1)
	(gimp-selection-none img)
	(apply-raindrop-logo-effect20 img text-layer
	 text-color light blur hi-width hi-offset hi-option sh-offset reflect-width antialias)
	(gimp-patterns-set-pattern old-pattern)
	(gimp-image-undo-enable img)
	(gimp-display-new img)
	(gimp-displays-flush)))

(script-fu-register
	"script-fu-raindrop-logo"
	_"<Toolbox>/Xtns/Script-Fu/Logos/Rain drop..."
	"Create a raindrop like logo"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"Jun, 2001"
	""
	SF-STRING		_"Text"			"Rain Drop"
	SF-ADJUSTMENT		_"Font size (px)"	'(150 2 1000 1 10 0 1)
	SF-FONT			_"Font"			"Slogan"
	SF-COLOR		_"Font Color"		'(0 127 255)
	SF-PATTERN		_"Background Pattern"		"Pine?"
	SF-ADJUSTMENT	_"Lighting angle"		'(45 0 360 1 10 0 0)
	SF-ADJUSTMENT	_"Blur radius"			'(10 1 50 1 5 0 0)
	SF-ADJUSTMENT	_"Higlight width (%)"		'(30 0 100 1 5 0 0)
	SF-ADJUSTMENT	_"Higlight offset (%)"		'(40 0 100 1 5 0 0)
	SF-OPTION	"Higlight option"		'(_"reduction" _"displace")
	SF-ADJUSTMENT	_"Shadow offset"		'(5 0 50 1 5 0 1)
	SF-ADJUSTMENT	_"Reflections width"		'(5 0 50 1 5 0 1)
	SF-TOGGLE	_"Antialias"			 FALSE)
