{-# OPTIONS_GHC -w #-}
{-

Open Source Fixedpoint Model-Checker version 2014

(C) Copyright Sebastian Moedersheim 2003,2014
(C) Copyright Paolo Modesti 2012
(C) Copyright Nicklas Bo Jensen 2012
(C) Copyright IBM Corp. 2009
(C) Copyright ETH Zurich (Swiss Federal Institute of Technology) 2003,2007

All Rights Reserved.

-}

module Parser where
import Lexer
import Ast
import Control.Applicative(Applicative(..))

-- parser produced by Happy Version 1.19.4

data HappyAbsSyn 
	= HappyTerminal (Token)
	| HappyErrorToken Int
	| HappyAbsSyn4 (Protocol)
	| HappyAbsSyn5 ([Ident])
	| HappyAbsSyn6 (TypeDecls)
	| HappyAbsSyn7 (TypeDecl)
	| HappyAbsSyn8 (SetDecls)
	| HappyAbsSyn9 (SetDecl)
	| HappyAbsSyn10 (FactDecl)
	| HappyAbsSyn11 (FactDecls)
	| HappyAbsSyn12 (Subprotocols)
	| HappyAbsSyn13 (Subprotocol)
	| HappyAbsSyn14 ([Action])
	| HappyAbsSyn15 (Action)
	| HappyAbsSyn16 (Ident)
	| HappyAbsSyn17 (SetExp)
	| HappyAbsSyn18 (InSetExp)
	| HappyAbsSyn19 ([InSetIdent])
	| HappyAbsSyn20 (InSetIdent)
	| HappyAbsSyn21 (FactExp)
	| HappyAbsSyn22 (Channel)
	| HappyAbsSyn23 (Msg)
	| HappyAbsSyn24 (Key)
	| HappyAbsSyn26 (PublicKey)
	| HappyAbsSyn27 (IdentList)
	| HappyAbsSyn28 (AttackDecls)
	| HappyAbsSyn29 (Attack)
	| HappyAbsSyn30 (AttackAction)

{- to allow type-synonyms as our monads (likely
 - with explicitly-specified bind and return)
 - in Haskell98, it seems that with
 - /type M a = .../, then /(HappyReduction M)/
 - is not allowed.  But Happy is a
 - code-generator that can just substitute it.
type HappyReduction m = 
	   Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> [(Token)] -> m HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> [(Token)] -> m HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> [(Token)] -> m HappyAbsSyn
-}

action_0,
 action_1,
 action_2,
 action_3,
 action_4,
 action_5,
 action_6,
 action_7,
 action_8,
 action_9,
 action_10,
 action_11,
 action_12,
 action_13,
 action_14,
 action_15,
 action_16,
 action_17,
 action_18,
 action_19,
 action_20,
 action_21,
 action_22,
 action_23,
 action_24,
 action_25,
 action_26,
 action_27,
 action_28,
 action_29,
 action_30,
 action_31,
 action_32,
 action_33,
 action_34,
 action_35,
 action_36,
 action_37,
 action_38,
 action_39,
 action_40,
 action_41,
 action_42,
 action_43,
 action_44,
 action_45,
 action_46,
 action_47,
 action_48,
 action_49,
 action_50,
 action_51,
 action_52,
 action_53,
 action_54,
 action_55,
 action_56,
 action_57,
 action_58,
 action_59,
 action_60,
 action_61,
 action_62,
 action_63,
 action_64,
 action_65,
 action_66,
 action_67,
 action_68,
 action_69,
 action_70,
 action_71,
 action_72,
 action_73,
 action_74,
 action_75,
 action_76,
 action_77,
 action_78,
 action_79,
 action_80,
 action_81,
 action_82,
 action_83,
 action_84,
 action_85,
 action_86,
 action_87,
 action_88,
 action_89,
 action_90,
 action_91,
 action_92,
 action_93,
 action_94,
 action_95,
 action_96,
 action_97,
 action_98,
 action_99,
 action_100,
 action_101,
 action_102,
 action_103,
 action_104,
 action_105,
 action_106,
 action_107,
 action_108,
 action_109,
 action_110,
 action_111,
 action_112,
 action_113,
 action_114,
 action_115,
 action_116,
 action_117,
 action_118,
 action_119,
 action_120,
 action_121,
 action_122,
 action_123,
 action_124,
 action_125,
 action_126,
 action_127,
 action_128,
 action_129,
 action_130,
 action_131,
 action_132,
 action_133,
 action_134,
 action_135,
 action_136,
 action_137,
 action_138,
 action_139,
 action_140,
 action_141,
 action_142,
 action_143,
 action_144,
 action_145,
 action_146,
 action_147,
 action_148,
 action_149,
 action_150,
 action_151,
 action_152,
 action_153,
 action_154,
 action_155,
 action_156,
 action_157,
 action_158,
 action_159,
 action_160,
 action_161,
 action_162 :: () => Int -> ({-HappyReduction (HappyIdentity) = -}
	   Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> [(Token)] -> (HappyIdentity) HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> [(Token)] -> (HappyIdentity) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> [(Token)] -> (HappyIdentity) HappyAbsSyn)

happyReduce_1,
 happyReduce_2,
 happyReduce_3,
 happyReduce_4,
 happyReduce_5,
 happyReduce_6,
 happyReduce_7,
 happyReduce_8,
 happyReduce_9,
 happyReduce_10,
 happyReduce_11,
 happyReduce_12,
 happyReduce_13,
 happyReduce_14,
 happyReduce_15,
 happyReduce_16,
 happyReduce_17,
 happyReduce_18,
 happyReduce_19,
 happyReduce_20,
 happyReduce_21,
 happyReduce_22,
 happyReduce_23,
 happyReduce_24,
 happyReduce_25,
 happyReduce_26,
 happyReduce_27,
 happyReduce_28,
 happyReduce_29,
 happyReduce_30,
 happyReduce_31,
 happyReduce_32,
 happyReduce_33,
 happyReduce_34,
 happyReduce_35,
 happyReduce_36,
 happyReduce_37,
 happyReduce_38,
 happyReduce_39,
 happyReduce_40,
 happyReduce_41,
 happyReduce_42,
 happyReduce_43,
 happyReduce_44,
 happyReduce_45,
 happyReduce_46,
 happyReduce_47,
 happyReduce_48,
 happyReduce_49,
 happyReduce_50,
 happyReduce_51,
 happyReduce_52,
 happyReduce_53,
 happyReduce_54,
 happyReduce_55,
 happyReduce_56,
 happyReduce_57,
 happyReduce_58,
 happyReduce_59,
 happyReduce_60,
 happyReduce_61 :: () => ({-HappyReduction (HappyIdentity) = -}
	   Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> [(Token)] -> (HappyIdentity) HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> [(Token)] -> (HappyIdentity) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> [(Token)] -> (HappyIdentity) HappyAbsSyn)

action_0 (60) = happyShift action_2
action_0 (4) = happyGoto action_3
action_0 _ = happyFail

action_1 (60) = happyShift action_2
action_1 _ = happyFail

action_2 (39) = happyShift action_4
action_2 _ = happyFail

action_3 (66) = happyAccept
action_3 _ = happyFail

action_4 (31) = happyShift action_5
action_4 _ = happyFail

action_5 (61) = happyShift action_6
action_5 _ = happyFail

action_6 (39) = happyShift action_7
action_6 _ = happyFail

action_7 (31) = happyShift action_11
action_7 (5) = happyGoto action_8
action_7 (6) = happyGoto action_9
action_7 (7) = happyGoto action_10
action_7 _ = happyFail

action_8 (39) = happyShift action_15
action_8 _ = happyFail

action_9 (62) = happyShift action_14
action_9 _ = happyFail

action_10 (31) = happyShift action_11
action_10 (5) = happyGoto action_8
action_10 (6) = happyGoto action_13
action_10 (7) = happyGoto action_10
action_10 _ = happyReduce_4

action_11 (43) = happyShift action_12
action_11 _ = happyReduce_2

action_12 (31) = happyShift action_11
action_12 (5) = happyGoto action_19
action_12 _ = happyFail

action_13 _ = happyReduce_5

action_14 (39) = happyShift action_18
action_14 _ = happyFail

action_15 (31) = happyShift action_16
action_15 (37) = happyShift action_17
action_15 _ = happyFail

action_16 _ = happyReduce_7

action_17 (31) = happyShift action_11
action_17 (5) = happyGoto action_23
action_17 _ = happyFail

action_18 (31) = happyShift action_22
action_18 (8) = happyGoto action_20
action_18 (9) = happyGoto action_21
action_18 _ = happyFail

action_19 _ = happyReduce_3

action_20 (63) = happyShift action_27
action_20 _ = happyFail

action_21 (43) = happyShift action_26
action_21 _ = happyReduce_8

action_22 (33) = happyShift action_25
action_22 _ = happyFail

action_23 (38) = happyShift action_24
action_23 _ = happyFail

action_24 _ = happyReduce_6

action_25 (31) = happyShift action_11
action_25 (5) = happyGoto action_30
action_25 _ = happyFail

action_26 (31) = happyShift action_22
action_26 (8) = happyGoto action_29
action_26 (9) = happyGoto action_21
action_26 _ = happyFail

action_27 (39) = happyShift action_28
action_27 _ = happyFail

action_28 (31) = happyShift action_34
action_28 (10) = happyGoto action_32
action_28 (11) = happyGoto action_33
action_28 _ = happyFail

action_29 _ = happyReduce_9

action_30 (34) = happyShift action_31
action_30 _ = happyFail

action_31 _ = happyReduce_10

action_32 (43) = happyShift action_37
action_32 _ = happyReduce_12

action_33 (64) = happyShift action_36
action_33 _ = happyFail

action_34 (41) = happyShift action_35
action_34 _ = happyFail

action_35 (32) = happyShift action_40
action_35 _ = happyFail

action_36 (39) = happyShift action_39
action_36 _ = happyFail

action_37 (31) = happyShift action_34
action_37 (10) = happyGoto action_32
action_37 (11) = happyGoto action_38
action_37 _ = happyFail

action_38 _ = happyReduce_13

action_39 (31) = happyShift action_47
action_39 (45) = happyShift action_48
action_39 (12) = happyGoto action_41
action_39 (13) = happyGoto action_42
action_39 (14) = happyGoto action_43
action_39 (15) = happyGoto action_44
action_39 (16) = happyGoto action_45
action_39 (22) = happyGoto action_46
action_39 _ = happyFail

action_40 _ = happyReduce_11

action_41 (65) = happyShift action_62
action_41 _ = happyFail

action_42 (44) = happyShift action_61
action_42 _ = happyReduce_14

action_43 _ = happyReduce_16

action_44 (31) = happyShift action_47
action_44 (45) = happyShift action_48
action_44 (14) = happyGoto action_60
action_44 (15) = happyGoto action_44
action_44 (16) = happyGoto action_45
action_44 (22) = happyGoto action_46
action_44 _ = happyReduce_17

action_45 (31) = happyShift action_54
action_45 (46) = happyShift action_55
action_45 (47) = happyShift action_56
action_45 (48) = happyShift action_57
action_45 (50) = happyShift action_58
action_45 (51) = happyShift action_59
action_45 (21) = happyGoto action_53
action_45 _ = happyFail

action_46 (39) = happyShift action_52
action_46 _ = happyFail

action_47 (39) = happyShift action_50
action_47 (42) = happyShift action_51
action_47 _ = happyFail

action_48 (42) = happyShift action_49
action_48 _ = happyFail

action_49 (31) = happyShift action_87
action_49 _ = happyFail

action_50 _ = happyReduce_29

action_51 (31) = happyShift action_85
action_51 (45) = happyShift action_86
action_51 _ = happyFail

action_52 (31) = happyShift action_77
action_52 (33) = happyShift action_78
action_52 (35) = happyShift action_79
action_52 (37) = happyShift action_80
action_52 (54) = happyShift action_81
action_52 (55) = happyShift action_82
action_52 (56) = happyShift action_83
action_52 (57) = happyShift action_84
action_52 (23) = happyGoto action_72
action_52 (24) = happyGoto action_73
action_52 (25) = happyGoto action_74
action_52 (26) = happyGoto action_75
action_52 (27) = happyGoto action_76
action_52 _ = happyFail

action_53 _ = happyReduce_24

action_54 (33) = happyShift action_71
action_54 _ = happyFail

action_55 (33) = happyShift action_70
action_55 _ = happyFail

action_56 (33) = happyShift action_69
action_56 _ = happyFail

action_57 (31) = happyShift action_68
action_57 _ = happyFail

action_58 (33) = happyShift action_67
action_58 _ = happyFail

action_59 (31) = happyShift action_66
action_59 (21) = happyGoto action_65
action_59 _ = happyFail

action_60 _ = happyReduce_18

action_61 (31) = happyShift action_47
action_61 (45) = happyShift action_48
action_61 (12) = happyGoto action_64
action_61 (13) = happyGoto action_42
action_61 (14) = happyGoto action_43
action_61 (15) = happyGoto action_44
action_61 (16) = happyGoto action_45
action_61 (22) = happyGoto action_46
action_61 _ = happyFail

action_62 (39) = happyShift action_63
action_62 _ = happyFail

action_63 (58) = happyShift action_106
action_63 (59) = happyShift action_107
action_63 (28) = happyGoto action_103
action_63 (29) = happyGoto action_104
action_63 (30) = happyGoto action_105
action_63 _ = happyFail

action_64 _ = happyReduce_15

action_65 _ = happyReduce_25

action_66 (33) = happyShift action_71
action_66 (52) = happyShift action_101
action_66 (53) = happyShift action_102
action_66 _ = happyFail

action_67 (31) = happyShift action_100
action_67 _ = happyFail

action_68 (49) = happyShift action_99
action_68 _ = happyFail

action_69 (31) = happyShift action_98
action_69 _ = happyFail

action_70 (31) = happyShift action_97
action_70 _ = happyFail

action_71 (31) = happyShift action_77
action_71 (33) = happyShift action_78
action_71 (35) = happyShift action_79
action_71 (37) = happyShift action_80
action_71 (55) = happyShift action_82
action_71 (56) = happyShift action_83
action_71 (57) = happyShift action_84
action_71 (23) = happyGoto action_96
action_71 (24) = happyGoto action_73
action_71 (25) = happyGoto action_74
action_71 (26) = happyGoto action_75
action_71 (27) = happyGoto action_76
action_71 _ = happyFail

action_72 (43) = happyShift action_95
action_72 _ = happyReduce_27

action_73 _ = happyReduce_44

action_74 _ = happyReduce_47

action_75 _ = happyReduce_48

action_76 _ = happyReduce_49

action_77 (33) = happyShift action_94
action_77 _ = happyReduce_40

action_78 (31) = happyShift action_77
action_78 (33) = happyShift action_78
action_78 (35) = happyShift action_79
action_78 (37) = happyShift action_80
action_78 (55) = happyShift action_82
action_78 (56) = happyShift action_83
action_78 (57) = happyShift action_84
action_78 (23) = happyGoto action_93
action_78 (24) = happyGoto action_73
action_78 (25) = happyGoto action_74
action_78 (26) = happyGoto action_75
action_78 (27) = happyGoto action_76
action_78 _ = happyFail

action_79 (31) = happyShift action_77
action_79 (33) = happyShift action_78
action_79 (35) = happyShift action_79
action_79 (37) = happyShift action_80
action_79 (55) = happyShift action_82
action_79 (56) = happyShift action_83
action_79 (57) = happyShift action_84
action_79 (23) = happyGoto action_92
action_79 (24) = happyGoto action_73
action_79 (25) = happyGoto action_74
action_79 (26) = happyGoto action_75
action_79 (27) = happyGoto action_76
action_79 _ = happyFail

action_80 (31) = happyShift action_77
action_80 (33) = happyShift action_78
action_80 (35) = happyShift action_79
action_80 (37) = happyShift action_80
action_80 (55) = happyShift action_82
action_80 (56) = happyShift action_83
action_80 (57) = happyShift action_84
action_80 (23) = happyGoto action_91
action_80 (24) = happyGoto action_73
action_80 (25) = happyGoto action_74
action_80 (26) = happyGoto action_75
action_80 (27) = happyGoto action_76
action_80 _ = happyFail

action_81 _ = happyReduce_28

action_82 (33) = happyShift action_90
action_82 _ = happyFail

action_83 (33) = happyShift action_89
action_83 _ = happyFail

action_84 (33) = happyShift action_88
action_84 _ = happyFail

action_85 _ = happyReduce_37

action_86 _ = happyReduce_38

action_87 _ = happyReduce_39

action_88 (31) = happyShift action_11
action_88 (5) = happyGoto action_128
action_88 _ = happyFail

action_89 (31) = happyShift action_127
action_89 _ = happyFail

action_90 (31) = happyShift action_126
action_90 _ = happyFail

action_91 (38) = happyShift action_125
action_91 (43) = happyShift action_95
action_91 _ = happyFail

action_92 (36) = happyShift action_124
action_92 (43) = happyShift action_95
action_92 _ = happyFail

action_93 (34) = happyShift action_123
action_93 (43) = happyShift action_95
action_93 _ = happyFail

action_94 (31) = happyShift action_77
action_94 (33) = happyShift action_78
action_94 (35) = happyShift action_79
action_94 (37) = happyShift action_80
action_94 (55) = happyShift action_82
action_94 (56) = happyShift action_83
action_94 (57) = happyShift action_84
action_94 (23) = happyGoto action_122
action_94 (24) = happyGoto action_73
action_94 (25) = happyGoto action_74
action_94 (26) = happyGoto action_75
action_94 (27) = happyGoto action_76
action_94 _ = happyFail

action_95 (31) = happyShift action_77
action_95 (33) = happyShift action_78
action_95 (35) = happyShift action_79
action_95 (37) = happyShift action_80
action_95 (55) = happyShift action_82
action_95 (56) = happyShift action_83
action_95 (57) = happyShift action_84
action_95 (23) = happyGoto action_121
action_95 (24) = happyGoto action_73
action_95 (25) = happyGoto action_74
action_95 (26) = happyGoto action_75
action_95 (27) = happyGoto action_76
action_95 _ = happyFail

action_96 (34) = happyShift action_120
action_96 (43) = happyShift action_95
action_96 _ = happyFail

action_97 (43) = happyShift action_119
action_97 _ = happyFail

action_98 (43) = happyShift action_118
action_98 _ = happyFail

action_99 (31) = happyShift action_117
action_99 (17) = happyGoto action_116
action_99 _ = happyFail

action_100 (34) = happyShift action_115
action_100 _ = happyFail

action_101 (31) = happyShift action_113
action_101 (18) = happyGoto action_114
action_101 _ = happyFail

action_102 (31) = happyShift action_113
action_102 (18) = happyGoto action_112
action_102 _ = happyFail

action_103 _ = happyReduce_1

action_104 (44) = happyShift action_111
action_104 _ = happyReduce_53

action_105 (58) = happyShift action_106
action_105 (59) = happyShift action_107
action_105 (29) = happyGoto action_110
action_105 (30) = happyGoto action_105
action_105 _ = happyReduce_55

action_106 (39) = happyShift action_109
action_106 _ = happyFail

action_107 (39) = happyShift action_108
action_107 _ = happyFail

action_108 (31) = happyShift action_77
action_108 (33) = happyShift action_78
action_108 (35) = happyShift action_79
action_108 (37) = happyShift action_80
action_108 (55) = happyShift action_82
action_108 (56) = happyShift action_83
action_108 (57) = happyShift action_84
action_108 (23) = happyGoto action_142
action_108 (24) = happyGoto action_73
action_108 (25) = happyGoto action_74
action_108 (26) = happyGoto action_75
action_108 (27) = happyGoto action_76
action_108 _ = happyFail

action_109 (48) = happyShift action_140
action_109 (51) = happyShift action_141
action_109 _ = happyFail

action_110 _ = happyReduce_56

action_111 (58) = happyShift action_106
action_111 (59) = happyShift action_107
action_111 (28) = happyGoto action_139
action_111 (29) = happyGoto action_104
action_111 (30) = happyGoto action_105
action_111 _ = happyFail

action_112 _ = happyReduce_26

action_113 (33) = happyShift action_138
action_113 _ = happyFail

action_114 _ = happyReduce_23

action_115 _ = happyReduce_22

action_116 _ = happyReduce_21

action_117 (33) = happyShift action_137
action_117 _ = happyFail

action_118 (31) = happyShift action_117
action_118 (17) = happyGoto action_136
action_118 _ = happyFail

action_119 (31) = happyShift action_117
action_119 (17) = happyGoto action_135
action_119 _ = happyFail

action_120 _ = happyReduce_36

action_121 (43) = happyShift action_95
action_121 _ = happyReduce_41

action_122 (34) = happyShift action_134
action_122 (43) = happyShift action_95
action_122 _ = happyFail

action_123 _ = happyReduce_46

action_124 (55) = happyShift action_82
action_124 (56) = happyShift action_83
action_124 (57) = happyShift action_84
action_124 (24) = happyGoto action_133
action_124 (25) = happyGoto action_74
action_124 (26) = happyGoto action_75
action_124 (27) = happyGoto action_76
action_124 _ = happyFail

action_125 (55) = happyShift action_82
action_125 (56) = happyShift action_83
action_125 (57) = happyShift action_84
action_125 (24) = happyGoto action_132
action_125 (25) = happyGoto action_74
action_125 (26) = happyGoto action_75
action_125 (27) = happyGoto action_76
action_125 _ = happyFail

action_126 (34) = happyShift action_131
action_126 _ = happyFail

action_127 (34) = happyShift action_130
action_127 _ = happyFail

action_128 (34) = happyShift action_129
action_128 _ = happyFail

action_129 _ = happyReduce_52

action_130 _ = happyReduce_51

action_131 _ = happyReduce_50

action_132 _ = happyReduce_42

action_133 _ = happyReduce_43

action_134 _ = happyReduce_45

action_135 (34) = happyShift action_152
action_135 _ = happyFail

action_136 (34) = happyShift action_151
action_136 _ = happyFail

action_137 (31) = happyShift action_11
action_137 (5) = happyGoto action_150
action_137 _ = happyFail

action_138 (31) = happyShift action_148
action_138 (45) = happyShift action_149
action_138 (19) = happyGoto action_146
action_138 (20) = happyGoto action_147
action_138 _ = happyFail

action_139 _ = happyReduce_54

action_140 (31) = happyShift action_145
action_140 _ = happyFail

action_141 (31) = happyShift action_144
action_141 (21) = happyGoto action_143
action_141 _ = happyFail

action_142 (43) = happyShift action_95
action_142 _ = happyReduce_57

action_143 _ = happyReduce_61

action_144 (33) = happyShift action_71
action_144 (52) = happyShift action_157
action_144 (53) = happyShift action_158
action_144 _ = happyFail

action_145 (49) = happyShift action_156
action_145 _ = happyFail

action_146 (34) = happyShift action_155
action_146 _ = happyFail

action_147 (43) = happyShift action_154
action_147 _ = happyReduce_32

action_148 _ = happyReduce_34

action_149 _ = happyReduce_35

action_150 (34) = happyShift action_153
action_150 _ = happyFail

action_151 _ = happyReduce_20

action_152 _ = happyReduce_19

action_153 _ = happyReduce_30

action_154 (31) = happyShift action_148
action_154 (45) = happyShift action_149
action_154 (19) = happyGoto action_162
action_154 (20) = happyGoto action_147
action_154 _ = happyFail

action_155 _ = happyReduce_31

action_156 (31) = happyShift action_117
action_156 (17) = happyGoto action_161
action_156 _ = happyFail

action_157 (31) = happyShift action_113
action_157 (18) = happyGoto action_160
action_157 _ = happyFail

action_158 (31) = happyShift action_113
action_158 (18) = happyGoto action_159
action_158 _ = happyFail

action_159 _ = happyReduce_60

action_160 _ = happyReduce_59

action_161 _ = happyReduce_58

action_162 _ = happyReduce_33

happyReduce_1 = happyReduce 18 4 happyReduction_1
happyReduction_1 ((HappyAbsSyn28  happy_var_18) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn12  happy_var_15) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn11  happy_var_12) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn8  happy_var_9) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn6  happy_var_6) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_3)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn4
		 ((happy_var_3,happy_var_6,happy_var_9,happy_var_12,happy_var_15,happy_var_18)
	) `HappyStk` happyRest

