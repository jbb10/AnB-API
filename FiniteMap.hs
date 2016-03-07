{-

Open Source Fixedpoint Model-Checker version 2014

(C) Copyright Sebastian Moedersheim 2003,2014
(C) Copyright Paolo Modesti 2012
(C) Copyright Nicklas Bo Jensen 2012
(C) Copyright IBM Corp. 2009
(C) Copyright ETH Zurich (Swiss Federal Institute of Technology) 2003,2007

All Rights Reserved.

-}

module FiniteMap where
import Data.Map

type FiniteMap = Data.Map.Map 

addToFM a b c = insert b c a
lookupFM a b = Data.Map.lookup b a 
mapFM = Data.Map.map
emptyFM = Data.Map.empty
fmToList = Data.Map.toList
unitFM a b = insert a b emptyFM