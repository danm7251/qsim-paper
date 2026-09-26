#import "../equations.typ": *

#heading[Background]

#text(red)[*Note: Flesh out explanations, add references and missing content - Sunday 2h*]

// Intro Paragraph
The following chapter will explore some of the concepts that will appear regularly in the following chapters. Additionally it will add some context surrounding current quantum simulators and related works.

// Prerequisites
Throughout this chapter the following mathematical background will be assumed:
- Binary arithmetic
- Complex numbers
- Linear algebra

== Statevectors
// Explain high-level concepts like Qubits, State, Circuit
An $n$-qubit statevector represents a quantum state using $2^n$ complex amplitudes, it is conventionally written as:

$
  ket(psi)=sum_(i = 0)^(2^n - 1) alpha_i ket(i)
$

where $ket(i)$ is the computational basis state and $alpha_i$ is its associated probability amplitude. The probability of observing $ket(i)$ is $|alpha_i|^2$ which requires the normalisation condition:

$
  sum_(i = 0)^(2^n - 1) |alpha_i|^2 = 1
$

If a fixed ordering of the basis states is assigned, the state can be represented computationally by a column vector:

$
  ket(psi) =
  mat(
    alpha_0;
    alpha_1;
    dots.v;
    alpha_(2^n - 1)
  )
  in CC^(2^n)
$

Therefore the space complexity for a statevector must be $O(2^n)$.

== Gates
Quantum gates are operations that are applied to a quantum state. When the state is represented as a statevector, a gate is represented as a matrix and applied using matrix-vector multiplication:

$
  ket(psi') = U ket(psi)
$

where $U$ is a gate matrix and $ket(psi')$ is the resulting changed state.

All gate matrices (except for measurement gates) are unitary, meaning they preserve the normalisation of the state and can be reversed by simply applying them again. A gate that acts on $k$ qubits will be represented by a $2^k times 2^k$ matrix.

Common single-qubit gates include the Pauli $X$, $Y$ and $Z$ gates as well as the Hadamard gate $H$:

$
  X=#x_matrix, quad Y=#y_matrix, quad Z=#z_matrix, quad H=#hadamard_matrix
$

However gates do not only need to be single-qubit, some common two-qubit gates are control gates and $"SWAP"$ gates:

$
  "CNOT"=#cnot_matrix, quad "CY"=#cy_matrix, \
  "CZ"=#cz_matrix, quad "SWAP"=#swap_matrix,
$

The controlled gates take two qubits, one control, one target. The premise is simple, if the control qubit is one, apply the operation to the target qubit. The $"SWAP"$ gate only takes two target qubits and switches their values no matter what.

// Mehhhh

Earlier it was stated that to apply a matrix to the statevector matrix-vector multiplication is used. But for this multiplication to be valid the number of columns in the matrix must be equal to the number of amplitudes in the vector. In most situations a statevector is more than one qubit. So to apply a single-qubit gate a full-system matrix that fulfils this can be used. This can be constructed using Kronecker products.

== Kronecker products
The Kronecker product, denoted by $times.o$, combines two smaller matrices to produce a larger matrix. Every element in the first matrix is multiplied by the second matrix. If matrix $A$ has dimensions $a times b$ and matrix B has dimensions $c times d$ then $A times.o B$ produces a matrix with dimensions $a c times b d$.

Therefore in statevector simulation it can be used to expand a gate matrix to a full-system matrix that is valid for multiplication with the statevector. For single-qubit gates:

$
  tilde(U)_t=I^(times.o t) times.o U times.o I^(\(n-t-1\))
$

#text(red)[*Note: Find source*]

Where $tilde(U)_t$ is the full-system matrix of a single-qubit gate at target $t$ and $I^(times.o t)$ denotes the Kronecker product of $t$ identity matrices. An identity matrix is a no-op which is why the gate can be expanded this way without distorting the operation.

For controlled two qubit gates it becomes more complex. They full-system matrix of such a gate can be expressed as:

$
  tilde("CU")_(c,t)=P_0 times.o I + P_1 times.o U
$

Where $tilde("CU")_(c,t)$ is the full-system matrix of a controlled two-qubit gate, and projectors $P_0$ and $P_1$ expand as:

$
  ket(0)bra(0) = #p0_matrix, quad ket(1)bra(1) = #p1_matrix
$

Since $I ket(psi)=ket(psi)$ leaving the state unchanged, this represents the branch where the controlled gate is not triggered, $P_0$ simply maps this onto the corresponding amplitudes. Vice versa, $P_1$ maps the operation $U$ onto the amplitudes where the control qubit is activated. The downside being that two full-system matrices must be constructed and combined before being applied.

#text(red)[*Note: Source tenessee university, this equation is simplified*]

It is clear, the time and space complexity of this naive approach is far too great, not to mention in addition to the system matrix, a simulator is already having to store the statevectors $2^n$ complex amplitudes in memory. It turns out that there is an approach that both limits the simulators space complexity to the base $O(2^n)$ and also speeds up execution time with workloads much more suited to modern processors.

== Direct indexing
Rather than attempting to apply a full-system matrix to the entire statevector, this approach splits the statevector into smaller two-dimensional subspaces, pairs of amplitudes whose basis states differ only in the target qubits value. Then each pair can be multiplied independently by the simpler $2 times 2$ gate matrix itself.

Iterating through the $2^(n-1)$ pairs means each amplitude in the statevector is operated on once. Applying the gate to each pair is mathematically equivalent to applying the full-system matrix to the entir

#text(red)[*Note: Find source (QuEST paper?) and detailed proof*]

The resulting amplitudes can be written back into the statevector while the while the two necessary original amplitudes and the four matrix coefficients are already available in memory. This removes any non-constant space complexity terms that are being added to the statevectors already harsh $O(2^n)$ space complexity during gate application.

// Stabilizer
== Gottesman-Knill theorem
Updating the statevector pair by pair is orders of magnitude more efficient however is still bound by the $O(2^n)$ space required to store the amplitudes themselves. The GK theorem poses the question: can the state of a quantum system be represented more compactly and if so for what classes of circuits does this hold?

The answer is yes, with stabilizer circuits. This is a class of circuit that is composed entirely of Clifford gates, a set of gates that includes but is not limited to: the Pauli $X$, $Y$ and $Z$ gates, the Hadamard gate and the $"CNOT"$ gate. The set of possible states allowed by such gates allows a different representation, rather than tracking the amplitudes of every basis state, it can be described by the Pauli operators that stabilise it.

For a state $ket(psi)$ an operator $S$ is a stabiliser if:

$
  S ket(psi) = ket(psi)
$

so, if it leaves the state unchanged.

#text(red)[*Note: As wierdly worded as GK theorem is, find way to reword this, add source. Expand on this if there is time, if not remove.*]

// Computational concepts

// Related works