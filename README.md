# Dumpstack

This repo demonstrates how to dump the CppAD stack from TMB and
visualize the computational graph.

## General usage

Define the preprocessor *before* including the TMB header:

```cpp
#define CPPAD_FORWARD0SWEEP_TRACE 1
#include <TMB.hpp>
// Model code here
```

Then compile *without precompilation*:

```r
compile("model.cpp", libtmb=FALSE)
```

To dump the stack use

```r
obj$env$f(dumpstack=1)
```

## Examples
