; Metal Mesh rel 0.04.3
; Created by Graechan
; Comments directed to http://gimpchat.com or http://gimpscripts.com
;
; License: GPLv3
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;    GNU General Public License for more details.
;
;    To view a copy of the GNU General Public License
;    visit: http://www.gnu.org/licenses/gpl.html
;
;
; ------------
;| Change Log |
; ------------ 
; Rel 0.01 - Initial Release
; Rel 0.02 - Added Logo Script
; Rel 0.03 - Bugfix for text size
; Rel 0.04.3 - Added Metal type and tint options bugfix for colors and mesh shapes
;

(define (apply-chrome-logo-effect img
                                  logo-layer
                                  offsets
                                  bg-color)
  (let* (
        (offx1 (* offsets 0.4))
        (offy1 (* offsets 0.3))
        (offx2 (* offsets (- 0.4)))
        (offy2 (* offsets (- 0.3)))
        (feather (* offsets 0.5))
        (width (car (gimp-drawable-get-width logo-layer)))
        (height (car (gimp-drawable-get-height logo-layer)))
        (layer1 (car (gimp-layer-new img width height RGBA-IMAGE "Layer 1" 100 LAYER-MODE-DIFFERENCE-LEGACY)))
        (layer2 (car (gimp-layer-new img width height RGBA-IMAGE "Layer 2" 100 LAYER-MODE-DIFFERENCE-LEGACY)))
        (layer3 (car (gimp-layer-new img width height RGBA-IMAGE "Layer 3" 100 LAYER-MODE-NORMAL-LEGACY)))
        (shadow (car (gimp-layer-new img width height RGBA-IMAGE "Drop Shadow" 100 LAYER-MODE-NORMAL-LEGACY)))
        (background (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
        (layer-mask (car (gimp-layer-create-mask layer1 ADD-MASK-BLACK)))
        )

    (gimp-context-push)
    (gimp-context-set-defaults)
    (gimp-context-set-paint-mode 0)

    (script-fu-util-image-resize-from-layer img logo-layer)
    (script-fu-util-image-add-layers img layer1 layer2 layer3 shadow background)
    (gimp-context-set-background '(255 255 255))
    (gimp-selection-none img)
    (gimp-drawable-edit-fill layer1 FILL-BACKGROUND)
    (gimp-drawable-edit-fill layer2 FILL-BACKGROUND)
    (gimp-drawable-edit-fill layer3 FILL-BACKGROUND)
    (gimp-drawable-edit-clear shadow)
    (gimp-image-select-item img CHANNEL-OP-REPLACE logo-layer)
    (gimp-item-set-visible logo-layer FALSE)
    (gimp-item-set-visible shadow FALSE)
    (gimp-item-set-visible background FALSE)
    (gimp-context-set-background '(0 0 0))
    (gimp-drawable-edit-fill layer1 FILL-BACKGROUND)
    (gimp-selection-translate img offx1 offy1)
    (gimp-selection-feather img feather)
    (gimp-drawable-edit-fill layer2 FILL-BACKGROUND)
    (gimp-selection-translate img (* 2 offx2) (* 2 offy2))
    (gimp-drawable-edit-fill layer3 FILL-BACKGROUND)
    (gimp-selection-none img)
    (set! layer1 (car (gimp-image-merge-visible-layers img CLIP-TO-IMAGE)))
    ; if the original image contained more than one visible layer:
    (while (> (car (gimp-image-get-item-position img layer1))
              (car (gimp-image-get-item-position img shadow)))
      (gimp-image-raise-item img layer1)
    )
    (gimp-drawable-invert layer1 FALSE)
    (gimp-layer-add-mask layer1 layer-mask)
    (gimp-image-select-item img CHANNEL-OP-REPLACE logo-layer)
    (gimp-context-set-background '(255 255 255))
    (gimp-selection-feather img feather)
    (gimp-drawable-edit-fill layer-mask FILL-BACKGROUND)
    (gimp-context-set-background '(0 0 0))
    (gimp-selection-translate img offx1 offy1)
    (gimp-drawable-edit-fill shadow FILL-BACKGROUND); qui
    (gimp-selection-none img)
    (gimp-context-set-background bg-color)
    (gimp-drawable-edit-fill background FILL-BACKGROUND)
    (gimp-item-set-visible shadow TRUE)
    (gimp-item-set-visible background TRUE)
    (gimp-item-set-name layer1 (car (gimp-item-get-name logo-layer)))
    (gimp-image-remove-layer img logo-layer)

    (gimp-context-pop)
  )
)

;scaled pattern fill procedure
(define (scaled-pattern-fill image drawable pattern scale)
  (let* (
	      (width (car (gimp-pattern-get-info pattern)))
          (height (cadr (gimp-pattern-get-info pattern)))
		  (pat-img (car (gimp-image-new (* 5 width) (* 5 height) RGB)))
		  (pat-layer (car (gimp-layer-new pat-img (* 5 width) (* 5 height) RGBA-IMAGE "Pattern" 100 LAYER-MODE-NORMAL-LEGACY)))
		  (new-width (* (/ (* 5 width) 100) scale))
		  (new-height (* (/ (* 5 height) 100) scale))
		  )
	(gimp-image-add-layer pat-img pat-layer	0)
    (gimp-drawable-fill pat-layer FILL-PATTERN)
	(gimp-image-scale-full pat-img new-width new-height 3)
	(plug-in-unsharp-mask 1 pat-img pat-layer 5 .5 0)
	;(plug-in-make-seamless 1 pat-img pat-layer)
	(gimp-edit-copy-visible pat-img)
	(gimp-context-set-pattern (caadr (gimp-patterns-list "")))
	(gimp-image-delete pat-img))
	(gimp-edit-fill drawable FILL-PATTERN))
;
; Gradients blend direction list
(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal"))
;
; Include layer Procedure
(define (include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.8 
          )
          (else
           (gimp-image-add-layer image newlayer (+ (car (gimp-image-get-layer-position image oldlayer)) stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end include layer procedure
;
;find layer by name proceedure
(define (find-layer-by-name image layerName)
  (let* (
           (layerList (vector->list (cadr (gimp-image-get-layers image))))    
           (wantedLayerId -1)
		   (layerId 0)
           (layerText "")
        )
       
        (while (not (null? layerList))
          (set! layerId (car layerList))
		  (set! layerText (cond ((defined? 'gimp-image-get-item-position) (car (gimp-item-get-name layerId)))
		                  (else (car (gimp-drawable-get-name layerId)))))
          (if (string=? layerText layerName) (set! wantedLayerId layerId))          
          (set! layerList (cdr layerList))) ;endwhile        
        (if (= -1 wantedLayerId) (error (string-append "Could not find a layer with name:- " layerName)))
        (list wantedLayerId)
  ) ;end variables
) ;end find layer by name proceedure
;
(define (script-fu-metal-mesh image 
                               layer
                               type
							   size
							   metal
							   tint-color
							   keep-selection-in
							   conserve
							   )
							   
	(gimp-image-undo-group-start image)						  

 (let* (
            (width (car (gimp-image-width image)))
			(height (car (gimp-image-height image)))
			(original-width width)
			(original-height height)
			(area (* 1000 1000))
			(alpha (car (gimp-drawable-has-alpha layer)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (cond ((defined? 'gimp-image-get-item-position) (car (gimp-item-get-name layer)))
		            (else (car (gimp-drawable-get-name layer)))))
			(active-gradient (car (gimp-context-get-gradient)))
		    (active-fg (car (gimp-context-get-foreground)))
		    (active-bg (car (gimp-context-get-background)))
		    (keep-selection keep-selection-in)
			(selection-channel 0)
			(ver 2.8)
			(bkg-layer 0)
			(bkg-copy 0)
			(grid-layer 0)
			(pattern-layer 0)
			(bump-channel 0)
			(shadow-layer 0)
			(background 0)
			(type (cond ((= type 0) 1)
            ((= type 1) 0)
            (else type)))
        )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
	
	(gimp-context-push)
	 (gimp-context-set-paint-mode 0)
	;(gimp-context-set-foreground '(0 0 0))
	;(gimp-context-set-background '(255 255 255))  
    (gimp-context-set-paint-method "gimp-paintbrush")
	(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Dynamics Off")))
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

	(if (= alpha FALSE) (gimp-layer-add-alpha layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (begin
	(cond ((= ver 2.8) (gimp-image-select-item image 2 layer)) 
	(else (gimp-selection-layer-alpha layer))
	) ;endcond
	)
	)
	
;;;;create selection-channel (gimp-selection-load selection-channel)	
	(set! selection-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name selection-channel "selection-channel"))
	(else (gimp-item-set-name selection-channel "selection-channel"))
    ) ;endcond
	(gimp-image-set-active-layer image layer)
	(cond((= sel FALSE) (gimp-edit-clear layer))
	(else (gimp-selection-none image))
    ) ;endcond
	
;;;;begin the script	
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	(include-layer image bkg-layer layer 1)	;stack 0=above 1=below
	(plug-in-plasma 1 image bkg-layer 0 1.0)
	(set! bkg-copy (car (gimp-layer-copy bkg-layer TRUE)))
	(include-layer image bkg-copy bkg-layer 0)	;stack 0=above 1=below
	(gimp-layer-set-mode bkg-copy LAYER-MODE-SCREEN-LEGACY)
	
	(set! grid-layer (car (gimp-layer-new image width height RGBA-IMAGE "Grid" 100 LAYER-MODE-NORMAL-LEGACY)))
	(include-layer image grid-layer bkg-copy 0)	;stack 0=above 1=below
	(plug-in-grid 1 image grid-layer 1 2 0 "Black" 255 1 2 0 "Black" 255 1 2 0 "Black" 255)
	;(plug-in-mosaic 1 image grid-layer 2 1 2 1 0 135 0 1 0 0 0 1 )
	
	(set! pattern-layer (car (gimp-layer-new image width height RGBA-IMAGE "Pattern" 100 LAYER-MODE-NORMAL-LEGACY)))
	(include-layer image pattern-layer grid-layer 0)	;stack 0=above 1=below
	(gimp-context-swap-colors)
	;(gimp-drawable-fill pattern-layer FILL-FOREGROUND)
	
		(plug-in-mosaic 1 image 
	                pattern-layer ;drawable 
	                size ;tile-size 
					1 ;tile-height 
					(/ size 4) ;tile-spacing 
					1 ;tile-neatness 
					FALSE ;tile-allow-split 
					135 ;light-dir 
					0 ;color-variation 
					TRUE ;antialiasing 
					FALSE ;color-averaging 
					type ;tile-type Tile geometry { SQUARES (0), HEXAGONS (1), OCTAGONS (2), TRIANGLES (3) }
					0 ;tile-surface 
					0) ;Grout color (black/white or fore/background) { BW (0), FG-BG (1) }

	;(plug-in-mosaic 1 image pattern-layer size 1 5 1 0 135 0 1 0 type 0 1 )
	 (gimp-image-select-item image 2 pattern-layer) 

	;(gimp-edit-clear pattern-layer)
	;(gimp-selection-invert image)
	
;;;;create bump-channel (gimp-selection-load bump-channel)	
	(set! bump-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name bump-channel "bump-channel"))
	(else (gimp-item-set-name bump-channel "bump-channel"))
    ) ;endcond
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image bump-channel 15 15)
	(gimp-image-set-active-layer image pattern-layer)	
	(gimp-context-set-background '(128 128 128))	
	(gimp-edit-blend pattern-layer BLEND-FG-BG-RGB LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE (/ width 2) 0 (/ width 2) height)
	(gimp-selection-none image)
	(plug-in-bump-map RUN-NONINTERACTIVE image pattern-layer bump-channel 135 45 32 0 0 0 0 TRUE FALSE 0)
	(plug-in-alienmap2 1 image pattern-layer 1 0 1 0 1 0 0 TRUE TRUE TRUE)
	
	(if (> metal 0) (begin
	(plug-in-colorify RUN-NONINTERACTIVE image 
	                                     pattern-layer ;drawable 
										 (cond ((= metal 1) '(255 215 0)) ;gold
										       ((= metal 2) '(192 192 192)) ;silver
											   ((= metal 3) '(250 180 150)) ;copper
											   ((= metal 4) '(166 125 61)) ;bronze
											   ((= metal 5) tint-color))) ;;colored tint
	)) ;endif
	
	(script-fu-drop-shadow image pattern-layer 4 4 15 '(0 0 0) 80 FALSE)
	(set! shadow-layer (car(find-layer-by-name image "Drop Shadow")))
	(gimp-layer-resize-to-image-size shadow-layer)	
	
;;;;finish the script	
	(if (= conserve FALSE) (begin
	(set! background (car (gimp-image-merge-down image pattern-layer EXPAND-AS-NECESSARY)))
	(set! background (car (gimp-image-merge-down image background EXPAND-AS-NECESSARY)))
	(set! background (car (gimp-image-merge-down image background EXPAND-AS-NECESSARY)))
	(set! background (car (gimp-image-merge-down image background EXPAND-AS-NECESSARY)))
	(cond ((= ver 2.8) (gimp-item-set-name background (string-append "Metal-Mesh" "\nBackground")))
	(else (gimp-item-set-name background (string-append "Metal-Mesh" "\nBackground")))
    ) ;endcond
	(if (= sel FALSE) (begin
	(set! layer (car (gimp-image-merge-down image layer EXPAND-AS-NECESSARY)))
	(cond ((= ver 2.8) (gimp-item-set-name layer (string-append layer-name "\nMetal-Mesh")))
	(else (gimp-item-set-name layer (string-append layer-name "\nMetal-Mesh")))
    ) ;endcond
	)) ;endif
	)) ;endif
   (if (= keep-selection TRUE) (gimp-selection-load selection-channel))
   (if (= conserve FALSE) (gimp-image-remove-channel image selection-channel))
   (if (= conserve FALSE) (gimp-image-remove-channel image bump-channel))

	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(script-fu-register "script-fu-metal-mesh"        		    
  "Metal Mesh..."
  "can create a 'Metal Mesh' background to selected layer or a fill for selection"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "2012"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-OPTION "Tile geometry" '("HEXAGONS" "SQUARES" "OCTAGONS" "TRIANGLES")
  SF-ADJUSTMENT "Size" '(64 4 100 1 10 0 0)
  SF-OPTION "Metal Finish Type" '("Chrome" "Gold" "Silver" "Copper" "Bronze" "Colored Tint")
  SF-COLOR      "Tint Color"         '(0 0 255)
  SF-TOGGLE     "Keep selection"          FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
)

(script-fu-menu-register "script-fu-metal-mesh" "<Image>/Filters/Render/Pattern")

(define (script-fu-metal-mesh-logo 
                                      text
									  justify
									  letter-spacing
									  line-spacing
                                      font-in 
                                      font-size
									  edge-width
									  text-mesh-type
							          text-mesh-size
									  metal
							          tint-color
									  3d-size
						              h-dir
						              v-dir
                                      bkg-type
									  bkg-mesh-type
							          bkg-mesh-size
									  bkg-metal
							          bkg-tint-color
                                      pattern
									  pat-scale
                                      bkg-color
									  gradient
									  gradient-type
									  reverse
									  blendir
									  border-size
									  merge)
									  
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))         
         (border (/ font-size 4))
		 (font (if (> (string-length font-in) 0) font-in (car (gimp-context-get-font))))
         (size-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (final-width (car (gimp-drawable-width size-layer)))
         (final-height (car (gimp-drawable-height size-layer)))
         (text-layer 0)
         (width 0)
         (height 0)
         (bkg-layer 0)
		 (ver 2.8)
		 (selection-channel 0)
         (aspect 0)
		 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))
		 (text-mesh-type (cond ((= text-mesh-type 0) 1)
		                       ((= text-mesh-type 1) 0)
							   (else text-mesh-type)))				
		 (pat-scale (cond ((= pat-scale 0) 100)
		            (else pat-scale)))
		 (drop-shadow 0)
		 (x1 0)
		 (y1 0)
		 (x2 0)
		 (y2 0)
         )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version	 
    
	(gimp-context-push)
	(gimp-context-set-paint-method "gimp-paintbrush")
	(if (= ver 2.8) (gimp-context-set-dynamics "Dynamics Off"))
	(gimp-context-set-foreground '(0 0 0)) ;---------------------------------set text color here
	(gimp-context-set-background '(255 255 255))
	
;;;;adjust the size-layer
    (gimp-text-layer-set-justification size-layer justify)
	(gimp-text-layer-set-letter-spacing size-layer letter-spacing)
	(gimp-text-layer-set-line-spacing size-layer line-spacing)
    (set! final-width (car (gimp-drawable-width size-layer)))
    (set! final-height (car (gimp-drawable-height size-layer)))	

;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 400 4)) TRUE 400 PIXELS font)))
	(gimp-item-set-name text-layer "Text")
;;;;adjust text 
	(gimp-text-layer-set-justification text-layer justify)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
;;;;set the new width and height	
    (set! width (car (gimp-drawable-width text-layer)))
    (set! height (car (gimp-drawable-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)

;;;;create selection-channel (cond ((= ver 2.8) (gimp-image-select-item image 2 selection-channel)) (else (gimp-selection-load selection-channel)))	
    (cond ((= ver 2.8) (gimp-image-select-item image 2 text-layer)) 
	(else (gimp-selection-layer-alpha text-layer)))
    (set! selection-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name selection-channel "selection-channel"))
	(else (gimp-item-set-name selection-channel "selection-channel"))
    ) ;endcond
	(gimp-image-set-active-layer image text-layer)
	(gimp-selection-grow image edge-width)
	(gimp-edit-fill text-layer FILL-FOREGROUND)
	(gimp-selection-none image)
    
;;;;begin the script
	
	(apply-chrome-logo-effect image
                            text-layer ;drawable
                            10 ;offsets
                            "lightgrey") ;bg-color
								  
	(gimp-image-remove-layer image (car (find-layer-by-name image "Background")))
	(set! text-layer (car (gimp-image-merge-down image (car (gimp-image-get-active-layer image)) EXPAND-AS-NECESSARY)))
	
	(if (> metal 0) (begin
	(plug-in-colorify RUN-NONINTERACTIVE image 
	                                     text-layer ;drawable 
										 (cond ((= metal 1) '(255 215 0)) ;gold
										       ((= metal 2) '(192 192 192)) ;silver
											   ((= metal 3) '(250 180 150)) ;copper
											   ((= metal 4) '(166 125 61)) ;bronze
											   ((= metal 5) tint-color))) ;;colored tint
	)) ;endif
	
	(cond ((= ver 2.8) (gimp-image-select-item image 2 selection-channel)) (else (gimp-selection-load selection-channel)))
	
	(script-fu-metal-mesh image 
                              text-layer ;drawable
                              text-mesh-type
							  text-mesh-size
							  metal
							  tint-color
							  FALSE ;keep-selection-in
							  FALSE) ;conserve
	
	(set! text-layer (car (gimp-image-get-active-layer image)))
	
	(metal-mesh-easy-3d image 
	                    text-layer ;drawable
                        3d-size
						h-dir
						v-dir
						FALSE ;keep-selection-in
						FALSE) ;conserve
	
	(set! text-layer (car (gimp-image-get-active-layer image)))
	
	(cond ((not (= bkg-type 4))
	(mesh-pixel-frame image 
	                  text-layer ;drawable 
					  border-size 
					  FALSE ;keep-selection-in 
					  FALSE) ;conserve
	)) ;endcond
	
	(set! text-layer (car (gimp-image-get-active-layer image)))
	
	;end

;;;;Scale Image to it's final size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (set! aspect (/ final-width (car (gimp-image-width image)))) 
    (gimp-image-scale image final-width (* (car (gimp-image-height image)) aspect))
	(set! width (car (gimp-image-width image)))
	(set! height (car (gimp-image-height image)))    
	
    (if (= bkg-type 0) 
	(begin
    (script-fu-metal-mesh image 
                              text-layer ;drawable
                              bkg-mesh-type
							  bkg-mesh-size
							  bkg-metal
							  bkg-tint-color
							  FALSE ;keep-selection-in
							  FALSE) ;conserve
	
	(set! bkg-layer (car (gimp-image-get-active-layer image))) 
    )) ;endif	

;;;;create the background layer    
	(cond ((not (or (= bkg-type 4) (= bkg-type 0)))
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	(include-layer image bkg-layer text-layer 1)	;stack 0=above 1=below
    )
	) ;endcond

	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 1) (scaled-pattern-fill image bkg-layer pattern pat-scale))		
    (if (= bkg-type 2) (gimp-drawable-fill bkg-layer FILL-BACKGROUND))	
    (if (= bkg-type 3) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)
    (if (= blendir 0) (set! x2 width))
	(if (= blendir 1) (set! y2 height))
	(if (= blendir 2) (begin
	(set! x2 (/ width 2))
	(set! y2 (/ height 2))))	
	(gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY gradient-type 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE x1 y1 x2 y2)))

	(if (= merge TRUE) (begin
	(gimp-image-remove-channel image selection-channel)
	(set! text-layer (car (gimp-image-merge-visible-layers image  EXPAND-AS-NECESSARY)))
	(cond ((= ver 2.8) (gimp-item-set-name text-layer (string-append text "\nMetal Mesh")))
	(else (gimp-item-set-name text-layer (string-append text "\nMetal Mesh")))
	) ;endcond
    )) ;endif
	
	(gimp-context-pop)	
    (gimp-display-new image)
	
    )
  ) 
(script-fu-register "script-fu-metal-mesh-logo"
  "Metal Mesh Logo"
  "Create an image with a text layer over a pattern layer"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "June 2011"
  ""
  SF-TEXT       "Text"    "GIMP"
  SF-OPTION "Justify" '("Centered" "Left" "Right")
  SF-ADJUSTMENT "Letter Spacing" '(70 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-FONT       "Font"               "Arial Bold"
  SF-ADJUSTMENT "Font size (pixels)" '(200 6 500 1 1 0 1)
  SF-ADJUSTMENT "Text Edge Width" '(15 1 30 1 5 0 0)
  SF-OPTION "Text Mesh Geometry" '("SQUARES" "HEXAGONS" "OCTAGONS" "TRIANGLES")
  SF-ADJUSTMENT "Text Mesh Size" '(14 4 100 1 10 0 0)
  SF-OPTION "Metal Finish Type" '("Chrome" "Gold" "Silver" "Copper" "Bronze" "Colored Tint")
  SF-COLOR      "Tint Color"         '(0 0 255)
  SF-ADJUSTMENT "3D Size" '(10 1 50 1 10 0 0)
  SF-OPTION "Horizontal direction" '("Right" "Neutral" "Left")
  SF-OPTION "Vertical direction" '("Bottom" "Neutral" "Top")
  SF-OPTION "Background Type" '("Default (Mesh)" "Pattern" "Color" "Gradient" "None")
  SF-OPTION "Bkg Mesh Geometry" '("HEXAGONS" "SQUARES" "OCTAGONS" "TRIANGLES")
  SF-ADJUSTMENT "Bkg Mesh Size" '(64 4 100 1 10 0 0)
  SF-OPTION "Bkg Metal Finish Type" '("Chrome" "Gold" "Silver" "Copper" "Bronze" "Colored Tint")
  SF-COLOR      "Bkg Tint Color"         '(0 0 255)
  SF-PATTERN    "Background Pattern"            "Bricks"
  SF-ADJUSTMENT "Pattern Scale %" '(0 0 500 1 50 0 0)
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
  SF-ADJUSTMENT "Border size (pixels)" '(20 1 400 1 10 0 0)
  SF-TOGGLE     "Merge the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-metal-mesh-logo" "<Image>/Script-Fu/Logos")
;  
(define (metal-mesh-easy-3d image drawable
                               3d-size
							   h-dir
							   v-dir
							   keep-selection-in
							   conserve
							   )
							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-width image)))
			(height (car (gimp-image-height image)))
			(alpha (car (gimp-drawable-has-alpha image-layer)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (cond ((defined? 'gimp-image-get-item-position) (car (gimp-item-get-name image-layer)))
		    (else (car (gimp-drawable-get-name image-layer)))))
		    (keep-selection keep-selection-in)
			(selection-channel 0)
			(innermap 0)
			(image-mask 0)
			(ver 2.8)
			(ok TRUE)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			(3d-layer 0)
			(copy-layer 0)
			(cnt 3d-size)
			(horizontal 0)
			(vertical 0)
        )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version	
	
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (begin
	(cond ((= ver 2.8) (gimp-image-select-item image 2 image-layer)) 
	(else (gimp-selection-layer-alpha image-layer)))
	)) ;endif
	
	;;;;save the selection    
    (set! selection-channel (car (gimp-selection-save image))) ;(gimp-selection-load selection-channel)
	(gimp-selection-none image)
	
		; creating  map (inner shape)
		(set! innermap (car (gimp-layer-new  image width height RGB-IMAGE "iMap" 100 LAYER-MODE-NORMAL-LEGACY)))
		(include-layer image innermap image-layer 1)	;stack 0=above 1=below
		(gimp-context-set-foreground '(255 255 255))
		(gimp-edit-fill innermap FILL-FOREGROUND)
		(gimp-selection-load selection-channel)
		(gimp-selection-shrink image 3)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-edit-fill innermap FILL-FOREGROUND)
		(gimp-selection-none image)
		(plug-in-gauss-rle2 1 image innermap 6 6)

;		(gimp-context-set-foreground color)
;		(gimp-edit-fill image-layer FILL-FOREGROUND)

		(plug-in-bump-map
			1
			image
			image-layer
			innermap
			135
			32
			5
			0
			0
			0
			0
			1
			1
			0)
	
		(gimp-selection-load selection-channel)
		(gimp-selection-shrink image 2)
		(set! image-mask (car (gimp-layer-create-mask image-layer ADD-MASK-SELECTION)))
		(gimp-layer-add-mask image-layer image-mask)
		(gimp-selection-none image)
		(plug-in-gauss-rle2 1 image image-mask 1 1)
		(gimp-layer-remove-mask image-layer MASK-APPLY)
		(gimp-image-remove-layer image innermap)

;;;;begin the 3d script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	(gimp-image-set-active-layer image image-layer)
	(set! 3d-layer (car (gimp-layer-copy image-layer TRUE)))
	(gimp-image-add-layer image 3d-layer 1)

    
	(set! horizontal
			(cond 
				(( equal? h-dir 0 ) 1) ;right
				(( equal? h-dir 1 ) 0) ;neutral
				(( equal? h-dir 2 ) -1) ;left
			)
		)
		
	(set! vertical
			(cond 
				(( equal? v-dir 0 ) 1) ;bottom
				(( equal? v-dir 1 ) 0) ;neutral
				(( equal? v-dir 2 ) -1) ;top
			)
		)
		
		
    	
	(gimp-selection-none image)
     (while (> cnt 0)
	(gimp-image-set-active-layer image 3d-layer)
	(set! copy-layer (car (gimp-layer-copy 3d-layer TRUE)))
	(gimp-image-add-layer image copy-layer -1)
    (gimp-drawable-transform-2d 
    copy-layer          ;The affected drawable
	0            ;X coordinate of the transformation center
	0            ;Y coordinate of the transformation center
	1             ;Amount to scale in x direction
	1             ;Amount to scale in y direction
	0               ;The angle of rotation (radians)
	horizontal              ;X coordinate of where the center goes
	vertical              ;Y coordinate of where the center goes
	0              ;Direction of transformation { TRANSFORM-FORWARD (0), TRANSFORM-BACKWARD (1) }
	2                   ;Type of interpolation { INTERPOLATION-NONE (0), INTERPOLATION-LINEAR (1), INTERPOLATION-CUBIC (2), INTERPOLATION-LANCZOS (3) }
	TRUE                ;This parameter is ignored, supersampling is performed based on the interpolation type (TRUE or FALSE)
	3                   ;Maximum recursion level used for supersampling (3 is a nice value) (recursion-level >= 1)
	0)                  ;How to clip results { TRANSFORM-RESIZE-ADJUST (0), TRANSFORM-RESIZE-CLIP (1), TRANSFORM-RESIZE-CROP (2), TRANSFORM-RESIZE-CROP-WITH-ASPECT (3) }
	(set! 3d-layer (car (gimp-image-merge-down image copy-layer EXPAND-AS-NECESSARY)))	
	(set! cnt (- cnt 1))
	)
    (if (or (= h-dir 0) (= v-dir 0)) (gimp-brightness-contrast 3d-layer 40 0))	
	(gimp-layer-set-offsets image-layer (cond
	                                    ((= h-dir 2) (- 0 3d-size)) 
                                        ((= h-dir 0) 3d-size)
										(else 0)) ;endcond
										(cond
	                                    ((= v-dir 2) (- 0 3d-size)) 
                                        ((= v-dir 0) 3d-size)
										(else 0)) ;endcond
										)
	
;;;;finish the script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	(if (= conserve FALSE) (begin
	(set! image-layer (car (gimp-image-merge-down image image-layer EXPAND-AS-NECESSARY)))
	(gimp-layer-resize-to-image-size image-layer)))
    (cond ((= ver 2.8) (gimp-item-set-name image-layer (string-append layer-name "-3D")))
	(else (gimp-item-set-name image-layer (string-append layer-name "-3D")))
    ) ;endcond
	(gimp-selection-load selection-channel)
    (if (= keep-selection FALSE) (gimp-selection-none image))
	(gimp-image-remove-channel image selection-channel)
;	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten image-layer)))	
    	
    
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
) 
;---------------------------------------------------------------------------------------------------------
(define (mesh-pixel-frame image drawable border-size keep-selection-in conserve)
							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-width image)))
			(height (car (gimp-image-height image)))
			(alpha (car (gimp-drawable-has-alpha image-layer)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (car (gimp-drawable-get-name image-layer)))
		    (keep-selection keep-selection-in)
			(original-channel 0)
			(selection-channel 0)
			;;;;;;;;;;;;;;;;;;;;;;;;;
			(gradient-image 0)
			(gradient-layer 0)
			(size (* border-size 2))
			(inName "Border Gradient")
			(frame-layer 0)
        )
	
	
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-default-colors)

	;;;;save the selection (gimp-selection-load original-channel)
	(if (= sel FALSE)
	(begin
	(gimp-selection-save image)
	(set! original-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity original-channel 100)	
	(gimp-item-set-name original-channel "original-channel")
	(gimp-image-set-active-layer image image-layer)
	(gimp-selection-none image)))	
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made and make one	
	(if (= sel TRUE) (set! keep-selection FALSE))	
	(gimp-rect-select image
                        (car (gimp-drawable-offsets image-layer))
                        (cadr (gimp-drawable-offsets image-layer))
                        width
                        height
						CHANNEL-OP-REPLACE
						FALSE
						10)                                 
	
;;;;create selection-channel (gimp-selection-load selection-channel)
    (gimp-selection-save image)
	(set! selection-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity selection-channel 100)	
	(gimp-item-set-name selection-channel "selection-channel")
    (gimp-image-set-active-layer image image-layer)	
	(gimp-selection-none image)	

;;;;begin the script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;create the Gradient image
	(set! gradient-image (car (gimp-image-new 400 400 RGB)))
	(set! gradient-layer (car (gimp-layer-new gradient-image 400 400 RGBA-IMAGE "Gradient" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-add-layer gradient-image gradient-layer 1)
	(plug-in-diffraction 1 gradient-image gradient-layer 0.815 1.221 1.123 0.821 0.821 0.974 1 1 1 0.066 37.126 -0.473)
	(plug-in-rgb-noise 1 gradient-image gradient-layer TRUE FALSE 1 1 1 0)
	(gimp-image-crop gradient-image 400 1 0 200)
	(gimp-image-scale-full gradient-image 400 400 3)
	(gimp-image-crop gradient-image 400 40 0 200)
	
;;;;run Gradient from image	
	(the-pixel-frame-gradient-from-image gradient-image gradient-layer 100 FALSE inName TRUE)
	(gimp-image-delete gradient-image)		

;;;;create the frame layer
    (gimp-image-resize image (+ width size) (+ height size) border-size border-size)
	(set! width (car (gimp-image-width image)))
	(set! height (car (gimp-image-height image)))
	(set! frame-layer (car (gimp-layer-new image width height RGBA-IMAGE "Frame" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-add-layer image frame-layer -1)
    (gimp-context-set-background '(255 255 255))
	(gimp-drawable-fill frame-layer FILL-BACKGROUND)
	(gimp-context-set-gradient "Border Gradient")
	(gimp-edit-blend frame-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-SHAPEBURST-SPHERICAL 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
    (gimp-gradient-delete "Border Gradient")
	(gimp-selection-load selection-channel)
	(gimp-edit-clear frame-layer)
	(gimp-selection-none image)	
	
;;;;finish the script	
	(if (= conserve FALSE) (set! image-layer (car (gimp-image-merge-down image frame-layer EXPAND-AS-NECESSARY))))
    (gimp-item-set-name image-layer layer-name)
    (if (= keep-selection TRUE)(gimp-selection-load original-channel))
	(gimp-image-remove-channel image selection-channel)
    (if (= sel FALSE) (gimp-image-remove-channel image original-channel))
	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten image-layer)))	
    
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)
;
;---------------------------------------------------------------------------------------------------
(define (the-pixel-frame-gradient-from-image img inLayer inSegments inSmooth inName inAlpha)
  (let* 
    (
	  (img (car (gimp-image-duplicate img)))  ;create a duplicate and work on that destructively.
	  (width (car (gimp-image-width img)))
	  (height (car (gimp-image-height img)))
	  (segments (truncate inSegments))
	  (colors (+ segments (if (= inSmooth TRUE) 1 0)))
	  (theGradient "")
	  (counter 0)
	 	(varAlpha 100)
	 	(varNextAlpha 100)
	)
	
	;it begins here
 	(gimp-image-undo-group-start img)

	;flatten inage and get drawable (layer)
	(set! inLayer (car (gimp-image-merge-visible-layers img 1)))
	
	; blur then resize to number of colors  by 1
  (gimp-image-scale img colors 1)
	
	; set up selection as copy of alpha
 	(if (= inAlpha TRUE) (gimp-selection-layer-alpha inLayer))

  ;create new gradient
	(set! theGradient (car (gimp-gradient-new inName)))
	(gimp-context-set-gradient theGradient)
	
	;subdivide
	(gimp-gradient-segment-range-split-uniform theGradient 0 0 segments)

	(while (< counter segments)	
   	(if (= inAlpha TRUE)
      (begin
        (set! varAlpha (/ (* 100 (car (gimp-selection-value img counter 0))) 255))
        (set! varNextAlpha (/ (* 100 (car (gimp-selection-value img (+ counter 1) 0))) 255))
      )
    )
	  (gimp-gradient-segment-set-left-color theGradient counter (car (gimp-image-pick-color img inLayer counter 0 FALSE FALSE 0)) varAlpha)
	  (gimp-gradient-segment-set-right-color theGradient counter (car (gimp-image-pick-color img inLayer (+ counter (if (= inSmooth TRUE) 1 0)) 0 FALSE FALSE 0)) (if (= inSmooth TRUE) varNextAlpha varAlpha))
		(set! counter (+ counter 1))
	)
	
	;done
	(gimp-image-undo-group-end img)
	(gimp-image-delete img)
  )
)
;-----------------------------------------------------------------------------------------------------------------
