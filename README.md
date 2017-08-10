# Dumpstack

This repo demonstrates how to dump the CppAD stack from TMB and
visualize the computational graph.

## Requirements

* Command line tools:
   ```shell
   apt-get install graphviz inkscape
   ```
* Upcoming TMB version 1.7.12 or current master branch installed using
   `make cran-version`.

## General usage

To enable tracing of the operation stack compile a model using:

```r
compile("model.cpp", tracesweep=TRUE)
```

This will set the preprocessor flag `CPPAD_FORWARD0SWEEP_TRACE`.

To dump the stack use

```r
obj$env$f(dumpstack=TRUE)
```

## Examples

```
R --slave < dumpstack.R
```
