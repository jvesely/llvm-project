//=- AMDGPUCombine.td - Define AMDGPU Combine Rules ----------*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

include "llvm/Target/GlobalISel/Combine.td"

// TODO: This really belongs after legalization after scalarization.
// TODO: GICombineRules should accept subtarget predicates

def fmin_fmax_legacy_matchdata : GIDefMatchData<"AMDGPUPostLegalizerCombinerHelper::FMinFMaxLegacyInfo">;

def fcmp_select_to_fmin_fmax_legacy : GICombineRule<
  (defs root:$select, fmin_fmax_legacy_matchdata:$matchinfo),
  (match (wip_match_opcode G_SELECT):$select,
         [{ return PostLegalizerHelper.matchFMinFMaxLegacy(*${select}, ${matchinfo}); }]),
  (apply [{ PostLegalizerHelper.applySelectFCmpToFMinToFMaxLegacy(*${select}, ${matchinfo}); }])>;


def uchar_to_float : GICombineRule<
  (defs root:$itofp),
  (match (wip_match_opcode G_UITOFP, G_SITOFP):$itofp,
         [{ return PostLegalizerHelper.matchUCharToFloat(*${itofp}); }]),
  (apply [{ PostLegalizerHelper.applyUCharToFloat(*${itofp}); }])>;

def cvt_f32_ubyteN_matchdata : GIDefMatchData<"AMDGPUPostLegalizerCombinerHelper::CvtF32UByteMatchInfo">;

def cvt_f32_ubyteN : GICombineRule<
  (defs root:$cvt_f32_ubyteN, cvt_f32_ubyteN_matchdata:$matchinfo),
  (match (wip_match_opcode G_AMDGPU_CVT_F32_UBYTE0,
                           G_AMDGPU_CVT_F32_UBYTE1,
                           G_AMDGPU_CVT_F32_UBYTE2,
                           G_AMDGPU_CVT_F32_UBYTE3):$cvt_f32_ubyteN,
         [{ return PostLegalizerHelper.matchCvtF32UByteN(*${cvt_f32_ubyteN}, ${matchinfo}); }]),
  (apply [{ PostLegalizerHelper.applyCvtF32UByteN(*${cvt_f32_ubyteN}, ${matchinfo}); }])>;

def clamp_i64_to_i16_matchdata : GIDefMatchData<"AMDGPUPreLegalizerCombinerHelper::ClampI64ToI16MatchInfo">;

def clamp_i64_to_i16 : GICombineRule<
  (defs root:$clamp_i64_to_i16, clamp_i64_to_i16_matchdata:$matchinfo),
  (match (wip_match_opcode G_TRUNC):$clamp_i64_to_i16,
      [{ return PreLegalizerHelper.matchClampI64ToI16(*${clamp_i64_to_i16}, MRI, *MF, ${matchinfo}); }]),
  (apply [{ PreLegalizerHelper.applyClampI64ToI16(*${clamp_i64_to_i16}, ${matchinfo}); }])>;

// Combines which should only apply on SI/VI
def gfx6gfx7_combines : GICombineGroup<[fcmp_select_to_fmin_fmax_legacy]>;

def AMDGPUPreLegalizerCombinerHelper: GICombinerHelper<
  "AMDGPUGenPreLegalizerCombinerHelper", [all_combines, clamp_i64_to_i16]> {
  let DisableRuleOption = "amdgpuprelegalizercombiner-disable-rule";
  let StateClass = "AMDGPUPreLegalizerCombinerHelperState";
}

def AMDGPUPostLegalizerCombinerHelper: GICombinerHelper<
  "AMDGPUGenPostLegalizerCombinerHelper",
  [all_combines, gfx6gfx7_combines,
   uchar_to_float, cvt_f32_ubyteN]> {
  let DisableRuleOption = "amdgpupostlegalizercombiner-disable-rule";
  let StateClass = "AMDGPUPostLegalizerCombinerHelperState";
  let AdditionalArguments = [];
}

def AMDGPURegBankCombinerHelper : GICombinerHelper<
  "AMDGPUGenRegBankCombinerHelper", [zext_trunc_fold]> {
  let DisableRuleOption = "amdgpuregbankcombiner-disable-rule";
}
