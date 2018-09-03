# SGA
Surrogate-assisted Genetic Algorithm developed for constrainted mixed integer programming problem.

## Introduction
Evolutionary algorithms (EAs) have been widely used in a variety of
complex real-world applications. However, EAs need to perform a large
number of fitness (or objective) function evaluations to obtain optimal
or near-optimal solutions. For engineering problems, each fitness
function is evaluated via physics-based simulation, which often makes
the whole process computationally expensive. Hyper-heuristics represent
a class of methods that could address this barrier and reduce
computational cost.

A hyper-heuristic search method seeks to automate, often by incorporation
of statistical or machine learning techniques, the process of
handling several simpler heuristics to efficiently solve computational
search problems. The overall goal is to reduce the number of numerical
simulations along a search path at the algorithm level. One popular
paradigm is to construct a so-called surrogate or meta-model that can
approximate the behavior of the original fitness function in the optimization
process.

## Methodology
<img src="https://github.com/YangyangFu/SGA/blob/master/SGA/Resources/images/sga.png" alt="drawing" width="300"/>

<img src="https://github.com/YangyangFu/SGA/blob/master/SGA/Resources/images/sga-psudocode.png" alt="drawing" width="600"/>

At generation ``t``, a surrogate model needs to be updated if its accuracy is not acceptable. The
surrogate model is trained using the database ``D`` that consists of previous
populations ``P`` and their expensive evaluations F<sub>E,P</sub> (Steps 5-10). Then,
crossover and mutation operators are used to generate a surrogate population
``S`` (with size |S| > |P|) (Step 11). The surrogate approximates the
objective values in ``S`` (Step 12), and the F<sub>S</sub> ranks ``S`` (Step 13) with the
highest ranking solutions inserted into the offspring population ``Q`` (with
size ``|Q|=|P|``) (Step 14). ``Q`` are then evaluated using the expensive 
simulations, which will be appended into the database ``D`` if they
are not in ``D`` before. Finally, the offspring ``Q`` are assigned to be the parent
``P`` in the next generation.

## Installation
1. Download the package to local computer.
2. Add package to Matlab path in local computer.
3. Run example SGA/Examples/run_P8.m by setting <code>surrogateuse=0</code> to test conventional GA without surrogate, and setting <code>surrogateuse=0</code> to test surrogate-assisted GA.

## Cite as
Jiachen Mao, Yangyang Fu, Afshin Afshari, Peter R. Armstrong, Leslie K. Norford, Optimization-aided calibration of an urban microclimate model under uncertainty, Building and Environment, Volume 143, 2018, Pages 390-403, ISSN 0360-1323, https://doi.org/10.1016/j.buildenv.2018.07.034.
## Contact
<b>Yangyang Fu</b>

yangyang.fu@colorado.edu

University of Colorado at Boulder
