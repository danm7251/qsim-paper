#import "../equations.typ": *

#heading[Background]

This section will introduce the basics of quantum computing using statevectors and some core principles behind some of the techniques used before introducing an alternative approach to simulation. The material presented in the first four subsections is a brief introduction to the quantum computing foundations required by this project and follows Nielsen and Chuang @nielsen_quantum_2010.

== Qubits
A qubit can be considered the quantum analogue of a bit. Unlike a classical bit which has a value of either one or zero, a qubit is capable of existing as a linear combination of both values.

More precisely a linear combination of two basis states, $ket(0)$ and $ket(1)$. However, when measured this qubit will collapse into one of the two basis states probabilistically. The definition of a qubit is show below: 

$
  ket(psi)=alpha ket(0)+beta ket(1)
$

Where $alpha$ and $beta$ are complex numbers whose square moduli give the probability of each outcome during collapse. For a valid qubit the total probability, or the probability of there being an outcome at all, must be one. This is often referred to as the normalisation condition:

$
  |alpha|^2 + |beta|^2=1
$

== Gates

Quantum gates or operators as they are also known, are operations that are applied to qubits and form the building blocks of quantum circuits. A gate is represented by a matrix and applied using matrix-vector multiplication. This can be visualised in detail by using vector notation:

$
  ket(psi') =
  U ket(psi)
  =
  mat(
    delim: "[",
    a, b;
    c, d;
  )
  mat(
    delim: "[",
    alpha;
    beta;
  )
  =
  mat(
    delim: "[",
    a alpha + b beta;
    c alpha + d beta;
  )
$

where $ket(psi')$ is the resulting changed qubit, $U$ is an arbitrary gate matrix, $a$, $b$, $c$ and $d$ are the matrix coefficients and $alpha$ and $beta$ are the probability amplitudes of the qubits original state.

All gate matrices (aside from measurement gates) are unitary, meaning:
- they preserve the normalisation condition for the state
- their effects can be reversed by applying their inverse matrix

Common single-qubit gates include the Pauli $X$, $Y$ and $Z$ gates as well as the Hadamard gate $H$:

$
  X=#x_matrix, quad Y=#y_matrix, quad Z=#z_matrix, quad H=#hadamard_matrix
$

== Statevectors
So far a single qubit has been used in examples. However, there is not much computation that can be done with only a single qubit. Quantum algorithms typically run on many-qubit systems, so while in previous sections $ket(psi)$ represented a qubit it should actually be considered a single qubit statevector.

A statevector represents a quantum state of $n$-qubits by using $2^n$ complex amplitudes, and when generalising across $n$ qubits it is conventionally written in the form:

$
  ket(psi)=sum_(i = 0)^(2^n - 1) alpha_i ket(i)
$

where $ket(i)$ is the $i$th basis state and $alpha_i$ is its associated probability amplitude.

Basis states are typically numbered in binary notation rather than decimal i.e $ket(010)$. This set of basis states are known as the computational basis and measuring a system always results in one of them. So for example, a system can be said to be in the computational basis state $ket(010)$ when all other basis states have amplitudes equal to zero. Simulations conventionally begin in the all-zero state $ket(0 dots 0)$. The normalisation condition can then be generalised to:

$
  sum_(i = 0)^(2^n - 1) |alpha_i|^2 = 1
$

To represent a statevector computationally, a fixed ordering of the basis states is assigned, either big or little endian. This project uses big-endian ordering where qubit zero is the leftmost bit of the binary label and therefore the most significant. This allows the state to be represented in a more computation friendly format as a column vector:

$
  ket(psi) =
  mat(
    delim: "[",
    alpha_0;
    alpha_1;
    dots.v;
    alpha_(2^n - 1)
  )
  in CC^(2^n)
$

As a logical consequence of storing these amplitudes, the space complexity for a simulated statevector is $O(2^n)$.

== Multi-qubit gates
Just as with single-qubit gates a gate that acts on multiple qubits will be a matrix. The number of qubits it operates on has the following relationship with its dimensions, a $k$ qubit gate will be represented by a $2^k times 2^k$ matrix. A common two-qubit gate is the SWAP gate:

$
  "SWAP"=#swap_matrix,
$

Which has the property of swapping the amplitudes of two qubits unconditionally.

Another key type of gate is the controlled gate, which allows branching and more complex behaviour in quantum circuits. Common controlled two-qubit gates include the controlled Pauli matrices:

$
  "CNOT"=#cnot_matrix, quad "CY"=#cy_matrix, quad "CZ"=#cz_matrix,
$

The way these gates function is that they 'take' two qubits, a control and a target qubit. If the control qubit is one then they apply the single-qubit pauli gate to the target qubit. However this perhaps overstates the simplicity when one takes into account the fact that in a quantum circuit the control qubit can be in a superposition of both one and zero simultaneously.

== Kronecker products
In section 2.2 (gates), it was stated that to apply a gate to a qubit matrix-vector multiplication is used. But once the state is made up of multiple qubits, applying valid matrix-vector multiplication would fail. This is because the operation requires that the number of columns in the matrix are equal to the number of rows in the column vector. So to apply a gate matrix to an $n$-qubit statevector, the matrix can be expanded to a full-system matrix with $2^n$ columns. This is done by using the Kronecker product.

The Kronecker product, denoted by $times.o$, combines two smaller matrices to produce a larger matrix, where every element in the first matrix is multiplied by the second matrix. If matrix $A$ has dimensions $a times b$ and matrix B has dimensions $c times d$ then $A times.o B$ produces a matrix with dimensions $a c times b d$.

Therefore it can be used to expand a gate matrix to a full-system matrix that can be applied to a quantum system's statevector. For a single-qubit gate this can be described as:

$
  tilde(U)_t=I^(times.o t) times.o U times.o I^(\(n-t-1\))
$

Where $tilde(U)_t$ is the full-system matrix of a single-qubit gate with a target qubit index $t$ and $I^(times.o t)$ denotes the Kronecker product of $t$ identity matrices. An identity matrix produces no effect on the statevector which is why the gate can be expanded this way without distorting the operation. For controlled two-qubit gates there exists a more complex formula:

$
  tilde("CU")_(c,t)=P_0 times.o I + P_1 times.o U
$

Where $tilde("CU")_(c,t)$ is the full-system matrix of a controlled two-qubit gate, and the projectors $P_0$ and $P_1$ are defined as:

$
  P_0 = ket(0)bra(0) = #p0_matrix, quad P_1 = ket(1)bra(1) = #p1_matrix
$

As $I ket(psi)$ leaves the state unchanged, $P_0 times.o I$ represents the branch where the controlled gate is not triggered, $P_0$ projects the identity matrix onto the corresponding amplitudes. By the same token, $P_1$ maps the operation $U$ onto the amplitudes where the control qubit is activated. Notably this requires two full-system matrices to be constructed and then combined before being applied.

It is evident that gate application on many-qubit statevectors has an enormous computational cost when being modelled on classical hardware. Full-system matrices having a space complexity of $O(4^n)$ and controlled two-qubit gates require two full-system matrices. In addition while these operations are being executed the statevector still needs to remain in memory with its own space complexity of $O(2^n)$.

This full-system matrix approach is therefore used as the baseline implementation for evaluating alternative gate-application methods that are developed in this paper. Its performance provides a reference against which the computational and memory benefits of other strategies can be measured.

== Direct pair multiplication (DPM)
Rather than attempting to apply a full-system matrix to the entire statevector, there is an approach that limits a simulation's space complexity to that of the statevector's while also improving execution time with workloads much more suited to modern processors.

This approach decomposes the $2^n$-element statevector into $2^(n-1)$ disjoint, two-dimensional subspaces. Specifically, each subspace groups pairs of amplitudes whose binary representations differ only at the target qubits position $q$. For each pair the first element is at base index $n_i$ where qubit $q$ has a value of zero and the second element is at index $n_i + s$ where $s$ can be defined as the stride between the two pairs as $s=2^(n - q - 1)$.

Each pair can then be multiplied independently by the base $2 times 2$ gate matrix itself, before writing the resulting vector's elements back into their original positions in the statevector:

$
  mat(
    a_(n_i);
    a_(n_i + s);
  )
  mapsto
  U
  mat(
    a_(n_i);
    a_(n_i + s);
  )
$

The $2^(n-1)$ pairs collectively contain every amplitude in the statevector once. Applying the gate to each pair therefore is mathematically equivalent to applying the full-system matrix to the entire statevector in one operation. @jones_quest_2019

The resulting amplitudes can be written back into the statevector while the two necessary original amplitudes and the four matrix coefficients are already available in memory. This adds no memory requirements other than the statevectors $O(2^n)$ space complexity during gate application.

Therefore DPM removes the overhead of applying gates but the statevector itself still holds $2^n$ amplitudes so memory grows exponentially with the number of qubits regardless of how gates are applied. Reducing this requires a more compact state representation which, without reducing accuracy, is only possible for a restricted class of circuit.

== Gottesman-Knill theorem
The Gottesman-Knill theorem @aaronson_improved_2004 states that a quantum circuit consisting only of Clifford gates can be simulated efficiently on a classical computer when it begins in a computational basis state and ends with measurements in the computational basis.

Clifford gates are any gate that transform a Pauli operator into another Pauli operator when applied to it. Any Clifford gate can be built from a sequence of Hadamard, $S$ and $"CNOT"$ gates and the Pauli operators $X$, $Y$ and $Z$ are Clifford gates themselves.

Circuits composed entirely of Clifford gates are known as stabiliser circuits, since the states they produce can always be described by the Pauli operators that stabilise them. A Pauli operator on $n$ qubits consists of $n$ single-qubit factors, one per qubit, where each factor is $I$, $X$, $Y$ or $Z$, together with an overall sign. For example $X I Z$ would apply $X$ to the first qubit and $Z$ to the third while leaving the second unchanged. A Pauli operator $P$ is said to stabilise a state $ket(psi)$ if:

$
  P ket(psi) = ket(psi)
$

where applying it leaves the state unchanged. A stabiliser state of $n$ qubits can be described as list of $n$ Pauli operators. Each operator is stored as $n$ bits marking the qubits with an $X$ factor and $n$ bits marking the qubits with a $Z$ factor ($Y$ is marked as both) plus a single bit for the sign. The whole state can thus only requires $O(n^2)$ bits rather than a statevectors $O(2^n)$ amplitudes.

== Key points

The above sections have summarised the three primary strategies that this paper will use to simulate quantum circuits, and also the background theory that they are built upon:
- Full-system matrices, follow directly from the basic theory and have clear drawbacks, namely their $O(4^n)$ space complexity.
- Direct pair multiplication is a direct upgrade, offering improvements in both space and time complexity.
- Stabiliser simulation offers both the highest memory and runtime performance but heavily restricts the types of circuits that can be simulated.

The following section will discuss how they were actually implemented.