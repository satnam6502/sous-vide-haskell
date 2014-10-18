module Thermomoter
where
import System.Process
  
therm = "/sys/bus/w1/devices/28-000005302a0e/w1_slave"
waterTherm = "/sys/bus/w1/devices/28-0000052f6c1b/w1_slave"

readTemp :: IO Float
readTemp
  = do system ("cat " ++ waterTherm ++ " > sample.txt")
       contents <- readFile "sample.txt"
       let contentLines = lines contents
           temp = read (drop 2 (last (words (contentLines!!1)))) / 1000
       return temp
