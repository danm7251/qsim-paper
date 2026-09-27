#heading[Results]

This chapter compares the correctness and computational cost of the various algorithms and approaches taken. It examines how execution time and memory usage evolve over an increasing number of qubits.

== Experimental configuration & Methodology

The following results were achieved using a desktop computer equipped with a Ryzen 5 1600 processor and 16 GB of RAM. The operating system was CachyOS, a Linux distribution. The benchmarks were compiled and run on the nightly-2026-05-27 Rust toolchain.

#text(red)[*Note: Provide a commit hash on main branch with all experiments ready to run*]

Each experiment that measured execution time was run using Criterion's benchmarking harness. Before collecting measurements, Criterion performed a three second warm-up period during which the benchmark is repeatedly executed without measurement in order to allow the system and host machines hardware to adapt to the load. It then ran benchmarks repeatedly over thousands of iterations to obtain 100 samples. It then provided a statistical analysis of said samples providing a mean, standard deviation and confidence intervals.

Experiments that measured memory usage were run using DHAT which provides heap profiling.

== Full-system matrix against direct indexing

The first comparison evaluates expansion of the full-system matrix against the direct indexing approach. The two approaches were benchmarked using Hadamard and CNOT gates over an increasing number of qubits. This covers both the single-qubit and controlled two-qubit kernels. To isolate qubit scaling as the independent variable, the middle qubit was always selected as a target in both kernel runs. In the $"CNOT"$ benchmarks the control qubit was always selected as zero.

=== Hadamard gate execution time

#image("../assets/kronecker-h-time.svg")

The difference between the two implementations increases exponentially with the number of qubits. Initially at $n=3$ the direct indexing exhibits a speedup of magnitude 19.13, by $n=13$ this factor is 44,391.94. The performance gap widens significantly as qubit count increases as the full-system matrix expansion becomes more expensive.

=== CNOT gate execution time

#image("../assets/kronecker-cnot-time.svg")

The controlled two-qubit variants of the kernels show an even larger difference. At $n=3$ a speedup of 31.03 is observed and at $n=13$ this has reached a factor of 147,010.09.

#text(red)[*Note: Lots to talk about here should be the same as Hadamard with a difference of 4*]

=== Hadamard and CNOT gate peak memory usage

Direct indexing was excluded from the following graphs, since as expected, it incurs no additional allocations aside from the statevector itself. Instead the difference in memory usage between the two full-system  matrix expansion kernels can be examined.

#image("../assets/kronecker-peak-mem.svg")

At $n=3$ the controlled two-qubit kernel consumes 1.86 times the peak memory as the single-qubit kernel. At $n=13$ this factor had approached 1.80. At this point the single-qubit kernel reaches a peak memory usage of approximately 1.34 GB, while the controlled two-qubit reaches 2.42 GB.

== Hardware accelerated kernels

The following experiments evaluate the effect of fused multiply-add operations and SIMD instructions on the execution time of direct-indexed statevector gate application.

=== Hadamard gate execution time over number of qubits

Applying a Hadamard gate over an increasing number of qubits with the middle qubit always selected as a target to isolate qubit scaling gave the following data:

#image("../assets/hardware-h-time.svg")

All three implementations show the expected exponential increase in execution time as qubit count increases. However both hardware accelerated kernels consistently outperform the portable kernel, with a significant reduction in execution time from the AVX kernel. At $n=3$ the speedup from the FMA and AVX kernels are 1.12 and 1.80 respectively while at $n=19$ this has increased to 1.40 and 1.58.

=== Hadamard gate execution time over target qubit

This experiment differs in the last in that the circuit size remained constant at $n=17$, this time the independent variable was the target qubit. Each kernel was aside from AVX was tested at all target qubit positions from zero to $n-1$. The AVX kernel cannot accept a target qubit equal to $n-1$ since the target amplitudes are interleaved with a stride equal to one. Running this experiment provided the following results:

#image("../assets/hardware-h-target.svg")

The AVX implementation once again, consistently outperforms the other implementations, at every measurement value it can be applied to. There is an evident increase in execution time as the target approaches $n-1$. However on the final three targets there are peaks at $n-3$ and $n-1$ with a trough at $n-2$. This pattern was reproduced at various constant qubit counts.

#text(red)[*Note: Run at different odd/even circuit size*]