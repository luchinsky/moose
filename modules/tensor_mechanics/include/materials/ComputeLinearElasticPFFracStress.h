/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef COMPUTELINEARELASTICPFFRACSTRESS_H
#define COMPUTELINEARELASTICPFFRACSTRESS_H

#include "ComputeStressBase.h"
#include "Function.h"

/**
 * Phase-field fracture
 * This class computes the stress and energy contribution to fracture
 * Small strain Anisotropic Elastic formulation
 * Stiffness matrix scaled for heterogeneous elasticity property
 */
class ComputeLinearElasticPFFracStress : public ComputeStressBase
{
public:
  ComputeLinearElasticPFFracStress(const InputParameters & parameters);

protected:
  virtual void computeQpStress();

  const VariableValue & _c;
  /// Small number to avoid non-positive definiteness at or near complete damage
  Real _kdamage;

  MaterialProperty<Real> & _F;
  MaterialProperty<Real> & _dFdc;
  MaterialProperty<Real> & _d2Fdc2;
  MaterialProperty<RankTwoTensor> & _d2Fdcdstrain;
  MaterialProperty<RankTwoTensor> & _dstress_dc;
};

#endif //COMPUTELINEARELASTICPFFRACSTRESS_H
