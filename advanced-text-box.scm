  (script-fu-register
            "script-fu-advanced-text-box"                        ;function name
            "Advanced Text Box"                                  ;menu label
            "Creates a simple text box, sized to fit\
              around the user's choice of text,\
              font, font size, and color."              ;description
            "Michael Terry"                             ;author
            "copyright 1997, Michael Terry;\
              2009, the GIMP Documentation Team"        ;copyright notice
            "October 27, 1997"                          ;date created
            ""                              ;image type that the script works on
            SF-TEXT      "Text"          "Advanced\nText Box"   ;a string variable
            SF-FONT        "Font"          "Charter"    ;a font variable
            SF-ADJUSTMENT  "Font size"     '(150 1 1000 1 10 0 0)
	     SF-COLOR       "Color"         '(0 0 0)     ;color variable
	    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
                                                        ;a spin-button
           
            SF-ADJUSTMENT  "Buffer amount" '(35 0 100 1 10 1 0)
                                                        ;a slider
  )
  (script-fu-menu-register "script-fu-advanced-text-box" "<Image>/File/Create/Text")
  (define (script-fu-advanced-text-box inText inFont inFontSize inTextColor
					justification
					letter-spacing
					line-spacing
					grow-text
					outline
					inBufferAmount)
    (let*
      (
        ; define our local variables
        ; create a new image:
        (theImageWidth  10)
        (theImageHeight 10)
        (theImage)
        (theImage
                  (car
                      (gimp-image-new
                        theImageWidth
                        theImageHeight
                        RGB
                      )
                  )
        )
        (theText)             ;a declaration for the text
        (theBuffer)           ;create a new layer for the image
        (theLayer
                  (car
                      (gimp-layer-new
                        theImage
                        theImageWidth
                        theImageHeight
                        RGB-IMAGE
                        "layer 1"
                        100
                        LAYER-MODE-NORMAL
                      )
                  )
        )
	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
      ) ;end of our local variables
      (gimp-image-insert-layer theImage theLayer 0 0)
      (gimp-context-set-background '(255 255 255) )
      (gimp-context-set-foreground inTextColor)
      (gimp-drawable-fill theLayer FILL-BACKGROUND)
      (set! theText
      		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
		                    (car
                          (gimp-text-fontname
                          theImage theLayer
                          0 0
                          inText
                          0
                          TRUE
                          inFontSize PIXELS
                          inFont)
                      )
	
                    (car
                          (gimp-text-font
                          theImage theLayer
                          0 0
                          inText
                          0
                          TRUE
                          inFontSize
                          inFont)
                      ))
        )
	;; text alignment
	(gimp-text-layer-set-justification theText justification) ; Text Justification (Rev Value) 
	(gimp-text-layer-set-letter-spacing theText letter-spacing)  ; Set Letter Spacing
	(gimp-text-layer-set-line-spacing theText line-spacing)      ; Set Line Spacing


      (set! theImageWidth   (car (gimp-drawable-get-width  theText) ) )
      (set! theImageHeight  (car (gimp-drawable-get-height theText) ) )
      (set! theBuffer (* theImageHeight (/ inBufferAmount 100) ) )
      (set! theImageHeight (+ theImageHeight theBuffer theBuffer) )
      (set! theImageWidth  (+ theImageWidth  theBuffer theBuffer) )
      (gimp-image-resize theImage theImageWidth theImageHeight 0 0)
      (gimp-layer-resize theLayer theImageWidth theImageHeight 0 0)
      (gimp-layer-set-offsets theText theBuffer theBuffer)
      (gimp-floating-sel-to-layer theText)
      (gimp-layer-resize-to-image-size theText)
;;;; shrink grow text
(cond ((> grow-text 0)
	(gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-grow theImage (round grow-text))
(gimp-context-set-foreground inTextColor)	
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-drawable-edit-clear theText)
	(gimp-selection-shrink theImage (- grow-text)) 
	(gimp-context-set-foreground inTextColor)
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 ))
   ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-shrink theImage (round outline))   
	(gimp-drawable-edit-clear theText)
	(gimp-image-select-item theImage 2 theText)
 ))
; (gimp-image-resize-to-layers theImage)
 
      
      (gimp-display-new theImage)
      (list theImage theLayer theText)
    )
  )