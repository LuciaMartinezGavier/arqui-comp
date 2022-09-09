	.text
	.org 0x0000

ADD  X9, XZR, XZR
SUB X10, XZR, XZR
ADD X11, X20, XZR
loop:
    STUR X10, [X9, #0]
    ADD  X10, X10,  X1
    ADD   X9,  X9,  X8
    SUB X12, X11, X10
    CBZ X12, end
    CBZ XZR, loop
end:
    CBZ XZR, end
    
