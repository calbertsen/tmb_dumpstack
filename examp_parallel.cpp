#define CPPAD_FORWARD0SWEEP_TRACE 1
#include <TMB.hpp>

template<class Type>
Type objective_function<Type>::operator() ()
{
  PARAMETER_VECTOR(u);
  parallel_accumulator<Type> ans(this);
  ans += pow(u[0], 2);
  for(int i=1; i<u.size(); i++)
    ans += pow(u[i] - u[i-1], 2);
  return ans;
}
