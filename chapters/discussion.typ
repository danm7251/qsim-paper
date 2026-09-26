#heading[Discussion]

== Full-system matrix expansion

The execution time results show that for both types of kernel the full-system matrix expansions cost becomes increasingly impractical. Primarily the memory usage is what limits this approach.

In the peak memory usage benchmarks, as direct indexing did not trigger any additional allocations the total memory usage remained at the size of the statevector, approximately 128 KB at $n=13$. Compared to the overhead of storing the matrix required to operate on this statevector, it is clear that full-system matrixes become unviable quickly past 13 qubit circuits.