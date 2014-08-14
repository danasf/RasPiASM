/* 
	super simple LED ASM example
*/

.section .init
.globl _start
_start:

// we want pin 16, we need to set the mode to output, each pin gets 3 bits for setup

setup$:
 ldr r0,=0x20200000  // load addr of GPIO control into r0
 mov r1, #1 // move a 1 into r1
 lsl r1, #18 // shift r1 left 1 << 18
 str r1[r0,#4] // store this shifted val at GPIO with 4 byte offset
 mov r3, 0 // set state bit to 0

// okay, we'll turn the pin on
turnon$:
 mov r1,#1 
 lsl r1,#16 // left shift 16
 str r1,[r0,#28] // store value at GPIO with 28 byte offset
 mov r3,#1
 b waitLoop$

// okay, it's setup now we turn it off
turnoff$:
 mov r1,#1 
 lsl r1,#16 // shift 16 places L
 str r1,[r0,#40] // store value to GPIO controller with 40byte offset
 mov r3, #0
 b waitLoop$

// the wait loop
waitLoop$:
 mov r2,#0x3F0000 // set a wait time
 wait$:
  sub r2,#1 // subtract 1
  cmp r2,#0 // compare to 0
  bne wait$ // branch if not equal
 cmp r3,0  // compare the state bit to 0
 bne turnoff$ // if state bit = 1, turnoff
 b turnoff$ // if state bit = 0, turn on

loop$:
b loop$