#ifndef NSMOMENTUMINVISCIDFLUXWITHGRADP_H
#define NSMOMENTUMINVISCIDFLUXWITHGRADP_H

#include "NSKernel.h"
#include "NSPressureDerivs.h"

// ForwardDeclarations
class NSMomentumInviscidFluxWithGradP;

template<>
InputParameters validParams<NSMomentumInviscidFluxWithGradP>();

class NSMomentumInviscidFluxWithGradP : public NSKernel
{
public:

  NSMomentumInviscidFluxWithGradP(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  // Coupled gradients
  VariableGradient& _grad_p;

  // Parameters
  int _component;

private:
  // Computes the Jacobian contribution due to the pressure term,
  // by summing over the appropriate Hessian row.
  Real compute_pressure_jacobian_value(unsigned var_number);

  // Single vector to refer to all gradients.  We have to store
  // pointers since you can't have a vector<Foo&>.  Initialized in
  // the ctor.
  std::vector<VariableGradient*> _gradU;

  // An object for computing pressure derivatives.
  // Constructed via a reference to ourself
  NSPressureDerivs<NSMomentumInviscidFluxWithGradP> _pressure_derivs;

  // Declare ourselves friend to the helper class.
  template <class U>
  friend class NSPressureDerivs;
};

#endif
