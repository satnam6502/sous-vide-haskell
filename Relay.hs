module Relay
where
import System.Process

-- Functions to control the relay control attached to GPIO-17.
  
turnRelayOn :: IO ()
turnRelayOn
  = do putStrLn "Relay ON"
       system "echo \"1\" > /sys/class/gpio/gpio17/value"
       return ()
 
turnRelayOff :: IO ()
turnRelayOff
  = do putStrLn "Relay OFF"
       system "echo \"0\" > /sys/class/gpio/gpio17/value"
       return ()
 