#heading[Analysis and discussion]

== Full-system matrix expansion

The full-system matrix approach constructs a $2^n times 2^n$ operator for a gate. Its cost therefore grows with $4^n$ while DPM grows with $2^n$. The measured speedup rose by a factor of roughly 2.2 per added qubit for the Hadamard gate and 2.3 for CNOT which is close to the factor of two this argument predicts. The memory results show the practical consequence. At $n=13$ the operator alone occupies 1 GiB and each added qubit quadruples it. Full-system expansion would need around 4 GiB at $n=14$ and 64 GiB at $n=16$ whereas DPM needs no allocation beyond the statevector itself.

In the peak memory usage benchmarks, as direct indexing did not trigger any additional allocations the total memory usage remained at the size of the statevector, approximately 131 KB at $n=13$. In comparison, the full-system matrix implementations require far more memory to construct and apply the expanded matrix. At $n=13$, this reached approximately 1.34 GB for the single-qubit kernel and 2.42 GB for the controlled two-qubit kernel. This demonstrates that full-system matrix expansion becomes impractical quickly at relatively small circuit sizes due to its rapidly increasing memory requirements.

The difference in execution time also follows the same underlying scaling issue. A full-system matrix contains $2^n times 2^n=4^n$ elements, applying these to the statevector through matrix-vector multiplication takes time as well as memory.

The "CNOT" results show the same behaviour as the Hadamard results, however the difference between the two kernels is even larger. This is due to the opposite approaches they take to conditionals. Full-system matrix expansion requires two system matrices multiplying the cost by a factor of two, while the direct indexing kernel actually takes advantage of the control aspect to reduce the amount of work. Since the direct approach individually selects qubit pairs at a time to operate on, it can calculate the positions of the $c=1$ amplitudes and construct a loop condition that skips all $c=0$ amplitudes, in theory halving the workload. Due to this we should expect to see the differnce in execution time between the two kernels multiply by four when comparing the Hadamard and $"CNOT"$ experiments.

#image("../assets/ratio.svg")

Interestingly that prediction does not hold with the difference in speedup hovering around a modest factor of two.

== Hardware acceleration

#image("../assets/avx-fma-speedup.svg")

The hardware-accelerated kernels consistently reduced execution time across both experiments compared with the portable implementation. FMA showed a modest improvement, while the AVX implementation provided the largest reduction in execution time.

The target experiment revealed an established pattern as the target qubit increased. Execution time surges as the x-axis approaches the final three to four qubits, despite no change in the amount of data processed. The only variable that has changed is how the accesses are distributed in memory.

After futher analysis using perf, a tool for recording hardware counters such as instruction counts and cache activity the following was found:

#image("../assets/instruction-count-target.svg")

This data was obtained by recording instruction count over the execution of a binary that applied one thousand Hadamard gates to a 17 qubit statevector. Five measurements were taken for each target qubit in order to reduce variability introduced by runtime overhead. However maximum the standard deviation is only 0.0000231% at target qubit 9.


