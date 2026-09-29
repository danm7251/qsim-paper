#heading[Conclusion]

#heading(numbering: none, outlined: true)[Conclusion]

This paper investigated the computational challenges of classical statevector quantum circuit simulation and evaluated strategies to mitigate its inherent bottlenecks at both the algorithmic and hardware levels. By developing a custom Rust-based simulator, this work demonstrated that directly operating on amplitude pairs bypasses the prohibitive memory and computational overhead of full-system matrix expansion.

The experimental results confirmed that Direct Pair Multiplication fundamentally alters memory and execution scaling. At 13 qubits, direct indexing achieved speedups of 44,391.94 times for single-qubit Hadamard gates and 147,010.09 times for controlled two-qubit CNOT gates. While full-system matrix construction required up to 1.34 GB for single-qubit operations and 2.42 GB for controlled two-qubit operations at 13 qubits, direct indexing operated without any additional allocations beyond the amplitude buffer itself.

Furthermore, hardware-accelerated kernels provided substantial execution time reductions over the portable implementation. The AVX SIMD implementation delivered an additional 158% to 225% speedup over the portable kernel. However, memory allocation profiling revealed that performance decreases as the target qubit approaches $n - 1$.

Future research directions could consist of providing measurement operations to the stabiliser simulation for running consequential quantum circuits, as well as investigating the benefits of multithreaded strategies on execution time.

Ultimately, while classical statevector simulation remains bound by its exponential state space scaling, combining direct pair multiplication with SIMD vectorization significantly improves runtime and memory efficiency. These optimizations provide a fast, memory-performant environment for designing and verifying quantum algorithms on classical hardware.