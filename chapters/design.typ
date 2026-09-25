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

==== Statevector backend

Uses big endian ordering.