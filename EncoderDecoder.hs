------------------------------------------------------------------------------
-- |
-- Module      :  Application model illustrative example using ForSyDe.Shallow
-- Copyright   :  (c) Denis Loubach
-- License     :  BSD-style (see the file LICENSE)
-- 
-- Stability   :  experimental
-- Portability :  portable
--
------------------------------------------------------------------------------

module ApplicationModel where
import ForSyDe.Shallow

-- ::class Path.Data.Hybrid (Application-domain Ontology)
-- regular data input signal arbitrary definitions
s_key  = signal [1, 4, 6, 1, 1]

-- ::class Path.Data.Homogeneous (Application-domain Ontology)
-- regular data input signal arbitrary definitions
s_input = signal [256, 512, 1024, 2048, -512]

-- ::class Value.Function (Application-domain Ontology)
-- functions definition
fsub x y = y - x
fadd x y = x + y

-- ::class Path.Data.Hybrid (Application-domain Ontology)
-- function signals arbitrary definition (ie static scheduling)
s_f     = signal [(fadd),(fsub),(fadd),(fsub),(fadd)]
s_f_inv = signal [(fsub),(fadd),(fsub),(fadd),(fsub)]

-- function placeholder (FPH) implementation for synchronous (SY) MoC
-- runtime reconfigurable process constructor definition
apply = ($)
fphSY = comb2SY apply

-- ::class Procedure.Controller (Application-domain Ontology)
-- control processes/vertex definition
cipherGen s_f s_key = comb2SY ($) s_f s_key
decipherGen s_f_inv s_key = comb2SY ($) s_f_inv s_key

-- ::class Procedure.Executor.Variable (Application-domain Ontology)
-- reconfigurable processes/vertex definitions following
-- function placeholder (FPH) definition
cipher s_encF s_input = fphSY s_encF s_input
decipher s_decF s_enc = fphSY s_decF s_enc

-- hierarchical process network definition
lambdaExample s_key s_input = (s_enc, s_output)
       where -- s_encF :: Path.Control
             s_encF = cipherGen s_f s_key
             -- s_decF :: Path.Control
             s_decF = decipherGen s_f_inv s_key
             -- s_enc :: Path.Data.Homogeneous
             s_enc = cipher s_encF s_input
             -- s_output :: Path.Data.Homogeneous
             s_output = decipher s_decF s_enc

-- use the following for testing this application model illustrative example in GHCi
-- *ApplicationModel> lambdaExample s_key s_input
-- ({257,508,1030,2047,-511},{256,512,1024,2048,-512})
