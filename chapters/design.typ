#heading[Design & Implementation]

=== Development environment

Rust was chosen as the primary development language for its performance and safety guarantees while still allowing unsafe, direct memory management if necessary. Its zero-cost abstractions allow higher level intuitive interfaces to be used without causing additional runtime overhead.

Git was used for version control throughout so that branches could be used to develop experimental features in isolation from the main implementation. Additionally this allowed individual experiments and benchmarks to be associated with specific commits for reproducibility.

GitHub was used to host the source code and provide continuous integration through GitHub Actions. Automated unit tests were run on pushes to the default branch, on Windows and Ubuntu environments, providing correctness checks across platforms and ensuring that changes did not break logic and accuracy past a determined threshold.

=== Testing, benchmarking and observability

Unit correctness tests were used throughout development to ensure the behaviour of the simulator was as expected aside from its performance. The Rust ecosystem also provided tools for investigating performance. 

Criterion.rs, a Rust port of the popular Haskell Criterion package, was used for execution time benchmarking and analysis. It iterates over benchmarks gathering samples and then provides a full statistical breakdown. It also supports direct comparison benchmarks useful for verifying the difference between different approaches and algorithms. This was most useful when it came to developing different gate application algorithms and analysing the effects of compiler directive placement. DHAT was used to investigate the behaviour of heap allocations. It is a custom allocator that once initialised, records the peak and total number of allocations throughout execution.

The Tracing crate was used to provide observability insights into circuit execution. Primarily useful when examining sub-routines such as the quantum Fourier transform which expands into a series of gates whose ordering depends on parameters such as qubit count. It provided quality-of-life features such as exporting trace data to Chrome Perfetto for examination.

Rust's feature gating was used extensively throughout in coordination with these features to ensure that any accomodations for benchmarking and tracing did not introduce unnecessary overhead when unactivated.

=== Simulator Architecture

The simulator is designed around a common instruction based representation of quantum circuits, where seperate statevector and stabilizer objects can be used as the interfaces for the respective backends.

Each instruction describes a quantum operation and the qubits it acts on, while the state representation executing said instruction is responsible for its implementation. This implementation must validate the inputs, and dispatch the operation to the appropriate kernel. The kernels are collections of low-level functions specific to each backend, they take the backends internal state and mutate it accordingly.

#text(red)[Explain Api::Instruction and circuit modelling in more detail]

==== Statevector backend

The statevector representation itself is extraordinarily simple, the only requirement is a heap-backed ordered mutable buffer of complex numbers. That way the basis state is simply encoded by the position of the amplitude in the statevector using big-endian ordering.

For this a #text(purple)[`Vector`] type was established, a thin wrapper around a #text(purple)[`Vec<Complex<f64>>`]. The #text(purple)[`Complex`] type is provided by the 'num_complex' crate. The statevector object owns the amplitude vector by composition and is responsible for interpreting instructions and applying operations to it.

Instructions pass through a key #text(purple)[`execute`] method that matches on the input and routes it to the appropriate operation, this keeps the external instruction separate from any mathematical input necessary such as selecting the gate matrix. Before handing over to kernels the qubit indices provided in the instruction are validated before being converted to the stride format the kernels require. With big-endian ordering the stride of a target qubit $t$ in an $n$-qubit state can be calculated as $2^(\(n-t-1\))$. This stride identifies the distance between two amplitudes whose basis states differ only in the target qubit. This is the information that allows matrix application per pair instead of constructing a full system matrix. For two-qubit controlled operations both the control and target stride must be calculated after undergoing more validation conditions. 

The statevector also needs to provide a gate matrix as well as a mutable reference to the amplitude vector. The matrices are represented using the #text(purple)[`SquareMatrix`] type, which stores elements in a row-major format and stores the dimension also. Standard matrices are constructed with dedicated public constructors in the matrix module. Parameterised gates such as the rotation or controlled-rotation gates take a supplied angle. As only individual pairs are operated on, only the four element basic operator gates are necessary for single-qubit gates.

===== Configuration

