module StateMonad where

{- Mockup of the Standard Haskell State Monad since many installations do not have it anymore -}

data State s v = State { st :: s -> (v,s) } 
instance Monad (State s) where
  return = \ v -> State (\s -> (v,s))
  m1 >>= m2 = State (\ s1 -> let (v,s2) = st m1 s1 
                             in st (m2 v) s2 )
get = State (\s -> (s,s))
put = \ s -> State (\ _ -> ((),s))
evalState = \ m init -> let (v,s) = st m init in v
