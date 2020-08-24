C $Header: /u/gcmpack/MITgcm/pkg/bling/BLING_OPTIONS.h,v 1.6 2017/03/16 17:03:26 mmazloff Exp $
C $Name:  $

#ifndef BLING_OPTIONS_H
#define BLING_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_BLING
C     Package-specific Options & Macros go here

C BLING+Nitrogen is the default model. It's a version
C of BLING with 8 tracers and 3 phyto classes.
C For the original 6-tracer model of Galbraith et al (2010),
C define USE_BLING_V1 - but note the different order of tracers in data.ptracers
#undef USE_BLING_V1

C Options for BLING+Nitrogen code:
C SiBLING: add a 9th tracer for silica
#undef USE_SIBLING
C apply remineralization from diel vertical migration
#undef USE_BLING_DVM
C active tracer for total phytoplankton biomass
#undef ADVECT_PHYTO
C sub grid scale sediments - NOT IMPLEMENTED YET
c #undef USE_SGS_SED

C Prevents negative values in nutrient fields
#define BLING_NO_NEG

C Use Liebig function instead of geometric mean of the
C nutrient limitations to calculate maximum phyto growth rate
#define MIN_NUT_LIM

C Allow different phytoplankton groups to have different growth rates and
C nutrient/light limitations. Parameters implemented have yet to be tuned.
#undef SIZE_NUT_LIM

C Assume that phytoplankton in the mixed layer experience
C the average light over the mixed layer (as in original BLING model)
#undef ML_MEAN_LIGHT

C Assume that phytoplankton are homogenized in the mixed layer
#define ML_MEAN_PHYTO

C Calculate MLD using a threshold criterion. If undefined,
C MLD is calculated using the second derivative of rho(z)
#undef BLING_USE_THRESHOLD_MLD

C Determine PAR from shortwave radiation Qsw;
C otherwise determined from date and latitude
#define USE_QSW

C Light absorption scheme from Manizza et al. (2005),
C with self shading from phytoplankton
#undef PHYTO_SELF_SHADING

C Note: atm pressure from PKG/EXF is always used for air-sea flux calculation
C if available; otherwise read from file or set to constant value (1 atm)

C Note: winds from PKG/EXF are always used if available;
C otherwise read from file or set to constant value (5 m/s)

C Note: ice fraction from PKG/SEAICE or THSICE is always used if available;
C otherwise read from file or set to constant value (0)

C Note: atm pCO2 from EXF file is always used if available;
C otherwise set to constant value in data.bling

C Simplify some parts of the code that are problematic when using the adjoint
#define BLING_ADJOINT_SAFE

c Allow self-shading to impact ocean heating
#undef BLING_HEATING

C For adjoint safe, do not call bling_dvm
#ifdef BLING_ADJOINT_SAFE
#undef USE_BLING_DVM
c Also do not allow biophysical feedback
#undef BLING_HEATING
#endif

c If bio-optical feedback implemented, require self-shading
#ifndef PHYTO_SELF_SHADING
#undef BLING_HEATING

C When calculating the fraction of sinking organic matter, use model biomass diagnostics.
#define NEW_FRAC_EXP

C Assume different nutrient limitations for small and large phytoplankton.
#define SIZE_DEP_LIM

#endif /* ALLOW_BLING */
#endif /* BLING_OPTIONS_H */

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
