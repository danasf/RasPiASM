.global GetGpioAddress
.global SetGpioFunction
.global SetGpioState

GetGpioAddress:
 ldr r0,=0x20200000 // GPIO controller addr
 // lr address to jump when fuction is finished
 // pc - next instruction to be run
 mov pc, lr  // move jump point into next instruction

SetGpioFunction:
 cmp r0,#53 // is pin less than 53
 cmpls r1,#7 // is pin function less than 7
 movhi pc,lr // run this if conditions not met to exit function

 push {lr} // put resume point into stack, we do this because we need lr in GetGpioAddress
 mov r2,r0 // mov pin number into r2
 bl GetGpioAddress // we call GetGpioAddress, now that is loaded into r0

/* we need to find the offset to set our GPIO pin in,
 base addr + 4 * ( pin num / 10 )
 we're trying to avoid division to save cycles */

 functionLoop$:
  cmp r2,#9 // compare GPIO pin to 9
  subhi r2,#10 // if higher than 9, subtract 10 from number
  addhi r0,#4 //  if higher add 4 bit offset to base addr 
  bhi functionLoop$ // if still above 9 do it again

  /* 
    we're using this in place of multiplication 
  	add r2 + r2 left shifted 1 (2*r2), so 3*r2
  */
  add r2, r2, lsl #1 
  lsl r1, r2 // left shift gpio function by offset r2
  str r1,[r0] // store gpio function in r0, gpio addr + offset
  pop {pc} // go back to next instr to run outside of function 


SetGpioState:
 pinNum .req r0
 pinVal .req r1

 cmp pinNum,#53
 movhi pc,lr // if condition not met exit
 push {lr} // put jump after poin on stack
 mov r2,pinNum // mov pin num into r2
 .unreq pinNum // we don't need the alias anymore

 pinNum .req r2 // alias r2 as pin num
 bl GetGpioAddress // call the gpioAddrGetter
 gpioAddr .req r0 // get base addr as r0

 pinBank .req r3
 lsr pinBank,pinNum,#5
 lsl pinBank,#2
 add gpioAddr,pinBank
 .unreq pinBank

 and pinNum,#31  // 
 setBit .req r3 
 mov setBit,#1 // set bit high
 lsl setBit,pinNum // left shift pinNum
.unreq pinNum

