[Mesh]
  # length scale -> microns
  type = GeneratedMesh
  dim = 2
  xmax = 100
  nx = 10
  ymax = 50
  ny = 5
  uniform_refine = 4
[]

[AuxVariables]
  [./f_dens]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[AuxKernels]
  [./f_dens]
    type = TotalFreeEnergy
    interfacial_vars = 'c_c eta'
    f_name = f_loc
    kappa_names = 'kappa_c kappa_eta'
    variable = f_dens
  [../]
[]

[Variables]
  [./c_c]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type =   BoundingBoxIC
      x1 = 0
      x2 = 50
      y1 = 0
      y2 = 10
      inside = 0.8
      outside = 1e-3
    [../]
  [../]

  [./w_c]
    order = FIRST
    family = LAGRANGE
  [../]

  [./eta]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = BoundingBoxIC
      x1 = 0
      x2 = 50
      y1 = 0
      y2 = 10
      inside = 0
      outside = 1
    [../]
  [../]
[]

[Kernels]
  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]

  [./ACBulk]
    type = AllenCahn
    variable = eta
    args = c_c
    f_name = f_loc
    mob_name = L
  [../]

  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa_eta
  [../]

  [./c_c_res]
    type = SplitCHParsed
    variable = c_c
    f_name = f_loc
    kappa_name = kappa_c
    w = w_c
    args = eta
  [../]

  [./w_c_res]
    type = SplitCHWRes
    variable = w_c
    mob_name = M
  [../]

  [./time_c]
    type = CoupledTimeDerivative
    variable = w_c
    v = c_c
  [../]
[]

[Materials]
  [./constants_CH]
    type = GenericConstantMaterial
    prop_names  = 'L kappa_eta'
    prop_values = '1 2'
  [../]

  [./constants_AC]
    type = GenericConstantMaterial
    prop_names  = 'M kappa_c'
    prop_values = '0.01 0'
    #Smaller mob fixed negative composition on gas side
    #Increasing W brought it back, but symetric
  [../]

  [./switching]
    type = SwitchingFunctionMaterial
    function_name = h
    eta = eta
    outputs = exodus
    h_order =  HIGH
    #args = 'eta'
    #function = 'eta*eta*eta*(6.0*eta*eta -15.0*eta +10.0)'
  [../]

  [./barrier]
    type = BarrierFunctionMaterial
    function_name = g
    eta = eta
    outputs = exodus
    g_order = SIMPLE
   #args = 'eta'
   #function = 'eta*eta*(1.0 -eta)^2.0'
  [../]

  [./free_energy_f]
    type = DerivativeParsedMaterial
    f_name = f_f
    args = 'c_c'
    constant_names = 'Ef_v kb T'
    constant_expressions = '8.0 8.6173303e-5 1000.0'
    function = 'kb*T*c_c*plog(c_c,1e-4) + (Ef_v*(1-c_c) + kb*T*(1-c_c)*plog((1-c_c), 1e-4))'
    derivative_order = 2
    #outputs = exodus
  [../]

  [./free_energy_g]
    type = DerivativeParsedMaterial
    f_name = f_g
    args = 'c_c'
    constant_names = 'A'
    constant_expressions = '1.0'
    function = 'A*0.5*(c_c^2)'
    derivative_order = 2
    #outputs = exodus
  [../]

  [./free_energy_loc]
    type = DerivativeParsedMaterial
    f_name = f_loc
    constant_names = 'W'
    constant_expressions = '20.0'
    args = 'c_c eta'
    material_property_names = 'h(eta) g(eta) f_g(c_c) f_f(c_c)'
    function = 'h * f_g + (1 - h) * f_f + W * g'
    derivative_order = 2
    #outputs = exodus
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'
  solve_type = 'NEWTON'
  #petsc_options_iname = '-pc_type -sub_pc_type'
  #petsc_options_value = 'asm lu'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  l_max_its = 10
  l_tol = 1.0e-8

  nl_max_its = 20
  nl_rel_tol = 1.0e-8

  start_time = 0.0

  dtmax = 10
  dtmin = 1e-9

  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    percent_change = 0.1
    dt = 1e-3
    initial_direction = 1
  [../]

  [./Adaptivity]
    refine_fraction = 0.5
    coarsen_fraction = 0.1
    max_h_level = 6
  [../]

[]

[Postprocessors]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = f_dens
  [../]
  [./timestep]
    type = TimestepSize
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  print_perf_log = true
  file_base = ./NASA_TPS_fiber_2d_v5/NASA_TPS_fiber_2d_v5
[]

[Debug]
  show_var_residual_norms = true
[]