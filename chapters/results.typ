#heading[Results]

This chapter compares the correctness and computational cost of the various strategies taken. It examines how execution time and memory usage evolve over an increasing number of qubits. In the majority of cases logarithmic graphs are preferred due to the exponential nature of the data.

== Experimental configuration & Methodology

The following results were achieved using a desktop computer equipped with a Ryzen 5 1600 processor and 16 GB of RAM. The operating system was CachyOS, a Linux distribution. The benchmarks were compiled and run on the nightly-2026-05-27 Rust toolchain.

Each experiment that measured execution time was run using Criterion's benchmarking harness. Before collecting measurements, Criterion performed a three second warm-up period during which the benchmark is repeatedly executed without measurement in order to allow the system and host machines hardware to adapt to the load. It then ran benchmarks repeatedly over thousands of iterations to obtain 100 samples. It then provided a statistical analysis of said samples providing a mean, standard deviation and confidence intervals.

When comparing kernels directly against each other, amplitude buffers were constructed explicitly outside of the benchmark and kernels were called directly in benchmarks to remove any overhead that the validation and dispatch of the statevector object could introduce.

== Full-system matrix against portable DPM

The first comparison evaluates expansion of the full-system matrix against the baseline portable DPM approach. The two strategies were benchmarked using singular Hadamard and CNOT gates over amplitude buffers containing an increasing number of qubits from $n=3$ to $n=13$ in increments of two. These experiments correspond to both the single-qubit and controlled two-qubit kernels. To isolate qubit count as the independent variable, the target was always the middle qubit and for CNOT gates the control qubit was always selected as zero.

=== Hadamard gate execution time

#figure(
  image("../assets/kronecker-h-time.svg"),
  caption: [Execution time of a single Hadamard gate application against the number of qubits for the full-system matrix and portable DPM methods.]
)

The gap between the two implementations grows exponentially with the number of qubits. At $n=3$ the DPM kernel is 19.13 times faster than full-system expansion and at $n=13$ it is 44,391.94 times faster.

=== CNOT gate execution time

#figure(
  image("../assets/kronecker-cnot-time.svg"),
  caption: [Execution time of a single CNOT gate application against the number of qubits for the full-system matrix and portable DPM methods.]
)

The controlled two-qubit kernels show an even larger difference. The speedup is 31.03 at $n=3$ and 147,010.09 at $n=13$.

=== Execution time gains

#image("../assets/ratio-dpm-full.svg")

=== Hadamard and CNOT gate peak memory usage

DPM was excluded from the following graphs, since as expected, its gate applications triggered no additional allocations. Instead the difference in memory usage between the two full-system matrix expansion kernels can be examined.

#figure(
  image("../assets/kronecker-peak-mem.svg"),
  caption: [Peak heap memory usage of full-system matrix gate application against the number of qubits for single Hadamard and CNOT gates.]
)

At $n=3$ the controlled two-qubit kernel consumes 1.86 times the peak memory as the single-qubit kernel. At $n=13$ this factor had approached 1.80. At this point the single-qubit kernel reaches a peak memory usage of approximately 1.34 GB, while the controlled two-qubit reaches 2.42 GB.

== Hardware accelerated kernels

The following experiments evaluate the effect of fused multiply-add operations and SIMD instructions on the execution time of DPM statevector gate application.

=== Hadamard gate execution time over number of qubits

#figure(
  image("../assets/hardware-h-time.svg"),
  caption: [Execution time of a single Hadamard gate application against the number of qubits for all three direct pair multiplication methods.]
)

All three implementations show the expected exponential increase in execution time as qubit count increases. However both hardware accelerated kernels consistently outperform the portable kernel, with a significant reduction in execution time from the AVX kernel. At $n=3$ the speedup from the FMA and AVX kernels are 1.12 and 1.80 respectively while at $n=19$ this has increased to 1.40 and 1.58.

=== Hadamard gate execution time over target qubit

This experiment differs in the last in that the circuit size remained constant at $n=17$, this time the independent variable was the target qubit. Each kernel was aside from AVX was tested at all target qubit positions from zero to $n-1$. The AVX kernel cannot accept a target qubit equal to $n-1$ since the target amplitudes are interleaved with a stride equal to one. Running this experiment provided the following results:

#figure(
  image("../assets/hardware-h-target.svg"),
  caption: [Execution time of a single Hadamard gate application against the target qubit index for all three direct pair multiplication methods.]
)

The AVX implementation once again, consistently outperforms the other implementations, at every measurement value it can be applied to. There is an evident increase in execution time as the target approaches $n-1$. However on the final three targets there are peaks at $n-3$ and $n-1$ with a trough at $n-2$. This pattern was reproduced at various constant qubit counts.

== Stabiliser simulator

The following experiments evaluate the performance of the full statevector and stabiliser simulation objects when provided with the same circuit. The circuit consists of a Hadamard gate with a target qubit one and a CNOT gate with a target qubit zero and control qubit one.

#figure(
  image("../assets/stab-sv-time.svg"),
  caption: [Execution time of a two gate Clifford circuit against the number of qubits for both the stabiliser and statevector simulators.]
)

A graph