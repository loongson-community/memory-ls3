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

#define ADDIU   PTR_ADDIU

/* int strcmp (const char *s1, const char *s2); */

    .globl  strcmp
    .ent    strcmp, 0
    .type   strcmp, @function
    .set    push
    .set    noreorder
    .set    noat
    .set    arch=loongson3a

strcmp:
    andi    t0, a0, 0x7
    andi    t1, a1, 0x7
    beq     t0, t1, _loop_ah
    xor     $f0, $f0, $f0

_loop:
    nor     $f2, $f0, $f0
    nor     $f4, $f0, $f0
    gsldrc1 $f2, 0(a0)
    gsldrc1 $f4, 0(a1)
    pcmpeqb $f6, $f2, $f0
    pcmpeqb $f8, $f4, $f0
    or      $f10, $f6, $f8
    seq     $f0, $f10
    bc1f    _ll1
    ADDIU   a0, 8
    gsldlc1 $f2, 7-8(a0)
    gsldlc1 $f4, 7(a1)
    pcmpeqb $f6, $f2, $f0
    seq     $f0, $f6
    mfc1    t0, $f2
    bc1f    _mc8
    mfhc1   t1, $f2
    seq     $f2, $f4
    bc1t    _loop
    ADDIU   a1, 8

_mc8:
    mfc1    t2, $f4
_mc8_1:
    mfhc1   t3, $f4
    wsbh    a0, t0
    rotr    a0, 16
    wsbh    a1, t1
    rotr    a1, 16
    mtc1    a1, $f2
    mthc1   a0, $f2
    wsbh    a0, t2
    rotr    a0, 16
    wsbh    a1, t3
    rotr    a1, 16
    mtc1    a1, $f4
    mthc1   a0, $f4
    psubb   $f8, $f2, $f4
    pcmpeqb $f6, $f2, $f0
    pcmpeqb $f4, $f2, $f4
    nor     $f2, $f0, $f6
    and     $f6, $f2, $f4
    pmovmskb $f6, $f6
    dmfc1   a1, $f8
    mfc1    a0, $f6
    sll     a0, 24
    clo     a0, a0
    sll     a0, 3
    dsllv   a1, a1, a0
    dext    v0, a1, 56, 8
    jr      ra
    seb     v0, v0

_ll1:
    seq     $f0, $f6
    bc1f    _sk1
    seq     $f0, $f8
    gsldlc1 $f2, 7-8(a0)
_sk1:
    bc1f    _sk2
    mfc1    t0, $f2
    gsldlc1 $f4, 7(a1)
_sk2:
    b       _mc8
    mfhc1   t1, $f2

_loop_ah:
    nor     $f2, $f0, $f0
    nor     $f4, $f0, $f0
    gsldrc1 $f2, 0(a0)
    gsldrc1 $f4, 0(a1)
    dins    a0, zero, 0, 3
    dins    a1, zero, 0, 3
    pcmpeqb $f6, $f2, $f0
    pcmpeqb $f8, $f4, $f0
    or      $f6, $f6, $f8
    pcmpeqb $f8, $f2, $f4
    nor     $f8, $f0, $f8
    or      $f10, $f6, $f8
    seq     $f0, $f10
    mfc1    t0, $f2
    bc1f    _mc8
    mfhc1   t1, $f2
    ADDIU   a0, 8
    ADDIU   a1, 8
_loop_a:
    ldc1    $f2, 0(a0)
    ldc1    $f4, 0(a1)
    pcmpeqb $f6, $f2, $f0
    mfc1    t0, $f2
    seq     $f0, $f6
    bc1f    _mc8
    mfhc1   t1, $f2
    ADDIU   a0, 8
    seq     $f2, $f4
    bc1t    _loop_a
    ADDIU   a1, 8
    b       _mc8_1
    mfc1    t2, $f4

    .end    strcmp
    .size   strcmp, .-strcmp
    .set    pop