The statevector is also composed of a configuration which can either be created externally and then supplied during construction, or via the default constructor is created automatically after verifying which hardware-specific features are available on the host machine. This is then used during routing when selecting the optimal kernel for the operation.

==== Kernel implementations

The numerical operations are separated from the state management into three kernel implementations: a portable implementation, an FMA implementation and an AVX implementation. Each performs the same underlying gate transformation but differs in the instructions used to perform the arithmetic.

The portable kernel provides the general implementation of the gate operations. It operates directly on the amplitude slice using ordinary scalar arithmetic. For each selected pair, the two complex input amplitudes are copied into local values, multiplied by the four matrix coefficients and accumulated into two output amplitudes. The outputs are then written back to the original positions in the statevector.

The FMA kernel follows the same traversal and transformation but uses fused multiply-add operations for the real and imaginary components of complex multiplication. These operations are compiled with the `fma` target feature and are only selected when the host processor has been verified to support FMA.

The AVX implementation instead processes two amplitude pairs simultaneously using four-wide SIMD vectors. The real and imaginary components of the amplitudes are placed into separate SIMD lanes and the matrix coefficients are replicated across the corresponding lanes. Complex multiplication can then be performed on both pairs using vector arithmetic before the results are written back to the statevector.

The different kernels therefore do not represent different algorithms. They provide different implementations of the same pair-wise statevector operation, allowing the execution layer to select an implementation appropriate to the available processor features.

==== Execution configuration

Kernel selection is controlled by the #text(purple)[`Config`] structure, which records whether AVX and FMA execution should be used. The configuration can either be selected automatically when constructing a state or supplied explicitly.

When an explicit configuration is supplied, the constructor first checks that the requested processor features are available. This prevents execution from reaching a kernel containing unsupported instructions. The configuration is then retained by the statevector and used whenever a gate is executed.

The execution path therefore consists of validation and preparation at the state level, followed by hardware-specific numerical execution:

$
  "Instruction" -> "State" -> "stride calculation" -> "kernel selection" -> "kernel" -> "amplitudes"
$

This separation allows the same statevector representation and instruction interface to be used independently of the numerical implementation selected for the host processor.

==== Measurement

Measurement is implemented separately from the instruction execution path because it produces a classical result as well as modifying the quantum state. The #text(purple)[`probabilities`] method first calculates the marginal probabilities of measuring a selected qubit as $|0 angle$ or $|1 angle$. It uses the same big-endian stride calculation as gate application to identify the amplitudes associated with each outcome.

The measurement operation then samples an outcome according to these probabilities. Once an outcome has been selected, amplitudes inconsistent with that outcome are set to zero and the remaining amplitudes are renormalised by the square root of the corresponding probability. This produces the post-measurement state while preserving its normalisation.

==== State access and validation

The #text(purple)[`State`] object also provides accessors for the amplitude buffer, number of qubits and state norm. The amplitude buffer is exposed as an immutable slice, allowing the state to be inspected without transferring ownership of its underlying storage.

Validation is performed before operations reach the kernels. For example, a single-qubit operation checks that its target exists, while a controlled operation additionally checks that its control and target are distinct. The kernels can therefore operate on already validated indices and strides. Internal indexing operations use `debug_assert` checks where appropriate, keeping safety checks available during development without adding the same validation overhead to release execution.

==== Memory and optimisation considerations

The implementation deliberately avoids allocating a new statevector when applying a gate. The portable and FMA kernels operate directly on the existing amplitude buffer, temporarily holding only the small number of amplitudes required for the current pair. This keeps the additional working memory required for gate application constant with respect to the number of qubits.

The repository also retains earlier Kronecker-based kernels as deprecated implementations. These construct the full-system matrix from the gate and identity matrices before multiplying it by the statevector. They are retained as a reference implementation and for direct benchmarking against the strided approach, while the active execution path uses direct indexing.

The resulting design separates the representation of the quantum state from the numerical kernels used to manipulate it. The `State` object manages the state, validates operations and determines how the statevector should be accessed, while the kernels perform the corresponding numerical transformation. This provides a common execution path for the supported gates while allowing the underlying implementation to be replaced with progressively more specialised versions for different processor capabilities.
