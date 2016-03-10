/*
 ============================================================================
 Name        : strcmp.S
 Author      : Heiher <r@hev.cc>
               Pei Huang <huangpei@loongson.cn>
 Version     : 2.0.0
 Copyright   : Copyright (c) 2016 everyone.
 Description : The strcmp for Loongson 3.
 ============================================================================
 */

#include <sys/asm.h>
#include <sys/regdef.h>

#define SUBU    PTR_SUBU
#define ADDIU   PTR_ADDIU

/* int strcmp (const char *s1, const char *s2); */

    .globl  strcmp
    .ent    strcmp, 0
    .type   strcmp, @function
    .set    push
    .set    noreorder
    .set    noat
    .set    arch=loongson3a
    .align  5

strcmp:
    andi    t0, a0, 7
    andi    t1, a1, 7
    beq     t0, t1, _loop_ah
    xor     $f0, $f0, $f0

    sltu    t2, t0, t1
    nor     $f4, $f0, $f0
    move    t3, a0
    movz    a0, a1, t2
    movz    a1, t3, t2
    movn    t0, t1, t2

    gsldrc1 $f4, 0(a1)
    gsldrc1 $f2, 0(a0)
    pcmpeqb $f8, $f4, $f0
    seq     $f0, $f8
    bc1f    _mc8
    SUBU    a0, t0
    sll     t0, 3
    nor     $f6, $f0, $f0
    mtc1    t0, $f8
    dins    a1, zero, 0, 3
    dsrl    $f6, $f6, $f8
    ADDIU   a0, 8
    and     $f2, $f2, $f6
    and     $f4, $f4, $f6
    ADDIU   a1, 8
    seq     $f2, $f4
    bc1f    _mc8_1
    psubb   $f8, $f2, $f4
_loop:
    nor     $f2, $f0, $f0
    gsldrc1 $f2, 0(a0)
    ldc1    $f4, 0(a1)
    pcmpeqb $f6, $f2, $f0
    seq     $f0, $f6
    bc1f    _mc8
    ADDIU   a1, 8
    gsldlc1 $f2, 7(a0)
    pcmpeqb $f6, $f2, $f0
    seq     $f0, $f6
    bc1f    _mc8
    seq     $f2, $f4
    bc1t    _loop
    ADDIU   a0, 8

_mc8:
    psubb   $f8, $f2, $f4
_mc8_1:
    pcmpeqb $f6, $f2, $f0
    pcmpeqb $f4, $f2, $f4
    pandn   $f6, $f6, $f4
    dmfc1   v0, $f8
    mfc1    t0, $f6
    mfhc1   t1, $f6
    wsbh    t0, t0
    wsbh    t1, t1
    rotr    t0, 16
    rotr    t1, 16
    dins    t1, t0, 32, 32
    dclo    t0, t1
    dsrl    v0, t0
    andi    v0, 0xff
    seb     v0, v0
    subu    v1, zero, v0
    jr      ra
    movz    v0, v1, t2

    .align  5
    .space  20
_loop_ah:
    nor     $f2, $f0, $f0
    nor     $f4, $f0, $f0
    gsldrc1 $f2, 0(a0)
    gsldrc1 $f4, 0(a1)
    ori     t2, zero, 1
    dins    a0, zero, 0, 3
    pcmpeqb $f6, $f2, $f0
    dins    a1, zero, 0, 3
    seq     $f0, $f6
    bc1f    _mc8
    seq     $f2, $f4
    bc1f    _mc8
    ADDIU   a0, 8
    ADDIU   a1, 8
_loop_a:
    ldc1    $f2, 0(a0)
    ldc1    $f4, 0(a1)
    pcmpeqb $f6, $f2, $f0
    seq     $f0, $f6
    bc1f    _mc8
    ADDIU   a0, 8
    seq     $f2, $f4
    bc1t    _loop_a
    ADDIU   a1, 8
    b       _mc8_1
    psubb   $f8, $f2, $f4

    .end    strcmp
    .size   strcmp, .-strcmp
    .set    pop

