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

-- ::Path.Data.Homogeneous class
-- regular data input signals arbitrary definitions
s_key  = signal [1, 4, 6, 1, 1]
s_input = signal [256, 512, 1024, 2048, -512]

-- ::Function class
-- functions definition
fsub x y = y - x
fadd x y = x + y

-- ::Path.Data.Hybrid class
-- function signals arbitrary definition (ie static scheduling)
s_f     = signal [(fadd),(fsub),(fadd),(fsub),(fadd)]
s_f_inv = signal [(fsub),(fadd),(fsub),(fadd),(fsub)]

-- function placeholder (FPH) implementation for synchronous (SY) MoC
-- runtime reconfigurable process constructor definition
apply = ($)
fphSY = comb2SY apply

-- ::Procedure.Controller class
-- control processes/vertex definition
cipherGen s_f s_key = comb2SY ($) s_f s_key
decipherGen s_f_inv s_key = comb2SY ($) s_f_inv s_key

-- ::Procedure.Executor.Variable class
-- reconfigurable processes/vertex definitions following
-- function placeholder (FPH) definition
cipher s_encF s_input = fphSY s_encF s_input
decipher s_decF s_enc = fphSY s_decF s_enc

-- hierarchical process network definition
lambdaExample s_key s_input = (s_enc, s_output)
       where s_encF = cipherGen s_f s_key        -- s_encF :: Path.Control
             s_decF = decipherGen s_f_inv s_key  -- s_decF :: Path.Control
             s_enc = cipher s_encF s_input       -- s_enc :: Path.Data.Homogeneous
             s_output = decipher s_decF s_enc    -- s_output :: Path.Data.Homogeneous

-- use the following for testing this application model illustrative example in GHCi
-- *ApplicationModel> lambdaExample s_key s_input
-- ({257,508,1030,2047,-511},{256,512,1024,2048,-512})
