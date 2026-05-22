module Main where

import Oracle
import System.CPUTime
import Text.Printf
import qualified Data.Map as Map

-- | Run an IO action many times to get a measurable cumulative time in microseconds.
-- We force the result using seq to prevent lazy evaluation optimization.
timeMany :: Int -> (a -> Int) -> IO a -> IO Double
timeMany iterations forceFn action = do
    start <- getCPUTime
    let loop 0 = return ()
        loop i = do
            res <- action
            let v = forceFn res
            v `seq` loop (i - 1)
    loop iterations
    end <- getCPUTime
    return (fromIntegral (end - start) / 1e6)

-- | Generate a balanced decision tree of questions of depth d.
-- Leaves are named "P_0", "P_1", etc.
generateTree :: Int -> Oracle
generateTree depth = go 0 0
  where
    go d index
        | d == depth = newOracle ("P_" ++ show index)
        | otherwise  =
            let q = "Q_depth_" ++ show d ++ "_idx_" ++ show index
                leftVal = go (d + 1) (index * 2)
                rightVal = go (d + 1) (index * 2 + 1)
            in branch ["0", "1"] [leftVal, rightVal] q

-- | Force evaluation of the paths returned by findPaths
forcePaths :: [[(String, String)]] -> Int
forcePaths paths = sum [ length p | p <- paths ]

-- | Force evaluation of LCA query result
forceEither :: Either String (String, String, String) -> Int
forceEither (Left s) = length s
forceEither (Right (q, o1, o2)) = length q + length o1 + length o2

runBenchmarkForDepth :: Int -> IO ()
runBenchmarkForDepth d = do
    let numPredictions :: Int
        numPredictions = 2^d
    printf "\n--- Running Benchmark for Tree Depth %d (%d predictions, %d questions) ---\n"
           d numPredictions (numPredictions - 1)

    let tree = generateTree d
    let iterations = 10000

    -- 1. Measure buildPathMap time (run 100 times since building the map takes longer)
    mapBuildTime <- timeMany 100 Map.size (return $ buildPathMap tree)
    printf "Average PathMap Construction Time: %.2f µs (runs: 100)\n" (mapBuildTime / 100.0)

    let pathMap = buildPathMap tree
    -- Pick two predictions at the far ends of the tree
    let p1 = "P_0"
        p2 = "P_" ++ show (numPredictions - 1)

    -- 2. Measure manual findPaths (recursive traversal)
    findPathsTime <- timeMany iterations forcePaths (do
        let r1 = findPaths p1 tree
            r2 = findPaths p2 tree
        return (r1 ++ r2))
    printf "Manual Path Retrieval (findPaths): %.3f µs (runs: %d)\n"
           (findPathsTime / fromIntegral iterations) iterations

    -- 3. Measure cached PathMap lookup
    cachedLookupTime <- timeMany iterations (\(r1, r2) -> maybe 0 length r1 + maybe 0 length r2) (do
        let r1 = Map.lookup p1 pathMap
            r2 = Map.lookup p2 pathMap
        return (r1, r2))
    printf "Cached Path Retrieval (PathMap lookup): %.3f µs (runs: %d)\n"
           (cachedLookupTime / fromIntegral iterations) iterations
    printf "Path Retrieval Speedup: %.1fx\n" (findPathsTime / cachedLookupTime)

    -- 4. Measure manual getCrucialQuestion (full tree traversal)
    cqManualTime <- timeMany iterations forceEither (return $ getCrucialQuestion p1 p2 tree)
    printf "Manual LCA Query (getCrucialQuestion): %.3f µs (runs: %d)\n"
           (cqManualTime / fromIntegral iterations) iterations

    -- 5. Measure cached getCrucialQuestionCached
    cqCachedTime <- timeMany iterations forceEither (return $ getCrucialQuestionCached p1 p2 pathMap)
    printf "Cached LCA Query (getCrucialQuestionCached): %.3f µs (runs: %d)\n"
       (cqCachedTime / fromIntegral iterations) iterations
    printf "LCA Query Speedup: %.1fx\n" (cqManualTime / cqCachedTime)

    -- 6. Worst-Case Retrieval (prediction does not exist)
    let pNotFound = "P_non_existent"
    notFoundManualTime <- timeMany iterations forcePaths (do
        let r = findPaths pNotFound tree
        return r)
    printf "Manual Path Retrieval (Not Found): %.3f µs (runs: %d)\n"
           (notFoundManualTime / fromIntegral iterations) iterations

    notFoundCachedTime <- timeMany iterations (\r -> maybe 0 length r) (do
        let r = Map.lookup pNotFound pathMap
        return r)
    printf "Cached Path Retrieval (Not Found): %.3f µs (runs: %d)\n"
           (notFoundCachedTime / fromIntegral iterations) iterations
    printf "Worst-Case Path Retrieval Speedup: %.1fx\n" (notFoundManualTime / notFoundCachedTime)

main :: IO ()
main = do
    putStrLn "========================================================="
    putStrLn "              HASKINATOR BENCHMARKING SUITE              "
    putStrLn "========================================================="
    
    runBenchmarkForDepth 6
    runBenchmarkForDepth 8
    runBenchmarkForDepth 10
    runBenchmarkForDepth 12
    
    putStrLn "\n========================================================="
    putStrLn "Benchmarking completed successfully!"
    putStrLn "========================================================="
