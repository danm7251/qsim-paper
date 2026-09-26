#heading(numbering: none, outlined: true)[
    Appendix
]

#figure(
  table(
    columns: 3,
    [Qubits], [Full-system matrix (ms)], [Direct indexing (ms)],
    [3], [0.000623], [0.000033],
    [5], [0.009367], [0.000109],
    [7], [0.15016], [0.000343],
    [9], [2.469403], [0.001218],
    [11], [47.624858], [0.004629],
    [13], [793.488575], [0.017875],
  ),
  caption: [Hadamard gate execution time for full-system matrix expansion and direct indexing.]
)

#figure(
  table(
    columns: 3,
    [Qubits], [Full-system matrix (ms)], [Direct indexing (ms)],
    [3], [0.001106], [0.000036],
    [5], [0.016174], [0.000075],
    [7], [0.245583], [0.000188],
    [9], [5.016699], [0.000642],
    [11], [94.779459], [0.002286],
    [13], [1366.488455], [0.009295],
  ),
  caption: [CNOT gate execution time for full-system matrix expansion and direct indexing.]
)

#figure(
  table(
    columns: 3,
    [Qubits], [Hadamard (MB)], [CNOT (MB)],
    [3], [0.001344], [0.002496],
    [5], [0.020544], [0.037056],
    [7], [0.327744], [0.590016],
    [9], [5.242944], [9.437376],
    [11], [83.886144], [150.995136],
    [13], [1342.177344], [2415.919296],
  ),
  caption: [Peak memory usage of full-system matrix expansion for Hadamard and CNOT gates.]
)


#figure(
  table(
    columns: 4,
    [Qubits], [Portable (µs)], [FMA (µs)], [AVX (µs)],
    [3], [0.032974], [0.029392], [0.018314],
    [5], [0.107920], [0.073119], [0.047978],
    [7], [0.352090], [0.271980], [0.164130],
    [9], [1.205300], [0.918370], [0.622740],
    [11], [4.576000], [3.254700], [2.513300],
    [13], [18.508000], [12.715000], [10.356000],
    [15], [72.479000], [49.887000], [41.201000],
    [17], [280.930000], [202.460000], [163.710000],
    [19], [1203.100000], [857.450000], [760.220000],
  ),
  caption: [Hadamard gate execution time for hardware-accelerated kernels.]
)