module Main where

import GoatParser

import Data.Char
import Text.Parsec
import System.Environment
import System.Exit

main :: IO ()
main
  = do
      progname <- getProgName
      args <- getArgs
      excute progname args

excute :: String -> [String] -> IO ()
excute _ [filename]
  = do
    putStrLn "Sorry, cannot generate code yet"
    exitWith (ExitFailure 1)

excute _ ["-p", filename]
  = do
      input <- readFile filename
      let output = runGoatParse input
      case output of
        Right ast -> print ast
        Left  err -> do 
          putStr "Parse error at "
          print err
    -- TODO: Pretty print

excute progname _
  = do
      putStrLn ("Usage: " ++ progname ++ " filename\n\n")
      exitWith (ExitFailure 1)