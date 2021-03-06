; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s --check-prefixes=CHECK,LITTLE
; RUN: opt -S -instcombine -data-layout="E" < %s | FileCheck %s --check-prefixes=CHECK,BIG

; Some cases where store to load forwarding is principally possible,
; but is non-trivial.

define i8 @load_smaller_int(i16* %p) {
; CHECK-LABEL: @load_smaller_int(
; CHECK-NEXT:    store i16 258, i16* [[P:%.*]], align 2
; CHECK-NEXT:    [[P2:%.*]] = bitcast i16* [[P]] to i8*
; CHECK-NEXT:    [[LOAD:%.*]] = load i8, i8* [[P2]], align 1
; CHECK-NEXT:    ret i8 [[LOAD]]
;
  store i16 258, i16* %p
  %p2 = bitcast i16* %p to i8*
  %load = load i8, i8* %p2
  ret i8 %load
}

define i32 @vec_store_load_first(i32* %p) {
; CHECK-LABEL: @vec_store_load_first(
; CHECK-NEXT:    [[P2:%.*]] = bitcast i32* [[P:%.*]] to <2 x i32>*
; CHECK-NEXT:    store <2 x i32> <i32 1, i32 2>, <2 x i32>* [[P2]], align 8
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    ret i32 [[LOAD]]
;
  %p2 = bitcast i32* %p to <2 x i32>*
  store <2 x i32> <i32 1, i32 2>, <2 x i32>* %p2
  %load = load i32, i32* %p
  ret i32 %load
}

define i32 @vec_store_load_second(i32* %p) {
; CHECK-LABEL: @vec_store_load_second(
; CHECK-NEXT:    [[P2:%.*]] = bitcast i32* [[P:%.*]] to <2 x i32>*
; CHECK-NEXT:    store <2 x i32> <i32 1, i32 2>, <2 x i32>* [[P2]], align 8
; CHECK-NEXT:    [[P3:%.*]] = getelementptr i32, i32* [[P]], i64 1
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, i32* [[P3]], align 4
; CHECK-NEXT:    ret i32 [[LOAD]]
;
  %p2 = bitcast i32* %p to <2 x i32>*
  store <2 x i32> <i32 1, i32 2>, <2 x i32>* %p2
  %p3 = getelementptr i32, i32* %p, i64 1
  %load = load i32, i32* %p3
  ret i32 %load
}

define i64 @vec_store_load_whole(i32* %p) {
; LITTLE-LABEL: @vec_store_load_whole(
; LITTLE-NEXT:    [[P2:%.*]] = bitcast i32* [[P:%.*]] to <2 x i32>*
; LITTLE-NEXT:    store <2 x i32> <i32 1, i32 2>, <2 x i32>* [[P2]], align 8
; LITTLE-NEXT:    ret i64 8589934593
;
; BIG-LABEL: @vec_store_load_whole(
; BIG-NEXT:    [[P2:%.*]] = bitcast i32* [[P:%.*]] to <2 x i32>*
; BIG-NEXT:    store <2 x i32> <i32 1, i32 2>, <2 x i32>* [[P2]], align 8
; BIG-NEXT:    ret i64 4294967298
;
  %p2 = bitcast i32* %p to <2 x i32>*
  store <2 x i32> <i32 1, i32 2>, <2 x i32>* %p2
  %p3 = bitcast i32* %p to i64*
  %load = load i64, i64* %p3
  ret i64 %load
}

define i32 @vec_store_load_overlap(i32* %p) {
; CHECK-LABEL: @vec_store_load_overlap(
; CHECK-NEXT:    [[P2:%.*]] = bitcast i32* [[P:%.*]] to <2 x i32>*
; CHECK-NEXT:    store <2 x i32> <i32 1, i32 2>, <2 x i32>* [[P2]], align 8
; CHECK-NEXT:    [[P3:%.*]] = bitcast i32* [[P]] to i8*
; CHECK-NEXT:    [[P4:%.*]] = getelementptr i8, i8* [[P3]], i64 2
; CHECK-NEXT:    [[P5:%.*]] = bitcast i8* [[P4]] to i32*
; CHECK-NEXT:    [[LOAD:%.*]] = load i32, i32* [[P5]], align 2
; CHECK-NEXT:    ret i32 [[LOAD]]
;
  %p2 = bitcast i32* %p to <2 x i32>*
  store <2 x i32> <i32 1, i32 2>, <2 x i32>* %p2
  %p3 = bitcast i32* %p to i8*
  %p4 = getelementptr i8, i8* %p3, i64 2
  %p5 = bitcast i8* %p4 to i32*
  %load = load i32, i32* %p5, align 2
  ret i32 %load
}
