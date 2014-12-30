/*
 ============================================================================
 Name        : strcmp.S
 Author      : Heiher <r@hev.cc>
 Version     : 1.0.0
 Copyright   : Copyright (c) 2014 everyone.
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
    lui     t2, 0x0101
    lui     t3, 0x8080
    ori     t2, 0x0101
    ori     t3, 0x8080
    dins    t2, t2, 32, 32
    dins    t3, t3, 32, 32
_loop:
    ldl     t0, 7(a0)
    ldr     t0, 0(a0)
    ldl     t1, 7(a1)
    ldr     t1, 0(a1)
    bne     t0, t1, _mc8
    dsubu   a2, t0, t2
    nor     a3, zero, t0
    and     a3, a3, t3
    and     a2, a3
    ADDIU   a0, 8
    beqz    a2, _loop
    ADDIU   a1, 8
    jr      ra
    ori     v0, zero, 0
_mc8:
    dext    t2, t0, 0, 8
    beqz    t2, _quit
    dext    t3, t1, 0, 8
    dsrl    t0, 8
    beq     t2, t3, _mc8
    dsrl    t1, 8
_quit:
    jr      ra
    subu    v0, t2, t3

    .end    strcmp
    .size   strcmp, .-strcmp
    .set    pop

