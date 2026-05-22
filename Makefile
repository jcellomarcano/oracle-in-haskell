haskinator:
	ghc --make Haskinator

test:
	ghc --make UnitTest
	./UnitTest

bench:
	ghc --make Benchmark
	./Benchmark

clean:
	rm -f Haskinator UnitTest Benchmark *.o *.hi