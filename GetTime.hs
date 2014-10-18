module GetTime
where
import Foreign.C 

foreign import ccall "clockgettime" clockgettime :: IO CLong

getTime :: IO Integer                                                    
getTime
  = do t <- clockgettime
       return (fromIntegral t)
