module Drasil.GlassBR.IMods (symb, iMods, pbIsSafe, lrIsSafe, instModIntro) where

import Control.Lens ((^.))
import Prelude hiding (exp)
import Language.Drasil
import Theory.Drasil (InstanceModel, imNoDeriv, qwC, qwUC, equationalModelN)
import Language.Drasil.Chunk.Concept.NamedCombinators
import qualified Language.Drasil.Sentence.Combinators as S

import Data.Drasil.Concepts.Documentation (goal)
import Data.Drasil.SI_Units

import Drasil.GlassBR.DataDefs {- temporarily import everything -}
import Drasil.GlassBR.Goals (willBreakGS)
import Drasil.GlassBR.References (astm2009, beasonEtAl1998)
import Drasil.GlassBR.Unitals (charWeight, demand, isSafeLR, isSafePb,
  lRe, pbTol, plateLen, plateWidth, probBr, standOffDist, loadSF)


iMods :: [InstanceModel]
iMods = [probOfBreak, calofCapacity, pbIsSafe, lrIsSafe]

symb :: [UnitalChunk]
symb =  [ucuc plateLen metre, ucuc plateWidth metre, ucuc charWeight kilogram, ucuc standOffDist metre, demand] -- this is temporary
-- ++
 -- [dqdQd (qw calofDemand) demandq]

{--}

probOfBreak :: InstanceModel
probOfBreak = imNoDeriv (equationalModelN (probBr ^. term) probOfBreakQD)
  [qwUC risk] (qw probBr) [] (map dRef [astm2009, beasonEtAl1998]) "probOfBreak"
  [riskRef]

probOfBreakQD :: SimpleQDef
probOfBreakQD = mkQuantDef probBr (exactDbl 1 $- exp (neg (sy risk)))

{--}

calofCapacity :: InstanceModel
calofCapacity = imNoDeriv (equationalModelN (lRe ^. term) calofCapacityQD)
  (map qwUC [nonFL, glaTyFac] ++ [qwUC loadSF]) (qw lRe) []
  [dRef astm2009] "calofCapacity" [lrCap, nonFLRef, gtfRef]

calofCapacityQD :: SimpleQDef
calofCapacityQD = mkQuantDef lRe (sy nonFL `mulRe` sy glaTyFac `mulRe` sy loadSF)

{--}

pbIsSafe :: InstanceModel
pbIsSafe = imNoDeriv (equationalModelN (nounPhraseSP "Safety Req-Pb") pbIsSafeQD)
  [qwC probBr $ UpFrom (Exc, exactDbl 0), qwC pbTol $ UpFrom (Exc, exactDbl 0)]
  (qw isSafePb) []
  [dRef astm2009] "isSafePb"
  [pbIsSafeDesc, probBRRef, pbTolUsr]

pbIsSafeQD :: SimpleQDef
pbIsSafeQD = mkQuantDef isSafePb (sy probBr $< sy pbTol)

{--}

lrIsSafe :: InstanceModel
lrIsSafe = imNoDeriv (equationalModelN (nounPhraseSP "Safety Req-LR") lrIsSafeQD)
  [qwC lRe $ UpFrom (Exc, exactDbl 0), qwC demand $ UpFrom (Exc, exactDbl 0)]
  (qw isSafeLR) []
  [dRef astm2009] "isSafeLR"
  [lrIsSafeDesc, capRef, qRef]

lrIsSafeQD :: SimpleQDef 
lrIsSafeQD = mkQuantDef isSafeLR (sy lRe $> sy demand)

iModDesc :: QuantityDict -> Sentence -> Sentence
iModDesc main s = foldlSent [S "If", ch main `sC` S "the glass is" +:+.
    S "considered safe", s `S.are` S "either both True or both False"]
  
-- Intro --

instModIntro :: Sentence
instModIntro = foldlSent [atStartNP (the goal), refS willBreakGS, 
  S "is met by", refS pbIsSafe `sC` refS lrIsSafe]

-- Notes --

capRef :: Sentence
capRef = definedIn' calofCapacity (S "and is also called capacity")

lrIsSafeDesc :: Sentence
lrIsSafeDesc = iModDesc isSafeLR
  (ch isSafePb +:+ fromSource pbIsSafe `S.and_` ch isSafeLR)

pbIsSafeDesc :: Sentence
pbIsSafeDesc = iModDesc isSafePb
  (ch isSafePb `S.and_` ch isSafePb +:+ fromSource lrIsSafe)

probBRRef :: Sentence
probBRRef = definedIn probOfBreak
