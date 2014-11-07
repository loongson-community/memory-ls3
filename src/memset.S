/*
 ============================================================================
 Name        : memset.S
 Author      : Heiher <r@hev.cc>
 Version     : 1.0.0
 Copyright   : Copyright (c) 2014 everyone.
 Description : The memset for Loongson 3.
 ============================================================================
 */

#include <sys/asm.h>
#include <sys/regdef.h>

#define ADDU    PTR_ADDU
#define ADDIU   PTR_ADDIU
#define SUBU    PTR_SUBU

/* void * memset (void *a, int c, size_t n); */

    .globl  memset
    .ent    memset, 0
    .type   memset, @function
    .set    push
    .set    noreorder
    .set    noat
    .set    arch=loongson3a

memset:
    sltiu   t0, a2, 16
    move    v0, a0
    bnez    t0, _small
    ADDU    a3, a0, a2

    ins     a1, a1, 8, 8
    ins     a1, a1, 16, 16

    andi    t0, a0, 0xf
    beqz    t0, _8x16a
    dins    a1, a1, 32, 32

    sdr     a1, 0x0(a0)
    sdr     a1, 0x8(a0)
    sdl     a1, 0x8(a0)
    sdl     a1, 0xf(a0)

    SUBU    a0, a0, t0
    ADDIU   a0, a0, 16

_8x16a:
    sltiu   t0, a2, 144
    bnez    t0, _1x16a
    SUBU    a2, a3, a0
    andi    t0, a2, 0x7f
    SUBU    t0, a2, t0
    ADDU    t1, a0, t0
    ADDIU   t1, t1, -128
_8x16a_loop:
    gssq    a1, a1, 0x00(a0)
    gssq    a1, a1, 0x10(a0)
    gssq    a1, a1, 0x20(a0)
    gssq    a1, a1, 0x30(a0)
    gssq    a1, a1, 0x40(a0)
    gssq    a1, a1, 0x50(a0)
    gssq    a1, a1, 0x60(a0)
    gssq    a1, a1, 0x70(a0)
    bnel    a0, t1, _8x16a_loop
    ADDIU   a0, a0, 128

_1x16a:
    andi    t0, a3, 0xf
    SUBU    t1, a3, t0
    beq     a0, t1, _small
    ADDIU   t1, t1, -16
_1x16a_loop:
    gssq    a1, a1, (a0)
    bnel    a0, t1, _1x16a_loop
    ADDIU   a0, a0, 16

_small:
    beq     a0, a3, _quit
    ADDIU   a0, a0, 1
_small_loop:
    sb      a1, -1(a0)
    bne     a0, a3, _small_loop
    ADDIU   a0, a0, 1

_quit:
    jr      ra
    nop

    .end    memset
    .size   memset, .-memset
    .set    pop

