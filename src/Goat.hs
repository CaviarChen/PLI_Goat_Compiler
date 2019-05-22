-- | Main module of this Goat Compiler
--
-- Authors:
--   Weizhi Xu  (752454)
--   Zijun Chen (813190)
--   Zhe Tang   (743398)

module Main where

import GoatParser
import GoatLexer
import GoatFormatter
import GoatAnalyzer

import Data.Char
import Text.Parsec
import System.Environment
import System.Exit
import Control.Monad.State
import Data.Map (Map)
import qualified Data.Map as M

-- | Job type
data Job
  = JobToken | JobAST | JobPrettier | JobCompile
  deriving (Eq)

-- | Execute lexer, parser ... in order and output the result based on job type
execute :: Job -> String -> IO ()
execute job source_file
  = do
      input <- readFile source_file
      let tokens = runGoatLexer source_file input
      if job == JobToken
        then do
          -- tokens from lexer
          putStrLn (show tokens)
          return ()
        else do
          let ast = runGoatParser tokens
          case ast of
            Right tree ->
              do
                if job == JobAST
                  then do
                    -- AST from parser
                    putStrLn (show tree)
                    return ()
                  else do
                    if job == JobPrettier
                      then do 
                        -- preitter
                        runGoatFormatterAndOutput tree
                        return ()
                      else do
                        -- compile
                        let semanticResult = runSemanticCheck tree
                        case semanticResult of
                          Right decoratedAST ->
                            do
                              putStrLn(show decoratedAST)
                          Left err ->
                            do
                              putStr "Semantic error: "
                              putStrLn (show err)
                              exitWith (ExitFailure 3)
                        return ()
            Left err ->
              do
                putStr "Syntax error: "
                putStrLn (show err)
                exitWith (ExitFailure 2)

-- | Main function that handles the execution arguments
main :: IO ()
main
  = do
      progname <- getProgName
      args <- getArgs

      let usageMsg = "usage: " ++ progname ++ " [-st | -sa | -p | -h] file"

      case args of

        ["-st", source_file] -> execute JobToken source_file
        ["-sa", source_file] -> execute JobAST source_file
        ["-p", source_file] -> execute JobPrettier source_file
        ["-h"] ->
          do
            putStrLn usageMsg
            putStrLn ("Options and arguments:")
            putStrLn ("-st    : display secret tokens")
            putStrLn ("-sa    : display secret Abstract Syntax Tree")
            putStrLn ("-p     : pretty print the source file")
            putStrLn ("-h     : display the help menu")
            putStrLn ("file   : the file to be processed")
        [source_file] -> execute JobCompile source_file
        _ ->
          do
            putStrLn usageMsg
            exitWith (ExitFailure 1)
