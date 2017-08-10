#include <TMB.hpp>

template<class Type>
Type objective_function<Type>::operator() ()
{
  PARAMETER_VECTOR(u);
  Type ans=0;
  ans += pow(u[0], 2);
  for(int i=1; i<u.size(); i++)
    ans += pow(u[i] - u[i-1], 2);
  return ans;
}
