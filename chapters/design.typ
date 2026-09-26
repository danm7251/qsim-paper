#heading[Design & Implementation]

== Development environment

Rust was chosen as the primary development language for its performance and safety guarantees while still allowing unsafe, direct memory management if necessary. Its zero-cost abstractions allow higher level intuitive interfaces to be used without causing additional runtime overhead.

Git was used for version control throughout so that branches could be used to develop experimental features in isolation from the main implementation. Additionally this allowed individual experiments and benchmarks to be associated with specific commits for reproducibility.

GitHub was used to host the source code and provide continuous integration through GitHub Actions. Automated unit tests were run on pushes to the default branch, on Windows and Ubuntu environments, providing correctness checks across platforms and ensuring that changes did not break logic and or unnaceptably compromise accuracy.

== Testing, benchmarking and observability

Unit tests were used constantly throughout every step of development to ensure the behaviour of the simulator was as expected and innacuracies were not introduced. Due to the use of floating point arithmetic a certain degree of accumulated numerical error is inevitable. However it was required to remain within a tolerance range of $10^(-14)$ throughout tests. The Rust ecosystem also provided tools for investigating performance. 

Criterion.rs, a Rust port of the popular Haskell Criterion package, was used for execution time benchmarking and analysis. It iterates over benchmarks gathering samples and then provides a full statistical breakdown. It also supports direct comparison benchmarks useful for verifying the difference between different approaches and algorithms. This was most useful when it came to developing different gate application algorithms and analysing the effects of compiler directive placement. DHAT was used to investigate the behaviour of heap allocations. It is a custom allocator that once initialised, records the peak and total number of allocations throughout execution.

#text(red)[*Better DHAT explanation.*]

The Tracing crate was used to provide observability insights into circuit execution. Primarily useful when examining sub-routines such as the quantum Fourier transform which expands into a series of gates whose ordering depends on parameters such as qubit count. It provided quality-of-life features such as exporting trace data to Chrome Perfetto for examination.

Rust's feature gating was used extensively throughout in coordination with these features to ensure that any accomodations for benchmarking and tracing did not introduce unnecessary overhead when unactivated.

== Simulator Architecture

The simulator is designed around a common instruction based representation of quantum circuits, where seperate statevector and stabilizer objects can be used as the interfaces for the respective backends.

Each instruction describes a quantum operation and the qubits it acts on, while the state representation executing said instruction is responsible for its implementation. This implementation must validate the inputs, and dispatch the operation to the appropriate kernel. The kernels are collections of low-level functions specific to each backend, they take the backends internal state and mutate it accordingly.

#text(red)[Explain Api::Instruction and circuit modelling in more detail]

=== Statevector backend

The statevector representation itself is extraordinarily simple, the only requirement is a heap-backed ordered mutable buffer of complex numbers. That way the basis state is simply encoded by the position of the amplitude in the statevector using big-endian ordering.

For this a #text(purple)[`Vector`] type was established, a thin wrapper around a #text(purple)[`Vec<Complex<f64>>`]. The #text(purple)[`Complex`] type is provided by the 'num_complex' crate. The statevector object owns the amplitude vector by composition and is responsible for interpreting instructions and applying operations to it.

Instructions pass through a key #text(purple)[`execute`] method that matches on the input and routes it to the appropriate operation, this keeps the external instruction separate from any mathematical input necessary such as selecting the gate matrix. Before handing over to kernels the qubit indices provided in the instruction are validated before being converted to the stride format the kernels require. With big-endian ordering the stride of a target qubit $t$ in an $n$-qubit state can be calculated as $2^(\(n-t-1\))$. This stride identifies the distance between two amplitudes whose basis states differ only in the target qubit. This is the information that allows matrix application per pair instead of constructing a full system matrix. For two-qubit controlled operations both the control and target stride must be calculated after undergoing more validation conditions. 

The statevector also needs to provide a gate matrix as well as a mutable reference to the amplitude vector. The matrices are represented using the #text(purple)[`SquareMatrix`] type, which stores elements in a row-major format and stores the dimension also. Standard matrices are constructed with dedicated public constructors in the matrix module. Parameterised gates such as the rotation or controlled-rotation gates take a supplied angle. As only individual pairs are operated on, only the four element basic operator gates are necessary for single-qubit gates.

=== Configuration

The statevector is also composed of a configuration structure which allows enabling hardware acceleration such as FMA or AVX. It can either be created explicitly and then supplied during construction, or via the default constructor where it is populated automatically after verifying which hardware-specific features are available on the host machine. If created explicitly however, the host machine capabilities are still validated to ensure unsupported code blocks aren't entered. This configuration is then used during routing when selecting the optimal kernel for the operation.

=== Kernel implementations

The gate application operations are separated from the statevector structure into a submodule containing three kernel implementations: a portable implementation, an FMA implementation and an AVX implementation.

The portable implementation provides the baseline hardware independent kernels. It operates directly on the amplitudes using ordinary scalar arithmetic. It contains both the full-system matrix approach, which is kept for benchmarking but has been depracated in favour of the portable direct indexing approach.

The FMA kernels follow the same algorithms as the portable direct indexing kernels but use fused multiply-add operations for the real and imaginary components of complex multiplication. These operations are compiled with the `fma` target feature to ensure the compiler emits fused-multiply-add assembly and are only selected when the host machine has been verified to support FMA.

The AVX implementation instead utilises a changed direct indexing algorithm that processes two amplitude pairs simultaneously using four-wide SIMD vectors. The real and imaginary components of the amplitudes are placed into separate SIMD lanes and the matrix coefficients are replicated across the corresponding lanes. Complex multiplication can then be performed on both pairs using vector arithmetic before the results are written back to the statevector.

The different kernels therefore do not represent different algorithms. They provide different implementations of the same pair-wise statevector operation, allowing the execution layer to select an implementation appropriate to the available processor features.
