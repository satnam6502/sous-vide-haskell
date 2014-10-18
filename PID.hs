module Main
where
import System.Process
import System.CPUTime
import Data.Time.Clock
import Control.Concurrent
import Control.Monad
import GetTime                                      
import Thermomoter

target :: Float
-- target = 56.5 -- Lamb
target = 52.0 -- Vension.
-- target = 45.0 -- Salmon. About 25 minutes.
       
pid :: Float -> Float -> Float -> Float -> Integer -> (Bool, Float, Float, Float) -> IO ()
pid p i d sp begin (heating, u_1, temp_1, temp_2)
  = do cpuTime <- getCPUTime
       let elapsed = (cpuTime - begin) `div` 10^9
       start <- getTime
       threadDelay 1000000 -- Wait for approximately a second.
       temp <- readTemp
       -- Ignore spikes from bad readings and interference.
       when (temp < 0.0 || temp > 100.0) $
          pid p i d sp begin (heating, u_1, temp, temp_1)
       now <- getTime
       let delta = abs (fromIntegral (now - start) / 10^7) -- Duration of this sample.
           t = (fromIntegral (now - begin)) / 10^7 -- Time since start of execution.
           error = sp - temp
           -- Compute the new utility function value using the Type C model.
           u' = u_1 - p * (temp - temp_1) +
                      i * delta * error -
                      d / delta * (temp - 2 * temp_1 + temp_2)
           u = max 0.0 (min 100.0 u') -- Prevent windup
       putStrLn (show elapsed ++ "\t" ++ show temp ++ "\t" ++ show u ++ "\t" ++ show u' ++ "\t" ++ show now ++ "\tdelta = " ++ show delta)
       when (heating && temp >= u) $
         do putStrLn "OFF"
            system "echo \"0\" > /sys/class/gpio/gpio17/value"
            pid p i d sp begin (False, u, temp, temp_1)
       when (not heating && temp < u) $
         do putStrLn "ON"
            system "echo \"1\" > /sys/class/gpio/gpio17/value"
            pid p i d sp begin (True, u, temp, temp_1)
       pid p i d sp begin (heating, u, temp, temp_1)       
       
-- The main program reset the log file, initializes the       
-- the temperature sensor I/O and the GPIO for controlling
-- the relay switch that is connected to the heating element.
-- The strt time and initial temperature is recorded and then
-- the PID control process is kicked off.
main :: IO ()
main  
  = do system "echo \"17\" > /sys/class/gpio/export" -- Set GPIO 17 for output.
       system "echo \"out\" > /sys/class/gpio/gpio17/direction"
       system "echo \"0\" > /sys/class/gpio/gpio17/value" -- Set GPIO 17 to 0 (relay off).
       system "modprobe w1-gpio" -- Initialize the temperature sensor GPIO.
       system "modprobe w1-therm" -- Setup the driver for reading the temperature.
       start <- getCPUTime -- Get the start time.
       temp <- readTemp -- Read the initial temperature.
       pid 1 1  1 target start (False, temp, temp, temp)
