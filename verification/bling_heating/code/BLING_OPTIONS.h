C $Header: /u/gcmpack/MITgcm/pkg/bling/BLING_OPTIONS.h,v 1.6 2017/03/16 17:03:26 mmazloff Exp $
C $Name:  $

#ifndef BLING_OPTIONS_H
#define BLING_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_BLING
C     Package-specific Options & Macros go here

c Active tracer for total phytoplankton biomass
#define ADVECT_PHYTO

c Prevents negative values in nutrient fields
#define BLING_NO_NEG

c Assume that phytoplankton in the mixed layer experience
c the average light over the mixed layer
c (as in original BLING model)
#define ML_MEAN_LIGHT

c Assume that phytoplankton are homogenized in the mixed layer
#define ML_MEAN_PHYTO

c Sub grid scale sediments - NOT IMPLEMENTED YET
c #undef  USE_SGS_SED

c Determine PAR from shortwave radiation from EXF package
#define USE_EXFQSW

c Use chlorophyll concentration to determine shortwave attenuation 
#define PHYTO_SELF_SHADING

c Allow self-shading to impact ocean heating
#define BLING_HEATING

c Use local atmospheric pressure from EXF package for fugacity factor
#undef USE_EXF_ATMPRES

c Read atmospheric pCO2 values from EXF package
#undef USE_EXFCO2

c For exf undefined cannot use exf fields
#ifndef ALLOW_EXF
#undef USE_EXFCO2
#undef USE_EXF_ATMPRES
c  this one ok. In FFIELDS.h. #undef USE_EXFQSW
#endif

c  apply remineralization from diel vertical migration
#undef USE_BLING_DVM

c Simplify some parts of the code that are problematic 
c when using the adjoint
#undef BLING_ADJOINT_SAFE

c For adjoint safe, do not call bling_dvm
#ifdef BLING_ADJOINT_SAFE
#undef USE_BLING_DVM
c Also do not allow self-shading
#undef BLING_HEATING
#endif

c If bio-optical feedback implemented, require self-shading
#ifndef PHYTO_SELF_SHADING
#undef BLING_HEATING
#endif

#endif /* ALLOW_BLING */
#endif /* BLING_OPTIONS_H */

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
