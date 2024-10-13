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
; 2024 ott 11  fix for 2.99.19 vitforlinux
; Version 0.1 - Simulate a high quality photo like these from the National Geographic
;               Thanks to Martin Egger <martin.egger@gmx.net> for the shadow revovery and the sharpen script
;
; This is the batch version of the NG script, run it with
; gimp -i -b '(elsamuko-national-geographic-next-gen-batch "picture.jpg" 60 1 60 25 0.4 1 0)' -b '(gimp-quit 0)'
; or for more than one picture
; gimp -i -b '(elsamuko-national-geographic-next-gen-batch "*.jpg" 60 1 60 25 0.4 1 0)' -b '(gimp-quit 0)'

; Fix code for gimp 2.99.6 working in 2.10

(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))




(define (elsamuko-national-geographic-next-gen aimg adraw shadowopacity
                                      sharpness screenopacity
                                      overlayopacity localcontrast
                                      screenmask tint)
  (let* ((img (car (gimp-item-get-image adraw)))
         (owidth (car (gimp-image-get-width img)))
         (oheight (car (gimp-image-get-height img)))
         (overlaylayer 0)
         (overlaylayer2 0)
         (screenlayer 0)
         (contrastlayer 0)         
         (tmplayer1 0)         
         (tmplayer2 0)         
         (floatingsel 0)
         
         (ShadowLayer (car (gimp-layer-copy adraw TRUE)))         
         
         (MaskImage (car (gimp-image-duplicate aimg)))
         (MaskLayer (cadr (gimp-image-get-layers MaskImage)))
         (OrigLayer (cadr (gimp-image-get-layers aimg)))
         ;(HSVImage (car (plug-in-decompose TRUE aimg adraw "Value" TRUE)))
	 		(HSVImage (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
          (car (plug-in-decompose TRUE aimg adraw "RGB" TRUE))
          (car (plug-in-decompose 1 aimg 1 (vector adraw) "rgb" TRUE FALSE)) ;2.99.19
))
         (HSVLayer (cadr (gimp-image-get-layers HSVImage)))
         (SharpenLayer (car (gimp-layer-copy adraw TRUE)))
         )
    
    ;init
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    (if (= (car (gimp-drawable-is-gray adraw )) TRUE)
        (gimp-image-convert-rgb img)
        )
    ;(gimp-context-set-foreground '(0 0 0))
    ;(gimp-context-set-background '(255 255 255))
    
    ;shadow recovery from here: http://registry.gimp.org/node/112
    (if(> shadowopacity 0)
       (begin
         (gimp-image-insert-layer img ShadowLayer 0 -1)
         (gimp-drawable-desaturate ShadowLayer 2)
         (gimp-drawable-invert ShadowLayer FALSE)
         (let* ((ShadowMask (car (gimp-layer-create-mask ShadowLayer ADD-MASK-WHITE))))
           (gimp-layer-add-mask ShadowLayer ShadowMask)
           (gimp-selection-all img)
	   (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
           (begin (gimp-edit-copy ShadowLayer)
	   (gimp-floating-sel-anchor (car (gimp-edit-paste ShadowMask TRUE))))
           (begin (gimp-edit-copy 1 (vector ShadowLayer))
	   	       (let* (
           (pasted (gimp-edit-paste ShadowMask FALSE))
           (num-pasted (car pasted))
           (floating-sel (aref (cadr pasted) (- num-pasted 1)))
          )
     (gimp-floating-sel-anchor floating-sel)
    )))
           ;(gimp-floating-sel-anchor (car (gimp-edit-paste ShadowMask TRUE)))
           )
         (gimp-layer-set-mode ShadowLayer LAYER-MODE-OVERLAY-LEGACY)
         (gimp-layer-set-opacity ShadowLayer shadowopacity)
         (gimp-item-set-name ShadowLayer "Shadow Recovery")
         )
       )
    
    ;smart sharpen from here: http://registry.gimp.org/node/108
    (if(> sharpness 0)
       (begin
         (gimp-image-insert-layer img SharpenLayer 0 -1)
         (gimp-selection-all HSVImage)
	(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
         (begin(gimp-edit-copy (aref HSVLayer 0))
	 (gimp-floating-sel-anchor (car (gimp-edit-paste SharpenLayer FALSE))))
         (gimp-edit-copy 1 (vector (aref HSVLayer 0)))
	     ; Clipboard is copy of mask-drawable.  Paste into mask, a channel, and anchor it.
    (begin (let* (
           (pasted (gimp-edit-paste SharpenLayer FALSE))
           (num-pasted (car pasted))
           (floating-sel (aref (cadr pasted) (- num-pasted 1)))
          )
     (gimp-floating-sel-anchor floating-sel)
    )))
         (gimp-image-delete HSVImage)
	 
         ;(gimp-floating-sel-anchor (car (gimp-edit-paste SharpenLayer FALSE)))
         (gimp-layer-set-mode SharpenLayer LAYER-MODE-HSV-VALUE-LEGACY)
         (plug-in-edge TRUE MaskImage (aref MaskLayer 0) 6 1 0)
         (gimp-drawable-levels-stretch (aref MaskLayer 0))
         (gimp-image-convert-grayscale MaskImage)
         (plug-in-gauss TRUE MaskImage (aref MaskLayer 0) 6 6 TRUE)
         (let* ((SharpenChannel (car (gimp-layer-create-mask SharpenLayer ADD-MASK-WHITE)))
                )
           (gimp-layer-add-mask SharpenLayer SharpenChannel)
           (gimp-selection-all MaskImage)
	   (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
	   (begin (gimp-edit-copy (aref MaskLayer 0))
	   (gimp-floating-sel-anchor (car (gimp-edit-paste SharpenChannel FALSE))))
           (begin (gimp-edit-copy 1 (vector (aref MaskLayer 0)))
           ;(gimp-floating-sel-anchor (car (gimp-edit-paste SharpenChannel FALSE)))
	       (let* (
           (pasted (gimp-edit-paste SharpenChannel FALSE))
           (num-pasted (car pasted))
           (floating-sel (aref (cadr pasted) (- num-pasted 1)))
          )
     (gimp-floating-sel-anchor floating-sel)
    )))
           (gimp-image-delete MaskImage)
           (plug-in-unsharp-mask TRUE img SharpenLayer 1 sharpness 0)
           (gimp-layer-set-opacity SharpenLayer 80)
           (gimp-layer-set-edit-mask SharpenLayer FALSE)
           )
         (gimp-item-set-name SharpenLayer "Sharpen")
         )
       )
    
    ;enhance local contrast
    (if(> localcontrast 0)
       (begin
         (gimp-edit-copy-visible img)
         (set! tmplayer1 (car (gimp-layer-new-from-visible img img "Temp 1")))
         (set! tmplayer2 (car (gimp-layer-new-from-visible img img "Temp 2")))
         (gimp-image-insert-layer img tmplayer1 0 -1)
         (gimp-image-insert-layer img tmplayer2 0 -1)
         (plug-in-unsharp-mask 1 img tmplayer1 60 localcontrast 0)
         (gimp-layer-set-mode tmplayer2 LAYER-MODE-GRAIN-EXTRACT-LEGACY)
         (gimp-edit-copy-visible img)
         (set! contrastlayer (car (gimp-layer-new-from-visible img img "Local Contrast")))
         (gimp-image-insert-layer img contrastlayer 0 -1)
         (gimp-layer-set-mode contrastlayer LAYER-MODE-GRAIN-MERGE-LEGACY)
         (gimp-image-remove-layer img tmplayer1)
         (gimp-image-remove-layer img tmplayer2)
         )
       )
    
    ;copy visible three times
    (gimp-edit-copy-visible img)
    (set! overlaylayer (car (gimp-layer-new-from-visible img img "Overlay")))
    (set! overlaylayer2 (car (gimp-layer-new-from-visible img img "Overlay2")))
    (set! screenlayer (car (gimp-layer-new-from-visible img img "Screen")))
    
    ;add screen- and overlay- layers
    (gimp-image-insert-layer img screenlayer 0 -1)
    (gimp-image-insert-layer img overlaylayer 0 -1)
    (gimp-image-insert-layer img overlaylayer2 0 -1)
    
    ;desaturate layers
    (gimp-drawable-desaturate screenlayer 2)
    (gimp-drawable-desaturate overlaylayer 2)  
    (gimp-drawable-desaturate overlaylayer2 2)  
    
    ;set modes 
    (gimp-layer-set-mode screenlayer LAYER-MODE-SCREEN-LEGACY)
    (gimp-layer-set-mode overlaylayer LAYER-MODE-OVERLAY-LEGACY)
    (gimp-layer-set-mode overlaylayer2 LAYER-MODE-OVERLAY-LEGACY)
    (gimp-layer-set-opacity screenlayer screenopacity)
    (gimp-layer-set-opacity overlaylayer overlayopacity)
    (gimp-layer-set-opacity overlaylayer2 overlayopacity)
    
    ;layermask for the screen layer
    (if(= screenmask TRUE)
       (begin
         (set! floatingsel (car (gimp-layer-create-mask screenlayer 5)))
         (gimp-layer-add-mask screenlayer floatingsel)
         (gimp-drawable-invert floatingsel FALSE)
         )
       )
    
    ;overlay tint
    ;red
    (if(= tint 1)
       (begin
         (gimp-drawable-colorize-hsl screenlayer   0 25 0)
         (gimp-drawable-colorize-hsl overlaylayer  0 25 0)
         (gimp-drawable-colorize-hsl overlaylayer2 0 25 0)
         )
       )
    ;blue
    (if(= tint 2)
       (begin
         (gimp-drawable-colorize-hsl screenlayer   225 25 0)
         (gimp-drawable-colorize-hsl overlaylayer  225 25 0)
         (gimp-drawable-colorize-hsl overlaylayer2 225 25 0)
         )
       )
    
    ; tidy up
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
    )
  )

(define (elsamuko-national-geographic-next-gen-batch pattern shadowopacity
                                            sharpness screenopacity
                                            overlayopacity localcontrast
                                            screenmask tint)
  (gimp-message (string-append "Pattern: " pattern))
  (let* ((filelist (cadr (file-glob pattern 1))))
    (while (not (null? filelist))
           (let* ((filename (car filelist))
                  (fileparts (strbreakup filename "."))
                  (img (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))
                  (adraw (car (gimp-image-get-active-drawable img)))
                  )
             (gimp-message (string-append "Filename: " filename))

             (gimp-message "Calling elsamuko-national-geographic-next-gen")
             (elsamuko-national-geographic-next-gen img adraw shadowopacity
                                           sharpness screenopacity
                                           overlayopacity localcontrast
                                           screenmask tint)

             (gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY)
             (set! adraw (car (gimp-image-get-active-drawable img)))

             (gimp-message "Saving")
             (gimp-file-save RUN-NONINTERACTIVE img adraw filename filename)
             (gimp-image-delete img)
             (set! filelist (cdr filelist))
             )
           )
    )
  )

(script-fu-register "elsamuko-national-geographic-next-gen"
                    _"_National Geographic Next Gen"
                    "Simulating high quality photos.
Latest version can be downloaded from http://registry.gimp.org/node/9592"
                    "elsamuko <elsamuko@web.de>"
                    "elsamuko"
                    "22/09/08"
                    "*"
                    SF-IMAGE       "Input image"           0
                    SF-DRAWABLE    "Input drawable"        0
                    SF-ADJUSTMENT _"Shadow Recover Opacity"   '(60  0  100  1   5 0 0)
                    SF-ADJUSTMENT _"Sharpness"                '(0.5 0    2  0.1 1 1 0)
                    SF-ADJUSTMENT _"Screen Layer Opacity"     '(50  0  100  1   5 0 0)                    
                    SF-ADJUSTMENT _"Overlay Layer Opacity"    '(50  0  100  1   5 0 0)
                    SF-ADJUSTMENT _"Local Contrast"           '(0.4 0    2  0.1 1 1 0)
                    SF-TOGGLE     _"Layer Mask for the Screen Layer" TRUE
                    SF-OPTION     _"Overlay Tint"           '("Neutral"
                                                              "Red"
                                                              "Blue")
                    )

(script-fu-menu-register "elsamuko-national-geographic-next-gen" _"<Image>/Filters/Generic")
