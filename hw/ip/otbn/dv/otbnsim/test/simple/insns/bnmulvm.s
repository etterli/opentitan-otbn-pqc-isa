/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors into w0-w7
*/
addi x2, x0, 0

la     x3, vec16a0
bn.lid x2++, 0(x3)
la     x3, vec16b0
bn.lid x2++, 0(x3)

la     x3, vec32a0
bn.lid x2++, 0(x3)
la     x3, vec32b0
bn.lid x2++, 0(x3)

la     x3, vec64a0
bn.lid x2++, 0(x3)
la     x3, vec64b0
bn.lid x2++, 0(x3)

la     x3, vec128a0
bn.lid x2++, 0(x3)
la     x3, vec128b0
bn.lid x2++, 0(x3)

la     x3, vec128a1
bn.lid x2++, 0(x3)
la     x3, vec128b1
bn.lid x2++, 0(x3)

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod16
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.16H w10, w0, w1

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.8S  w11, w2, w3

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod64
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.4D  w12, w4, w5

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod128
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.2Q  w13, w6, w7
bn.mulvm.2Q  w14, w8, w9


addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  16bit vector mod16 for instruction mulvm
  mod16 = [7583]
  mod16 = 0x0000000000000000000000000000000000000000000000000000000000001d9f
*/
mod16:
  .word 0x00001d9f
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  16bit vector vec16a0 for instruction mulvm
  vec16a0 = [0, 1, 34, 58, 157, 23, 221, 159, 148, 62, 33, 129, 15, 158, 36, 137]
  vec16a0 = 0x000000010022003a009d001700dd009f0094003e00210081000f009e00240089
*/
vec16a0:
  .word 0x00240089
  .word 0x000f009e
  .word 0x00210081
  .word 0x0094003e
  .word 0x00dd009f
  .word 0x009d0017
  .word 0x0022003a
  .word 0x00000001

/*
  16bit vector vec16b0 for instruction mulvm
  vec16b0 = [63206, 58121, 923, 588, 208, 223, 204, 180, 10, 1, 100, 192, 42, 161, 92, 47]
  vec16b0 = 0xf6e6e309039b024c00d000df00cc00b4000a0001006400c0002a00a1005c002f
*/
vec16b0:
  .word 0x005c002f
  .word 0x002a00a1
  .word 0x006400c0
  .word 0x000a0001
  .word 0x00cc00b4
  .word 0x00d000df
  .word 0x039b024c
  .word 0xf6e6e309

/*
  Result of 16bit mulvm
  res = [0, 5040, 1050, 3772, 2324, 5129, 7169, 5871, 1480, 62, 3300, 2019, 630, 2689, 3312, 6439]
  res = 0x000013b0041a0ebc091414091c0116ef05c8003e0ce407e302760a810cf01927
*/

/*
  32bit vector mod32 for instruction mulvm
  mod32 = [8380417]
  mod32 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod32:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32a0 for instruction mulvm
  vec32a0 = [0, 1, 44913, 9734, 23276, 65251, 13010, 40903]
  vec32a0 = 0x00000000000000010000af710000260600005aec0000fee3000032d200009fc7
*/
vec32a0:
  .word 0x00009fc7
  .word 0x000032d2
  .word 0x0000fee3
  .word 0x00005aec
  .word 0x00002606
  .word 0x0000af71
  .word 0x00000001
  .word 0x00000000

/*
  32bit vector vec32b0 for instruction mulvm
  vec32b0 = [4140082361, 1869666356, 636760, 207841, 59661, 52504, 947, 30691]
  vec32b0 = 0xf6c4a4b96f70d8340009b75800032be10000e90d0000cd18000003b3000077e3
*/
vec32b0:
  .word 0x000077e3
  .word 0x000003b3
  .word 0x0000cd18
  .word 0x0000e90d
  .word 0x00032be1
  .word 0x0009b758
  .word 0x6f70d834
  .word 0xf6c4a4b9

/*
  Result of 32bit mulvm
  res = [0, 833365, 4819076, 3443797, 5900631, 6728368, 3940053, 6671840]
  res = 0x00000000000cb7550049888400348c55005a09570066aab0003c1ed50065cde0
*/

/*
  64bit vector mod64 for instruction mulvm
  mod64 = [8380417]
  mod64 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod64:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64a0 for instruction mulvm
  vec64a0 = [0, 1, 2417127611, 30955]
  vec64a0 = 0x0000000000000000000000000000000100000000901270bb00000000000078eb
*/
vec64a0:
  .word 0x000078eb
  .word 0x00000000
  .word 0x901270bb
  .word 0x00000000
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64b0 for instruction mulvm
  vec64b0 = [17614515565450322005, 5145075550695678108, 45867244350, 328746167066219]
  vec64b0 = 0xf4735494c14160554766faf41dc3609c0000000aade69b3e00012afe2e825e6b
*/
vec64b0:
  .word 0x2e825e6b
  .word 0x00012afe
  .word 0xade69b3e
  .word 0x0000000a
  .word 0x1dc3609c
  .word 0x4766faf4
  .word 0xc1416055
  .word 0xf4735494

/*
  Result of 64bit mulvm
  res = [0, 6736375, 5386136, 101487]
  res = 0x0000000000000000000000000066c9f70000000000522f980000000000018c6f
*/

/*
  128bit vector mod128 for instruction mulvm
  mod128 = [8380417]
  mod128 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod128:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128a0 for instruction mulvm
  vec128a0 = [0, 1]
  vec128a0 = 0x0000000000000000000000000000000000000000000000000000000000000001
*/
vec128a0:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128a1 for instruction mulvm
  vec128a1 = [15163934324283487979, 59768885155910817024740993528977806]
  vec128a1 = 0x0000000000000000d2711ded0c4536eb000b82d563bae0bc42c1cf008893598e
*/
vec128a1:
  .word 0x8893598e
  .word 0x42c1cf00
  .word 0x63bae0bc
  .word 0x000b82d5
  .word 0x0c4536eb
  .word 0xd2711ded
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b0 for instruction mulvm
  vec128b0 = [4475401137670541, 909208951293833190286950213268633]
  vec128b0 = 0x0000000000000000000fe65a8709c98d00002cd3d491451a0e7eac07695eb499
*/
vec128b0:
  .word 0x695eb499
  .word 0x0e7eac07
  .word 0xd491451a
  .word 0x00002cd3
  .word 0x8709c98d
  .word 0x000fe65a
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b1 for instruction mulvm
  vec128b1 = [86676785931336461155, 2613]
  vec128b1 = 0x0000000000000004b2e1cd923de2ab6300000000000000000000000000000a35
*/
vec128b1:
  .word 0x00000a35
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x3de2ab63
  .word 0xb2e1cd92
  .word 0x00000004
  .word 0x00000000

/*
  Result of 128bit mulvm
  res = [0, 3871254]
  res = 0x00000000000000000000000000000000000000000000000000000000003b1216
*/

/*
  Result of 128bit mulvm
  res = [4265058, 6051552]
  res = 0x00000000000000000000000000411462000000000000000000000000005c56e0
*/
