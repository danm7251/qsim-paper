#heading[Design & Implementation]

== Development environment

Rust was chosen as the primary development language for its performance and safety guarantees while still allowing unsafe, direct memory management if necessary. Its zero-cost abstractions allow higher level intuitive interfaces to be used without causing additional runtime overhead.

Git was used for version control throughout so that branches could be used to develop experimental features in isolation from the main implementation. Additionally this allowed individual experiments and benchmarks to be associated with specific commits for reproducibility.

GitHub was used to host the source code and provide continuous integration through GitHub Actions. Automated unit tests were run on pushes to the default branch, on Windows and Ubuntu environments, providing correctness checks across platforms, ensuring that changes did not introduce subtle logic bugs and or unnaceptably compromise accuracy.

== Library Architecture & Implementation

A software library was selected as the project format. This way the simulation can be exposed through a programmatic interface rather than being directly coupled to a particular application or user interface. In future it could be extended with a simulator application that utilises the library while the functionality remains independently accessible.

The library can be organised into three principle layers: the circuit representation, simulation state objects and kernels. The circuit representation describes the operations to be executed, simulation objects maintain simulation state and coordinate execution and kernels implement the mathematical transformations required by operations.

=== Circuit Representation

This project seperates the description of a quantum circuit from the statevector object used to simulate its execution. Quantum operations are represented as instructions defining the operations themselves and contain parameters pertaining to non-implementation specific information. For example rotation gate angles and qubit targeting indices. This results in a clean interface that allows introducing alternative simulation objects with different state representations in the future, such as stabilizer-based simulation without requiring changes to the circuit representation.

The core component of this interface is the #text(purple)[Instruction] enum which provides variants describing different quantum operations, mainly gates. Each variant defines the parameters that may accompany it explicitly, creating a fixed structure for required inputs. The use of an enum also offers a common type the operations can be stored and processed through, making it straightforward to express an entire circuit as an ordered collection of instructions. That ability naturally lends itself to future extensions such as circuit level optimisation as the sequence could be analysed and transformed before execution.

=== Statevector

A simulation starts by initialising a simulation object such as a statevector, with the desired number of qubits. That statevector then owns the quantum state being simulated using a heap-backed buffer of amplitudes and supplies the interface through which operations can be applied. To progress the simulation an instruction or a circuit as a collection of instructions must be passed to the statevector for execution.

The statevector then acts as a validation and dispatch layer above the operations themselves during execution, while owning the amplitude buffer. By first matching on the instruction the statevector can extract the parameters to perform the necessary validation checks. Validation within the instructions themselves was considered, but checks such as target qubit bounds depend on the state itself. Keeping it in the statevector avoids splitting related checks between the instructions and the statevector object.

After validation, the statevector translates the qubit indices into statevector strides for DPM, its primary simulation strategy, where a stride represents the distance between corresponding amplitudes in the amplitude buffer. This is determined by the position of the target qubit within the chosen big-endian structure. Despite appearing to be a low-level implementation detail, generating the strides in this layer, decouples the kernels that will recieve them from the memory layout of the buffer.

The statevector also encapsulates a performance configuration that specifies the hardware features to be utilised during execution. This configuration can be resolved automatically at runtime by detecting the host's CPU capabilities or it can be supplied explicitly to request a specific configuration, which is then validated against available host features. This validation is necessary because executing a kernel that uses unsupported hardware features can result in undefined behaviour.

#text(red)[*Reword paragraph below.*]

Measurement is handled directly by the statevector following a different execution path to instructions. As it returns values unlike unitary operations such as gate application, this makes it awkward to fit into the existing circuit representation that lacks a mechanism for collecting results. Calculating measurement probabilities requires iterating over the amplitude buffer according to the target qubit similarly to DPM. The probability calculation is currently implemented directly in the statevector rather than through kernel dispatch despite these similarities. Probability calculation, could be separated into dedicated kernels in a future implementation allowing hardware acceleration. Measurement calculates the marginal probabilities, samples a random distribution constructed from these to determine the outcome and subsequently collapses and renormalises the state.

=== Kernels

#text(red)[*Reword two paragraphs below.*]

