#heading[Evaluation]

This chapter compares the correctness and computational cost of the various algorithms and approaches taken. It examines how execution time and memory usage evolve over an increasing number of qubits.

== Experimental configuration

The results were achieved using a desktop computer equipped with a Ryzen 5 1600 processor and 16 GB of RAM. The operating system was CachyOS, a Linux distribution. The benchmarks were compiled and run on the nightly-2026-05-27 Rust toolchain.

== Full-system matrix against direct indexing

The baseline this paper will test against is Kronecker expansion. While it represents the mathematics well, the kronnecker product approach is expected to be vastly more inefficient at both $O(4^n)$ time and space complexity. By directly iterating throughout the statevector a great deal of null work is eliminated reducing computational complexity to $O(2^n)$. When testing each algorithm on a QFT subroutine we can clearly see that \~etc.

#image("../assets/kronecker-h-time.svg")

With controlled two qubit gates such as CNOT, the

#image("../assets/kronecker-cnot-time.svg")

Direct indexing was excluded from the following graphs as it incurs no additional allocations aside from the statevector itself. But it can be seen that even at a relatively modest number of qubits the additional allocations required by the kronecker expansion rapidly pass the 1 GB mark. 

#image("../assets/kronecker-peak-mem.svg")

== Hardware accelerated algorithms

This will test an AVX2 enabled algorithm against its unaccelerated counterpart. The exact speedup depends heavily on implementation but we would expect to see significant throughput gains.