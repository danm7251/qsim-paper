#let ket(x) = $lr(bar.v #x chevron.r)$
#let bra(x) = $lr(chevron.l #x bar.v)$

#let hadamard_matrix = $
    frac(1, sqrt(2))
    mat(delim: "[", 1, 1; 1, -1;)
$

#let identity_matrix = $
    mat(delim: "[", 1, 0; 0, 1;)       
$

#let x_matrix = $
    mat(delim: "[", 0, 1; 1, 0;)                  
$

#let y_matrix = $
    mat(delim: "[", 0, -i; i, 0;)                 
$

#let z_matrix = $
    mat(delim: "[", 1, 0; 0, -1;)
$

#let cnot_matrix = $
  mat(delim: "[",
    1, 0, 0, 0;
    0, 1, 0, 0;
    0, 0, 0, 1;
    0, 0, 1, 0;
  )
$

#let cy_matrix = $
  mat(delim: "[",
    1, 0, 0, 0;
    0, 1, 0, 0;
    0, 0, 0, -i;
    0, 0, i, 0;
  )
$

#let cz_matrix = $
  mat(delim: "[",
    1, 0, 0, 0;
    0, 1, 0, 0;
    0, 0, 1, 0;
    0, 0, 0, -1;
  )
$

#let swap_matrix = $
  mat(delim: "[",
    1, 0, 0, 0;
    0, 0, 1, 0;
    0, 1, 0, 0;
    0, 0, 0, 1;
  )
$

#let p0_matrix = $
  mat(delim: "[",
    1, 0;
    0, 0;
  )
$

#let p1_matrix = $
  mat(delim: "[",
    0, 0;
    0, 1;
  )
$

#hadamard_matrix
#identity_matrix
#x_matrix
#y_matrix
#z_matrix