The kernels are separated from the main statevector implementation in a submodule containing four implementations: a portable implementation, an FMA implementation and an AVX implementation. Each implementation performs equivalent operations using different levels of hardware-specific optimisation. The portable kernels provide a both DPM and full-system matrix operations, the FMA kernel provides fused multiply-add accelerated DPM operations while the AVX kernel provides SIMD operations that follow from DPM but are adapted to process multiple pairs simultaneously.

In order to simplify dispatch all kernel implementations share the same function naming styles and take the same parameters, a mutable reference to the amplitude buffer, a four element matrix and a target stride calculated by the statevector.

==== Portable DPM kernels

This is the baseline DPM implementation designed to be the baseline strategy executed with no hardware feature requirements. It can conceptually be split into two categories, functions that traverse the amplitudes and identify pairs of amplitudes and a function that, given these pairs and a matrix, performs the matrix-vector multiplication.

The single-qubit gate kernel consists of an outer loop that walks through the statevector in blocks. Each block contains two halves, each the length of a target stride, corresponding to a different value of the target qubit. An inner loop then traverses the first half of each block pairing each amplitude with the corresponding amplitude one target stride ahead.

#text(red)[*Reword two paragraphs below.*]

The controlled two-qubit gate kernel consists adds an extra condition to consider, only amplitudes in which the value of the control qubit is one can be updated. If the control strides are more significant then the first loop walks the statevector in blocks with halves of a control stride. Then the single-qubit gate kernels algorithm can be applied to each block where the control qubit is equal to one. If the target stride is more significant then the outer loop traverses the target blocks before a second loop traverses the control blocks within each target block and a final loop pairs amplitudes in the resulting ranges.

Matrix application for the kernels is handed of to a dedicated helper function. The pair of amplitudes are copied by value into a buffer on the stack and a zeroed stack buffer for the results is initialised before performing the matrix-vector multiplication whereupon the existing statevector amplitudes are overwritten with the results. This function can be considered the most performance-critical point in the entire program and thus every effort was made to eliminate unnecessary overhead.

==== FMA DPM kernels

A set of kernels with traversals algorithmically identical to the portable ones but arithmetic changes to the matrix application. During matrix-vector application fused multiply-add functions are used.

#divider()

The FMA kernels follow the same algorithms as the portable direct indexing kernels but use fused multiply-add operations for the real and imaginary components of complex multiplication. These kernels are compiled with the `fma` target feature to ensure the compiler emits fused-multiply-add assembly and are only selected when the host machine has been verified to support FMA.

The AVX implementation instead utilises an evolution of the direct indexing algorithm that has been rewritten to cast two pairs at once to four-lane SIMD vectors. The real and imaginary components of the amplitudes are interleaved across two four-lane vectors and the matrix coefficients are copied across an entire vector each. Then complex multiplication can be performed on multiple pairs at once increasing throughput. These kernels are compiled with the `avx` target feature to ensure that AVX instructions are actually emitted during compilation and are also required to check AVX support is available on the host machine.

The different kernels therefore represent both different algorithms and different implementations of the same algorithms. Allowing the execution layer to select an implementation appropriate for the available hardware features.

== Testing, benchmarking and observability

Unit tests were used constantly throughout every step of development to ensure the behaviour of the simulator was as expected and innacuracies were not introduced. Due to the use of floating point arithmetic a certain degree of accumulated numerical error is inevitable. However it was required to remain within a tolerance range of $10^(-14)$ throughout tests. The Rust ecosystem also provided tools for investigating performance. 

Criterion.rs, a Rust port of the popular Haskell Criterion package, was used for execution time benchmarking and analysis. It iterates over benchmarks gathering samples and then provides a full statistical breakdown. It also supports direct comparison benchmarks useful for verifying the difference between different approaches and algorithms. This was most useful when it came to developing different gate application algorithms and analysing the effects of compiler directive placement. DHAT was used to investigate the behaviour of heap allocations. It is a custom allocator that once initialised, records the peak and total number of allocations throughout execution.

#text(red)[*Better DHAT explanation.*]

The Tracing crate was used to provide observability insights into circuit execution. Primarily useful when examining sub-routines such as the quantum Fourier transform which expands into a series of gates whose ordering depends on parameters such as qubit count. It provided quality-of-life features such as exporting trace data to Chrome Perfetto for examination.

Rust's feature gating was used extensively throughout in coordination with these features to ensure that any accomodations for benchmarking and tracing did not introduce unnecessary overhead when unactivated.