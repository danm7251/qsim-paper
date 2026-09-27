= Introduction

Quantum computing is an emerging technology that leverages principles of quantum mechanics at the hardware level to create computers that are capable of performing computations in a fundamentally different way to classical machines. For specific classes of problems this 'quantum advantage' can be utilised by carefully designed algorithms to achieve non-trivial improvements in computational complexity @aaronson_limits_2008.

However, the field is in the Noisy Intermediate Scale Quantum (NISQ) era, characterized by processors that are constrained in size (number of qubits) and lack fault tolerance. In this context, a lack of fault tolerance means that processors are not yet stable enough to correct the errors introduced by cumulative external noise @lau_nisq_2022. Beyond these technical limitations, the hardware remains a scarce resource; it is extremely expensive to build, maintain and run a quantum computer. While cloud-based providers, such as Microsoft Azure Quantum and Amazon Braket, have improved access to quantum computing by offering Quantum-as-a-Service (QaaS), access to high-performance chips can involve long wait times and non-trivial usage fees, which can pose an obstacle to development @ravi_quantum_2021.

Due to these constraints, the ability to simulate quantum circuits on classical hardware remains essential. Quantum circuit simulation involves evaluating the effect of a series of logic gates mathematically on a representation of a quantum state. This approach provides an environment free of the typical environmental noise inherent to current quantum hardware and is far more cost effective. As such, currently, the most practical way to develop and test quantum algorithms is to use classical simulators of quantum computers @cicero_simulation_2025.

However, simulation comes with its own set of limitations. The core issue is the memory cost of describing a quantum state classically. The base units of quantum information are qubits (quantum bits) and the direct conventional approach is known as statevector simulation in which to fully describe a quantum system of $N$ qubits requires tracking $2^N$ individual complex amplitudes. Even on a supercomputer such as Summit @facility_summit_2018, we can only do algorithmic simulations of a quantum circuit up to 47 qubits, which requires 2.8 petabytes of memory @cicero_simulation_2025. Mitigating this scaling is an active area of research with many approaches that trade exactness for tractability, but in the end this limitation is not escapable, as it is an inherent consequence of mapping quantum information onto classical hardware.

One of the approaches to simulation that trades exactness for tractability is known as matrix product states or MPS. Which reduces the number of parameters from $2^n$ to roughly $2n chi^2$ where $chi$ represents the amount of entanglement (a property of quantum states) that can be represented. However this is at the cost of only being able to express an approximation of the state when $chi$ is low and entanglement high @xu_herculean_2025. The stabilizer formulism offers another approach to reducing computational cost, but similarly, only allows the simulation of specific classes of quantum circuits, losing the flexibility of other simulation methods. 

#text(red)[*Note: Flesh out & insert 1 extra paragraphs from draft and polish - Sunday 30m*]

// Paragraph 3:
// - Describe what my paper does broadly.
// - Investigates quantum circuit simulator design and algorithms
// - Does this directly through implementation/development.
// - Evaluates approaches through benchmarking.
// - Also takes the chance to explore non-paradigm improvements
// - For example: Inlining, cache performance, SIMD, compiler opts.
// - Explores superficial qualities such as natural API
// - Evaluates what my project offers compared to others (density, samples) etc

This paper aims to investigate the implementation of quantum circuit simulators, focusing on statevector simulation techniques. The objectives are to develop a statevector simulator, investigate the algorithms used to execute quantum operations and evaluate their computational characteristics across various workloads.

Explicit objectives:
- Implement a functional quantum circuit simulator using a statevector representation.
- Implement common single-qubit gates, controlled two-qubit gates and measurement.
- Implement multiple high-level approaches to computing the application of quantum operations including full-system matrix and direct pair multiplication.
- Implement multiple low-level approaches to computing the application of quantum operations utilising hardware acceleration.
- Evaluate the computational characteristics of approaches.

// Contributions
// - 1) What I actually produced
// - 2) What is novel/useful about my work

// Paragraph 1: TODO

// Paragraph 2: TODO

// Dissertation Structure
// - 1) Brief summary of each chapter

// Paragraph 1: TODO