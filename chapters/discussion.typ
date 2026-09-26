#heading[Discussion]

== Full-system matrix expansion

The execution time results show that for both types of kernel the full-system matrix expansions cost becomes increasingly impractical. Primarily the memory usage is what limits this approach.

In the peak memory usage benchmarks, as direct indexing did not trigger any additional allocations the total memory usage remained at the size of the statevector, approximately 131 KB at $n=13$. In comparison, the full-system matrix implementations require far more memory to construct and apply the expanded matrix. At $n=13$, this reached approximately 1.34 GB for the single-qubit kernel and 2.42 GB for the controlled two-qubit kernel. This demonstrates that full-system matrix expansion becomes impractical quickly at relatively small circuit sizes due to its rapidly increasing memory requirements.

The difference in execution time also follows the same underlying scaling issue. A full-system matrix contains $2^n times 2^n=4^n$ elements, applying these to the statevector through matrix-vector multiplication takes time as well as memory.

The "CNOT" results show the same behaviour as the Hadamard results, however the difference between the two kernels is even larger. This is due to the opposite approaches they take to conditionals. Full-system matrix expansion requires two system matrices multiplying the cost by a factor of two, while the direct indexing kernel actually takes advantage of the control aspect to reduce the amount of work. Since the direct approach individually selects qubit pairs at a time to operate on, it can calculate the positions of the $c=1$ amplitudes and construct a loop condition that skips all $c=0$ amplitudes, in theory halving the workload. Due to this we should expect to see the differnce in execution time between the two kernels multiply by four when comparing the Hadamard and $"CNOT"$ experiments.

#text(red)[*Quick graph of difference ratio - 20m*]

== Hardware acceleration

The hardware-accelerated kernels consistently reduced execution time across both experiments compared with the portable implementation. FMA showed a modest improvement, while the AVX implementation provided the largest reduction in execution time.

The target experiment revealed an established pattern as the target qubit increased. Execution time surges as the x-axis approaches the final three to four qubits, despite no change in the amount of data processed. The only variable that has changed is how the accesses are distributed in memory.

#text(red)[*Note: Explain memory behaviour - 30m*]

#text(red)[*Note: Explain target feature vs algorithmic speedup - 30m*]


