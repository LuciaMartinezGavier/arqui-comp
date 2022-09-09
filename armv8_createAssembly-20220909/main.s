	.text
	.org 0x0000
	
ADD  X9, XZR, XZR
SUB X10, XZR, XZR
ADD X11, X20, XZR
loop1:
    STUR X10, [X9, #0]
    ADD  X10, X10,  X1
    ADD   X9,  X9,  X8
    SUB X12, X11, X10
    CBZ X12, continue
    CBZ XZR, loop1
continue:

ADD  X9, XZR, XZR
ADD X10, XZR, XZR
ADD X11, X20, XZR

loop2:
    LDUR X12, [X9, #0]
    ADD  X10, X10, X12
    ADD   X9, X9, X8
    SUB  X11, X11, X1
    CBZ  X11, continue2
    CBZ XZR, loop2
continue2:
    STUR X10, [X9, #0]

ADD  X9, XZR, X17
ADD X10, XZR, X0

loop3:
    ADD X10, X10, X16
    SUB  X9,  X9,  X1
    CBZ X9, end
    CBZ XZR, loop3
end:
    STUR X10, [X0, #0]   
    
infloop:
    CBZ XZR, infloop