happyReduce_2 = happySpecReduce_1  5 happyReduction_2
happyReduction_2 (HappyTerminal (TATOM _ happy_var_1))
	 =  HappyAbsSyn5
		 ([happy_var_1]
	)
happyReduction_2 _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_3  5 happyReduction_3
happyReduction_3 (HappyAbsSyn5  happy_var_3)
	_
	(HappyTerminal (TATOM _ happy_var_1))
	 =  HappyAbsSyn5
		 (happy_var_1:happy_var_3
	)
happyReduction_3 _ _ _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_1  6 happyReduction_4
happyReduction_4 (HappyAbsSyn7  happy_var_1)
	 =  HappyAbsSyn6
		 ([happy_var_1]
	)
happyReduction_4 _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_2  6 happyReduction_5
happyReduction_5 (HappyAbsSyn6  happy_var_2)
	(HappyAbsSyn7  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1:happy_var_2
	)
happyReduction_5 _ _  = notHappyAtAll 

happyReduce_6 = happyReduce 5 7 happyReduction_6
happyReduction_6 (_ `HappyStk`
	(HappyAbsSyn5  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn5  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn7
		 ((happy_var_1,happy_var_4,True)
	) `HappyStk` happyRest

happyReduce_7 = happySpecReduce_3  7 happyReduction_7
happyReduction_7 (HappyTerminal (TATOM _ happy_var_3))
	_
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn7
		 ((happy_var_1,[happy_var_3],False)
	)
happyReduction_7 _ _ _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_1  8 happyReduction_8
happyReduction_8 (HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn8
		 ([happy_var_1]
	)
happyReduction_8 _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_3  8 happyReduction_9
happyReduction_9 (HappyAbsSyn8  happy_var_3)
	_
	(HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn8
		 (happy_var_1:happy_var_3
	)
happyReduction_9 _ _ _  = notHappyAtAll 

happyReduce_10 = happyReduce 4 9 happyReduction_10
happyReduction_10 (_ `HappyStk`
	(HappyAbsSyn5  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_1)) `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 ((happy_var_1,happy_var_3)
	) `HappyStk` happyRest

happyReduce_11 = happySpecReduce_3  10 happyReduction_11
happyReduction_11 (HappyTerminal (TNUMBER _ happy_var_3))
	_
	(HappyTerminal (TATOM _ happy_var_1))
	 =  HappyAbsSyn10
		 ((happy_var_1,read happy_var_3)
	)
happyReduction_11 _ _ _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_1  11 happyReduction_12
happyReduction_12 (HappyAbsSyn10  happy_var_1)
	 =  HappyAbsSyn11
		 ([happy_var_1]
	)
happyReduction_12 _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_3  11 happyReduction_13
happyReduction_13 (HappyAbsSyn11  happy_var_3)
	_
	(HappyAbsSyn10  happy_var_1)
	 =  HappyAbsSyn11
		 (happy_var_1:happy_var_3
	)
happyReduction_13 _ _ _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_1  12 happyReduction_14
happyReduction_14 (HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn12
		 ([happy_var_1]
	)
happyReduction_14 _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_3  12 happyReduction_15
happyReduction_15 (HappyAbsSyn12  happy_var_3)
	_
	(HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn12
		 (happy_var_1:happy_var_3
	)
happyReduction_15 _ _ _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_1  13 happyReduction_16
happyReduction_16 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn13
		 (happy_var_1
	)
happyReduction_16 _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_1  14 happyReduction_17
happyReduction_17 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 ([happy_var_1]
	)
happyReduction_17 _  = notHappyAtAll 

happyReduce_18 = happySpecReduce_2  14 happyReduction_18
happyReduction_18 (HappyAbsSyn14  happy_var_2)
	(HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (happy_var_1:happy_var_2
	)
happyReduction_18 _ _  = notHappyAtAll 

happyReduce_19 = happyReduce 7 15 happyReduction_19
happyReduction_19 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_4)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (Insert happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_20 = happyReduce 7 15 happyReduction_20
happyReduction_20 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_4)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (Delete happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_21 = happyReduce 5 15 happyReduction_21
happyReduction_21 ((HappyAbsSyn17  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_3)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (Select happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_22 = happyReduce 5 15 happyReduction_22
happyReduction_22 (_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_4)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (Create happy_var_4
	) `HappyStk` happyRest

happyReduce_23 = happyReduce 5 15 happyReduction_23
happyReduction_23 ((HappyAbsSyn18  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_3)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (Ifnotin happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_24 = happySpecReduce_2  15 happyReduction_24
happyReduction_24 (HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn15
		 (Fact happy_var_2
	)
happyReduction_24 _ _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_3  15 happyReduction_25
happyReduction_25 (HappyAbsSyn21  happy_var_3)
	_
	_
	 =  HappyAbsSyn15
		 (Iffact happy_var_3
	)
happyReduction_25 _ _ _  = notHappyAtAll 

happyReduce_26 = happyReduce 5 15 happyReduction_26
happyReduction_26 ((HappyAbsSyn18  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_3)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (Ifin happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_27 = happySpecReduce_3  15 happyReduction_27
happyReduction_27 (HappyAbsSyn23  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn15
		 (Transmission happy_var_1 happy_var_3
	)
happyReduction_27 _ _ _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_3  15 happyReduction_28
happyReduction_28 _
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn15
		 (Sync happy_var_1
	)
happyReduction_28 _ _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_2  16 happyReduction_29
happyReduction_29 _
	(HappyTerminal (TATOM _ happy_var_1))
	 =  HappyAbsSyn16
		 (happy_var_1
	)
happyReduction_29 _ _  = notHappyAtAll 

happyReduce_30 = happyReduce 4 17 happyReduction_30
happyReduction_30 (_ `HappyStk`
	(HappyAbsSyn5  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_1)) `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 ((happy_var_1,happy_var_3)
	) `HappyStk` happyRest

happyReduce_31 = happyReduce 4 18 happyReduction_31
happyReduction_31 (_ `HappyStk`
	(HappyAbsSyn19  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_1)) `HappyStk`
	happyRest)
	 = HappyAbsSyn18
		 ((happy_var_1,happy_var_3)
	) `HappyStk` happyRest

happyReduce_32 = happySpecReduce_1  19 happyReduction_32
happyReduction_32 (HappyAbsSyn20  happy_var_1)
	 =  HappyAbsSyn19
		 ([happy_var_1]
	)
happyReduction_32 _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_3  19 happyReduction_33
happyReduction_33 (HappyAbsSyn19  happy_var_3)
	_
	(HappyAbsSyn20  happy_var_1)
	 =  HappyAbsSyn19
		 (happy_var_1:happy_var_3
	)
happyReduction_33 _ _ _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_1  20 happyReduction_34
happyReduction_34 (HappyTerminal (TATOM _ happy_var_1))
	 =  HappyAbsSyn20
		 (Ident happy_var_1
	)
happyReduction_34 _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_1  20 happyReduction_35
happyReduction_35 _
	 =  HappyAbsSyn20
		 (Underscore "_"
	)

happyReduce_36 = happyReduce 4 21 happyReduction_36
happyReduction_36 (_ `HappyStk`
	(HappyAbsSyn23  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_1)) `HappyStk`
	happyRest)
	 = HappyAbsSyn21
		 ((happy_var_1,happy_var_3)
	) `HappyStk` happyRest

happyReduce_37 = happySpecReduce_3  22 happyReduction_37
happyReduction_37 (HappyTerminal (TATOM _ happy_var_3))
	_
	(HappyTerminal (TATOM _ happy_var_1))
	 =  HappyAbsSyn22
		 ((happy_var_1,happy_var_3)
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_3  22 happyReduction_38
happyReduction_38 _
	_
	(HappyTerminal (TATOM _ happy_var_1))
	 =  HappyAbsSyn22
		 ((happy_var_1,"_")
	)
happyReduction_38 _ _ _  = notHappyAtAll 

happyReduce_39 = happySpecReduce_3  22 happyReduction_39
happyReduction_39 (HappyTerminal (TATOM _ happy_var_3))
	_
	_
	 =  HappyAbsSyn22
		 (("_",happy_var_3)
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_1  23 happyReduction_40
happyReduction_40 (HappyTerminal (TATOM _ happy_var_1))
	 =  HappyAbsSyn23
		 (Atom happy_var_1
	)
happyReduction_40 _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_3  23 happyReduction_41
happyReduction_41 (HappyAbsSyn23  happy_var_3)
	_
	(HappyAbsSyn23  happy_var_1)
	 =  HappyAbsSyn23
		 (Cat happy_var_1 happy_var_3
	)
happyReduction_41 _ _ _  = notHappyAtAll 

happyReduce_42 = happyReduce 4 23 happyReduction_42
happyReduction_42 ((HappyAbsSyn24  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn23  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn23
		 (Crypt happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_43 = happyReduce 4 23 happyReduction_43
happyReduction_43 ((HappyAbsSyn24  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn23  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn23
		 (Scrypt happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_44 = happySpecReduce_1  23 happyReduction_44
happyReduction_44 (HappyAbsSyn24  happy_var_1)
	 =  HappyAbsSyn23
		 (Key happy_var_1
	)
happyReduction_44 _  = notHappyAtAll 

happyReduce_45 = happyReduce 4 23 happyReduction_45
happyReduction_45 (_ `HappyStk`
	(HappyAbsSyn23  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_1)) `HappyStk`
	happyRest)
	 = HappyAbsSyn23
		 (FactExp happy_var_1 happy_var_3
	) `HappyStk` happyRest

happyReduce_46 = happySpecReduce_3  23 happyReduction_46
happyReduction_46 _
	(HappyAbsSyn23  happy_var_2)
	_
	 =  HappyAbsSyn23
		 (happy_var_2
	)
happyReduction_46 _ _ _  = notHappyAtAll 

happyReduce_47 = happySpecReduce_1  24 happyReduction_47
happyReduction_47 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn24
		 (PublicKey happy_var_1
	)
happyReduction_47 _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_1  24 happyReduction_48
happyReduction_48 (HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn24
		 (PrivateKey happy_var_1
	)
happyReduction_48 _  = notHappyAtAll 

happyReduce_49 = happySpecReduce_1  24 happyReduction_49
happyReduction_49 (HappyAbsSyn27  happy_var_1)
	 =  HappyAbsSyn24
		 (SharedKey happy_var_1
	)
happyReduction_49 _  = notHappyAtAll 

happyReduce_50 = happyReduce 4 25 happyReduction_50
happyReduction_50 (_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_3)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn16
		 (happy_var_3
	) `HappyStk` happyRest

happyReduce_51 = happyReduce 4 26 happyReduction_51
happyReduction_51 (_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_3)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn26
		 (happy_var_3
	) `HappyStk` happyRest

happyReduce_52 = happyReduce 4 27 happyReduction_52
happyReduction_52 (_ `HappyStk`
	(HappyAbsSyn5  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn27
		 (happy_var_3
	) `HappyStk` happyRest

happyReduce_53 = happySpecReduce_1  28 happyReduction_53
happyReduction_53 (HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn28
		 ([happy_var_1]
	)
happyReduction_53 _  = notHappyAtAll 

happyReduce_54 = happySpecReduce_3  28 happyReduction_54
happyReduction_54 (HappyAbsSyn28  happy_var_3)
	_
	(HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn28
		 (happy_var_1:happy_var_3
	)
happyReduction_54 _ _ _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_1  29 happyReduction_55
happyReduction_55 (HappyAbsSyn30  happy_var_1)
	 =  HappyAbsSyn29
		 ([happy_var_1]
	)
happyReduction_55 _  = notHappyAtAll 

happyReduce_56 = happySpecReduce_2  29 happyReduction_56
happyReduction_56 (HappyAbsSyn29  happy_var_2)
	(HappyAbsSyn30  happy_var_1)
	 =  HappyAbsSyn29
		 (happy_var_1:happy_var_2
	)
happyReduction_56 _ _  = notHappyAtAll 

happyReduce_57 = happySpecReduce_3  30 happyReduction_57
happyReduction_57 (HappyAbsSyn23  happy_var_3)
	_
	_
	 =  HappyAbsSyn30
		 (ToRefAction happy_var_3
	)
happyReduction_57 _ _ _  = notHappyAtAll 

happyReduce_58 = happyReduce 6 30 happyReduction_58
happyReduction_58 ((HappyAbsSyn17  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_4)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn30
		 (RefSelect happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_59 = happyReduce 6 30 happyReduction_59
happyReduction_59 ((HappyAbsSyn18  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_4)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn30
		 (RefIfnotin happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_60 = happyReduce 6 30 happyReduction_60
happyReduction_60 ((HappyAbsSyn18  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TATOM _ happy_var_4)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn30
		 (RefIfin happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_61 = happyReduce 4 30 happyReduction_61
happyReduction_61 ((HappyAbsSyn21  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn30
		 (RefIffact happy_var_4
	) `HappyStk` happyRest

happyNewToken action sts stk [] =
	action 66 66 notHappyAtAll (HappyState action) sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = action i i tk (HappyState action) sts stk tks in
	case tk of {
	TATOM _ happy_dollar_dollar -> cont 31;
	TNUMBER _ happy_dollar_dollar -> cont 32;
	TOPENP _ -> cont 33;
	TCLOSEP _ -> cont 34;
	TOPENSCRYPT _ -> cont 35;
	TCLOSESCRYPT _ -> cont 36;
	TOPENB _ -> cont 37;
	TCLOSEB _ -> cont 38;
	TCOLON _ -> cont 39;
	TSEMICOLON _ -> cont 40;
	TSLASH _ -> cont 41;
	TCHANNEL _ -> cont 42;
	TCOMMA _ -> cont 43;
	TSEPARATOR _ -> cont 44;
	TUNDERSCORE _ -> cont 45;
	TINSERT _ -> cont 46;
	TDELETE _ -> cont 47;
	TSELECT _ -> cont 48;
	TFROM _ -> cont 49;
	TCREATE _ -> cont 50;
	TIF _ -> cont 51;
	TNOTIN _ -> cont 52;
	TIN _ -> cont 53;
	TSYNC _ -> cont 54;
	TPUBKEY _ -> cont 55;
	TINV _ -> cont 56;
	TSK _ -> cont 57;
	TREFEREE _ -> cont 58;
	TTOREFEREE _ -> cont 59;
	TPROTOCOL _ -> cont 60;
	TTYPES _ -> cont 61;
	TSETS _ -> cont 62;
	TFACTS _ -> cont 63;
	TSUBPROTOCOLS _ -> cont 64;
	TATTACKS _ -> cont 65;
	_ -> happyError' (tk:tks)
	}

happyError_ 66 tk tks = happyError' tks
happyError_ _ tk tks = happyError' (tk:tks)

newtype HappyIdentity a = HappyIdentity a
happyIdentity = HappyIdentity
happyRunIdentity (HappyIdentity a) = a

instance Functor HappyIdentity where
    fmap f (HappyIdentity a) = HappyIdentity (f a)

instance Applicative HappyIdentity where
    pure    = return
    a <*> b = (fmap id a) <*> b
instance Monad HappyIdentity where
    return = HappyIdentity
    (HappyIdentity p) >>= q = q p

happyThen :: () => HappyIdentity a -> (a -> HappyIdentity b) -> HappyIdentity b
happyThen = (>>=)
happyReturn :: () => a -> HappyIdentity a
happyReturn = (return)
happyThen1 m k tks = (>>=) m (\a -> k a tks)
happyReturn1 :: () => a -> b -> HappyIdentity a
happyReturn1 = \a tks -> (return) a
happyError' :: () => [(Token)] -> HappyIdentity a
happyError' = HappyIdentity . happyError

anbparser tks = happyRunIdentity happySomeParser where
  happySomeParser = happyThen (happyParse action_0 tks) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


happyError :: [Token] -> a
happyError tks = error ("AnB Parse error at " ++ lcn ++ "\n" )
	where
	lcn = 	case tks of
		  [] -> "end of file"
		  tk:_ -> "line " ++ show l ++ ", column " ++ show c ++ " - Token: " ++ show tk
			where
			AlexPn _ l c = token_posn tk
{-# LINE 1 "templates/GenericTemplate.hs" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
{-# LINE 1 "<built-in>" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp 


{-# LINE 13 "templates/GenericTemplate.hs" #-}


{-# LINE 46 "templates/GenericTemplate.hs" #-}









{-# LINE 67 "templates/GenericTemplate.hs" #-}


{-# LINE 77 "templates/GenericTemplate.hs" #-}










infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is (1), it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action


{-# LINE 155 "templates/GenericTemplate.hs" #-}

-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Int ->                    -- token number
         Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k - ((1) :: Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n - ((1) :: Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n - ((1)::Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction









happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery ((1) is the error token)

-- parse error if we are in recovery and we fail again
happyFail (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  (1) tk old_st (((HappyState (action))):(sts)) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        action (1) (1) tk (HappyState (action)) sts ((saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail  i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ( (HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.

