#ifdef __AMDGCN__
#  if __clang_major__ >= 7
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5"
#  else
target datalayout = "e-p:32:32-p1:64:64-p2:64:64-p3:32:32-p4:64:64-p5:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64"
#  endif
#elif defined __R600__
#  if __clang_major__ >= 7
target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5"
#  else
target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64"
#  endif
#elif defined __PTX__
#  ifdef __LP64__
target datalayout="e-i64:64-v16:16-v32:32-n16:32:64"
#  else
target datalayout="e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
#  endif
#endif

@__CLC_SUBNORMAL_DISABLE = external global i1

define i1 @__clc_subnormals_disabled() #0 {
  %disable = load i1, i1* @__CLC_SUBNORMAL_DISABLE
  ret i1 %disable
}

attributes #0 = { alwaysinline }
