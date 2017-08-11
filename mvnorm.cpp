#include <TMB.hpp>

template<class Type>
Type objective_function<Type>::operator() ()
{
  PARAMETER_VECTOR(u);
  PARAMETER_MATRIX(S);
  DATA_INTEGER(atomic);
  return density::MVNORM(S, atomic)(u);
}
