C $Header: /u/gcmpack/MITgcm/pkg/bling/bling_readparms.F,v 1.11 2017/08/09 15:23:39 mlosch Exp $
C $Name:  $

#include "BLING_OPTIONS.h"
#ifdef ALLOW_EXF
# include "EXF_OPTIONS.h"
#endif

CBOP
      SUBROUTINE BLING_READPARMS( myThid )

C     *========================================================*
C     | subroutine bling_readparms
C     | o Initialise and read parameters for BLING model
C     *========================================================*

      implicit none

C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#ifdef ALLOW_EXF
# include "EXF_PARAM.h"
# include "EXF_INTERP_SIZE.h"
C# include "EXF_INTERP_PARAM.h"
#endif /* ALLOW_EXF */
#include "BLING_VARS.h"

C     === Routine arguments ===
C     myThid    :: My Thread Id. number
      INTEGER myThid
CEOP

#ifdef ALLOW_BLING

C     === Local variables ===
C     msgBuf    :: Informational/error message buffer
C     errCount  :: error counter
C     iUnit     :: Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER errCount
      INTEGER iUnit

C ==========================================================
C   Abiotic parameters
C  selectBTconst :: estimates borate concentration from salinity
C     selectBTconst=1 for the default formulation of UppstrÃ¶1974) i.e.
C     the same as S/R CARBON_COEFFS
C     selectBTconst=2 for the new formulation from Lee et al (2010)
C  selectFTconst :: estimates fluoride concentration from salinity
C     selectFTconst=1 for the default formulation of Riley (1965) i.e.
C     the same as S/R CARBON_COEFFS
C     selectFTconst=2 for the new formulation from Culkin (1965)
C  selectHFconst :: sets the first dissociation constant for hydrogen
C  fluoride:
C     selectHFconst=1 for the default  Dickson and Riley (1979) i.e. the
C     same as S/R CARBON_COEFFS
C     selectHFconst=2 for the formulation of Perez and Fraga (1987)
C  selectK1K2const :: sets the first and second dissociation constants
C  of carbonic acid:
C     selectK1K2const=1 for the default formulation of Millero (1995)
C     with data from Mehrbach et al. (1973),
C          i.e. the same as S/R CARBON_COEFFS
C     selectK1K2const=2 for the formulation of Roy et al. (1993)
C     selectK1K2const=3 for the "combination" formulation of Millero
C     (1995)
C     selectK1K2const=4 for the formulation of Luecker et al. (2000)
C     selectK1K2const=5 for the formulation of Millero (2010, Mar. Fresh
C     Wat. Res.)
C     selectK1K2const=6 for the formulation of Waters, Millero, Woosley
C     (2014, Mar. Chem.)
C  selectPHsolver  :: sets the pH solver to use
C     selectPHsolver=0 for Follows et al., (2006)
C     selectPHsolver=1 for Munhoven (2013) solvesaphe general
C     selectPHsolver=2 for Munhoven (2013) solvesaphe sec
C     selectPHsolver=3 for Munhoven (2013) solvesaphe fast
C ==========================================================

      NAMELIST /ABIOTIC_PARMS/
     &                        permil,
     &                        Pa2Atm,
     &                        epsln

C ==========================================================
C   BLING parameters
C ==========================================================

      NAMELIST /BIOTIC_PARMS/
     &                     CtoN,
     &                     CtoP,
     &                     NtoP,
     &                     HtoC,
     &                     NO3toN,
     &                     O2toN,
     &                     O2toP,
     &                     CatoN,
     &                     CatoP,
     &                     masstoN,
#ifndef USE_BLING_V1
     &                     Pc_0_diaz,
     &                     alpha_photo,
     &                     gamma_DON,
     &                     k_Fe_diaz,
     &                     k_NO3,
     &                     k_PtoN,
     &                     k_FetoN,
     &                     PtoN_min,
     &                     PtoN_max,
     &                     FetoN_min,
     &                     FetoN_max,
     &                     kappa_eppley_diaz,
     &                     phi_dvm,
     &                     sigma_dvm,
#ifdef USE_SIBLING
     &                     k_Si,
     &                     gamma_Si_0,
     &                     kappa_remin_Si,
     &                     wsink_Si,
     &                     SitoN_uptake_min,
     &                     SitoN_uptake_max,
     &                     SitoN_uptake_scale,
     &                     SitoN_uptake_exp,
     &                     q_SitoN_diss,
#endif
#else
     &                     alpha_max,
     &                     alpha_min,
     &                     gamma_biomass,
     &                     k_FetoP,
     &                     FetoP_max,
     &                     Fe_lim_min,
#endif
     &                     pivotal,
     &                     Pc_0,
     &                     lambda_0,
     &                     resp_frac,
     &                     chl_min,
     &                     theta_Fe_max_hi,
     &                     theta_Fe_max_lo,
     &                     gamma_irr_mem,
     &                     gamma_DOP,
     &                     gamma_POM,
     &                     k_Fe,
     &                     k_O2,
     &                     k_PO4,
     &                     kFe_eq_lig_max,
     &                     kFe_eq_lig_min,
     &                     kFe_eq_lig_Femin,
     &                     kFe_eq_lig_irr,
     &                     kFe_org,
     &                     kFe_inorg,
     &                     FetoC_sed,
     &                     remin_min,
     &                     oxic_min,
     &                     ligand,
     &                     kappa_eppley,
     &                     kappa_remin,
     &                     ca_remin_depth,
     &                     phi_DOM,
     &                     phi_sm,
     &                     phi_lg,
     &                     wsink0z,
     &                     wsink0,
     &                     wsinkacc,
     &                     parfrac,
     &                     alpfe,
     &                     k0,
     &                     MLmix_max,
     &                     river_conc_po4,
     &                     river_dom_to_nut,
CAT add parameters for self-shading
     &                     k0_rd,
     &                     k0_bg,
     &                     k_ir,
     &                     chi_rd,
     &                     chi_bg,
     &                     e_rd,
     &                     e_bg
C ==========================================================
C   BLING forcing
C ==========================================================

      NAMELIST /BLING_FORCING/
     &          bling_windFile, bling_atmospFile, bling_iceFile,
     &          bling_ironFile, bling_silicaFile,
     &          bling_psmFile, bling_plgFile, bling_PdiazFile,
     &          bling_forcingPeriod, bling_forcingCycle,
     &          bling_Pc_2dFile, bling_Pc_2d_diazFile,
     &          bling_alpha_photo2dFile,bling_phi_DOM2dFile,
     &          bling_k_Fe2dFile, bling_k_Fe_diaz2dFile,
     &          bling_gamma_POM2dFile, bling_wsink0_2dFile,
     &          bling_phi_sm2dFile,bling_phi_lg2dFile,
     &          bling_pCO2,
     &          river_conc_po4, river_dom_to_nut
#ifdef ALLOW_EXF
     &         ,apco2file, apco2startdate1, apco2startdate2,
     &          apco2RepCycle, apco2period, apco2StartTime,
     &          exf_inscal_apco2, exf_outscal_apco2, apco2const,
     &          apco2_exfremo_intercept, apco2_exfremo_slope
#ifdef USE_EXF_INTERPOLATION
     &         ,apco2_lon0, apco2_lon_inc, apco2_lat0, apco2_lat_inc,
     &          apco2_nlon, apco2_nlat, apco2_interpMethod
#endif /* USE_EXF_INTERPOLATION */
#endif

C ==========================================================
C   secperday        :: seconds in a day = 24*60*60
C   permil           :: set carbon mol/m3 <---> mol/kg conversion factor
C                       default permil = 1024.5 kg/m3
C   Pa2Atm           :: Conversion factor for atmospheric pressure pLoad 
C                       (when coupled to atmospheric model) into Atm.  
C                       Default assumes pLoad in Pascal
C                       1 Atm = 1.01325e5 Pa = 1013.25 mb
C   epsln            :: A very small number
C   CtoN             :: Carbon to nitrogen ratio in organic matter
C   CtoP             :: Carbon to phosphorus ratio in organic matter
C   NtoP             :: Nitrogen to phosphorus ratio in organic matter
C   HtoC             :: Reduced hydrogen to carbon ratio in organic
C                       matter
C   NO3toN           :: Nitrate to organic nitrogen ratio for
C                       denitrification
C   O2toN            :: Oxygen to nitrogen for biological activity
C   O2toP            :: Oxygen to phosphorus for biological activity
C   CatoN            :: Calcium to nitrogen uptake by small phyto
C   CatoP            :: Calcium to phosphorus uptake by small phyto
C   masstoN          :: Organic matter mass to nitrogen ratio
C   pivotal          :: Pivotal phytoplankton biomass, for grazing law
C                       [mol P m-3  or  mol N m-3]
C   Pc_0             :: Maximum phytoplankton carbon-specific growth
C                       rate at 0C
C   Pc_0_diaz        :: Maximum diazotroph carbon-specific growth rate
C                       at 0C
C   lambda_0         :: Total mortality rate constant
C   resp_frac        :: Fraction of production that is respired
C   chl_min          :: Minimum chl concentration allowed (for numerical
C   stability)
C   alpha_photo      :: Quantum yield under low light, Fe-replete
C                       [g C g Chl-1 m2 W-1 s-1]
C   alpha_max        :: Quantum yield under low light, abundant iron
C   alpha_min        :: Quantum yield under low light, iron limited
C   theta_Fe_max_hi  :: Maximum Chl:C ratio when iron-replete
C   theta_Fe_max_lo  :: Maximum Chl:C ratio when iron-limited
C   gamma_irr_mem    :: Photoadaptation timescale
C   gamma_DON        :: Dissolved organic nitrogen decay timescale
C   gamma_DOP        :: Dissolved organic phosphorus decay timescale
C   gamma_POM        :: Particulate Organic Matter decay timescale
C   gamma_biomass    :: Biomass adjustment time scale
C   gamma_Si_0       :: Opal dissolution timescale
C   k_Fe             :: Iron half-saturation concentration
C   k_Fe_diaz        :: Iron half-saturation concentration for
C                       diazotrophs
C   k_O2             :: Oxygen half-saturation concentration for aerobic
C                       respiration
C   k_PO4            :: Phosphate half-saturation concentration
C   k_NO3            :: Nitrate half-saturation concentration
C   k_Si             :: Silicate half-saturation concentration
C   k_PtoN           :: Phosphate half-saturation concentration for
C                       uptake ratio
C   k_FetoN          :: Iron half-saturation concentration for uptake
C                       ratio
C   k_FetoP          :: Iron half-saturation concentration for uptake
C                       ratio
C   kFe_eq_lig_max   :: Maximum light-dependent iron ligand stability
C                       constant
C   kFe_eq_lig_min   :: Minimum light-dependent iron ligand stability
C                       constant
C   kFe_eq_lig_Femin :: Low-iron threshold for ligand stability constant
C   kFe_eq_lig_irr   :: Irradiance scaling for iron ligand stability
C                       constant
C   kFe_org          :: Iron scavenging, 1st order
C   kFe_inorg        :: Iron scavenging, 2nd order
C   PtoN_max         :: Phosphorus to Nitrogen uptake ratio maximum
C   PtoN_min         :: Phosphorus to Nitrogen uptake ratio minimum
C   FetoN_max        :: Iron to Nitrogen uptake ratio maximum
C   FetoN_min        :: Iron to Nitrogen uptake ratio minimum
C   FetoC_sed        :: Iron released per organic carbon delivery to
C                       sediments
C   FetoP_max        :: Iron to Phosphorus uptake ratio maximum
C   Fe_lim_min       :: Minimum iron limitation
C   SitoN_uptake_max :: Silica to Nitrogen uptake ratio maximum
C   SitoN_uptake_min :: Silica to Nitrogen uptake ratio minimum
C   SitoN_uptake_scale:: Scale factor for Silica to Nitrogen uptake
C                        ratio
C   SitoN_uptake_exp :: Exponent for Silica to Nitrogen uptake ratio
C   remin_min        :: Minimum remineralization under anoxia
C   oxic_min         :: Anaerobic respiration threshold
C   ligand           :: Iron ligand concentration
C   kappa_eppley     :: Temperature dependence of growth
C   kappa_eppley_diaz:: Temperature dependence of growth for diazotrophs
C   kappa_remin      :: Temperature dependence for particle
C                       fractionation
C   kappa_remin_Si   :: Temperature dependence for silica
C   ca_remin_depth   :: CaCO3 dissolution length scale (subject to
C                       omega)
C   q_SitoN_diss     :: Stoichiometric role in opal dissolution,
C                       following TOPAZ
C   phi_DOM          :: Fraction of uptake/consumption that becomes DOM
C   phi_sm           :: Fraction of small phytoplankton biomass
C                       converted to detritus
C   phi_lg           :: Fraction of large phytoplankton biomass
C                       converted to detritus
C   phi_dvm          :: Fraction of particate production exported by
C                       animals
C   sigma_dvm        :: Standard deviation of vertical migrator resting
C                       depth range
C   wsink0           :: Sinking rate at surface
C   wsink0z          :: Depth to which sinking rate remains constant
C   wsinkacc         :: Sinking rate acceleration with depth
C   wsink_si         :: Opal sinking velocity
C   parfrac          :: Fraction of Qsw available for photosynthesis
C   alpfe            :: Solubility of aeolian iron
C   k0               :: Light attentuation coefficient
C   MLmix_max        :: Maximum depth over which light and biomass can
C                       be mixed
C   river_conc_po4   :: Phosphate concentration in river runoff
C   river_dom_to_nut :: DOM to PO4 ratio in river runoff
C   -------------------------------------------------------------
C   k0_rd             :: attenuation coefficient for red light, without
C                       chlorophyll
C   k0_bg             :: attenuation coefficient for blue-green light,
C                       without chlorophyll
C   k_ir             :: attenuation coefficient for infrared
C   chi_rd           :: chlorophyll weighting coefficient for red light
C                       attenuation
C   chi_bg           :: chlorophyll weighting coefficient for blue-green light
C                       attenuation
C   e_rd             :: chlorophyll exponent for red light attenuation
C   e_bg             :: chlorophyll exponent for blue-green light
C                       attenuation
      _RL secperday
      integer k
#ifdef USE_EXF_INTERPOLATION
      INTEGER gridNx, gridNy
      INTEGER j
      _RL inp_lon0, inp_lat0, inp_dLon, inp_dLat
#endif

      _BEGIN_MASTER(myThid)
      errCount = 0

C ==========================================================
C     Default values

      secperday            = 86400. _d 0
      permil               = 1. _d 0 / 1024.5 _d 0
      Pa2Atm               = 1.01325 _d 5
      epsln                = 1. _d -30
#ifdef CARBONCHEM_SOLVESAPHE
       selectBTconst   = 1
       selectFTconst   = 1
       selectHFconst   = 1
       selectK1K2const = 1
       selectPHsolver  = 0
#endif

      CtoN                 = 6.75 _d 0
      CtoP                 = 106. _d 0
      NtoP                 = 16. _d 0
      HtoC                 = 48. _d 0 / 106. _d 0
      NO3toN               = CtoN * (1. _d 0 + 0.25 _d 0 * HtoC)
     &                        * 0.8 _d 0 + 0.6 _d 0
      O2toN                = CtoN * (1. _d 0 + 0.25 _d 0 * HtoC)
     &                        + 2. _d 0
      O2toP                = 150. _d 0
      CatoN                = CtoN * 0.015 _d 0
      CatoP                = 106.0 _d 0 * 0.015 _d 0
      masstoN              = CtoN * 12.001 _d 0
#ifndef USE_BLING_V1
      pivotal              = 1.9 _d -3 / 1028. _d 0 / CtoN / permil
      Pc_0                 = 1.7 _d -5
      Pc_0_diaz            = 0.01 _d -5
      alpha_photo          = 0.7 _d -5 * 2.77 _d 18 / 6.022 _d 17
      gamma_DON            = 0.25 _d 0 / (365.25 _d 0 * secperday)
      gamma_DOP            = 0.5 _d 0 / (365.25 _d 0 * secperday)
      PtoN_min             = 1. / 28.
      PtoN_max             = 1. / 9.
      FetoN_min            = 2. _d -6 * 6.75
      FetoN_max            = 25. _d -6 * 6.75
      k_Fe                 = 1.6 _d -10 / permil
      k_Fe_diaz            = 7. _d -10 / permil
      k_NO3                = 2. _d -6 / permil
      k_PO4                = 1. _d -8 / permil
      k_PtoN               = 1.5 _d -6 / permil
      k_FetoN              = 8. _d -10 / permil
      remin_min            = 0.15 _d 0
      kappa_eppley_diaz    = 0.18 _d 0
      sigma_dvm            = 40.0 _d 0
      phi_dvm              = 0.2 _d 0
#ifdef USE_SIBLING
      k_Si                 = 2.0 _d -6 / permil
      gamma_Si_0           = 0.05 / secperday
      kappa_remin_Si       = 0.075
      wsink_Si             = 100. / secperday
      SitoN_uptake_min     = 4
      SitoN_uptake_max     = 1
      SitoN_uptake_scale   = 0.6
      SitoN_uptake_exp     = 3.887
      q_SitoN_diss         = 1.0 _d 0
#endif
#else
      pivotal              = 1.9 _d -3 / 1028. _d 0 / CtoP / permil
      Pc_0                 = 1 _d -5
      alpha_max            = 1.6 _d -5 * 2.77 _d 18 / 6.022 _d 17
      alpha_min            = 0.4 _d -5 * 2.77 _d 18 / 6.022 _d 17
      gamma_biomass        = 0.5 _d 0 / secperday
      gamma_DOP            = 0.25 _d 0 / (365.25 _d 0 * secperday)
      k_Fe                 = 8. _d -10 / permil
      k_PO4                = 1. _d -7 / permil
      k_FetoP              = 7. _d -6 * CtoP
      FetoP_max            = 28. _d -6 * CtoP
      Fe_lim_min           = 0. _d 0
      remin_min            = 0.3 _d 0
#endif
      lambda_0             = 0.19 _d 0 / secperday
      resp_frac            = 0. _d 0
      chl_min              = 1. _d -5
      theta_Fe_max_hi      = 0.04 _d 0
      theta_Fe_max_lo      = 0.01 _d 0
      gamma_irr_mem        = 1. _d 0 / secperday
      gamma_POM            = 0.12 _d 0 / secperday
      k_O2                 = 20. _d -6 / permil
      kFe_eq_lig_max       = 8.0 _d 10 * permil
      kFe_eq_lig_min       = 8.0 _d 9 * permil
      kFe_eq_lig_Femin     = 0.05 _d -9 / permil
      kFe_eq_lig_irr       = 0.1 _d 0
      kFe_org              = 0.5 _d 0 / secperday * permil**(0.58)
      kFe_inorg            = 1. _d 3 / secperday * permil**(0.5)
      FetoC_sed            = 1. _d -4
      oxic_min             = 1. _d -6 / permil
      Ligand               = 1. _d -9 / permil
      kappa_eppley         = 0.063 _d 0
      kappa_remin          = -0.032 _d 0
      ca_remin_depth       = 1343. _d 0
      phi_DOM              = 0.1 _d 0
      phi_sm               = 0.18 _d 0
      phi_lg               = 1. _d 0
      wsink0               = 16. _d 0 / secperday
      wsink0z              = 80. _d 0
      wsinkacc             = 0.05 _d 0 / secperday
      parfrac              = 0.40 _d 0
      alpfe                = 0.01 _d 0
      k0                   = 0.04 _d 0
      MLmix_max            = 200.0 _d 0

CAT Set self-shading parameters
      k0_rd                = 0.225 _d 0 
      k0_bg                = 2.32  _d -2
      k_ir                 = 1.0 _d 0 / 0.6 _d 0
C      k_ir                 = 2.86 _d 0
C      chi_rd               = 3.7 _d -2
C      chi_bg               = 7.4 _d -2
      chi_rd               = 0 _d 0 
      chi_bg               = 0 _d 0   
      e_rd                 = 6.29 _d -1
      e_bg                 = 6.74 _d -1

      bling_windFile  = ' '
      bling_atmospFile= ' '
      bling_iceFile   = ' '
      bling_ironFile  = ' '
      bling_silicaFile= ' '
      bling_psmFile   = ' '
      bling_plgFile   = ' '
      bling_pdiazFile = ' '
      bling_Pc_2dFile        = ' '
      bling_Pc_2d_diazFile   = ' '
      bling_alpha_photo2dFile= ' '
      bling_k_Fe2dFile       = ' '
      bling_k_Fe_diaz2dFile  = ' '
      bling_gamma_POM2dFile  = ' '
      bling_wsink0_2dFile    = ' '
      bling_phi_DOM2dFile    = ' '
      bling_phi_sm2dFile     = ' '
      bling_phi_lg2dFile     = ' '

      bling_pCO2             = 278. _d -6
      river_conc_po4         = 0.007 _d 0
      river_dom_to_nut       = 0. _d 0

#ifdef ALLOW_EXF
      apco2startdate1   = 0
      apco2startdate2   = 0
      apco2StartTime    = UNSET_RL
      apco2period       = 0.0 _d 0
      apco2RepCycle     = repeatPeriod
      apco2const        = 0.0 _d 0
      apco2_exfremo_intercept = 0.0 _d 0
      apco2_exfremo_slope = 0.0 _d 0
      apco2file         = ' '
      exf_inscal_apco2  =  1. _d 0
      exf_outscal_apco2 =  1. _d 0
#ifdef USE_EXF_INTERPOLATION
C--   set default input location to match (in case of simple Lat-Long grid)
C     model grid cell-center position (leading to trivial interpolation)
      inp_lon0 = xgOrigin + delX(1)*exf_half
      inp_lat0 = ygOrigin + delY(1)*exf_half
      inp_dLon = delX(1)
      inp_dLat = delY(1)
      apco2_lon0     = inp_lon0
      apco2_lat0     = inp_lat0
      apco2_nlon     = gridNx
      apco2_nlat     = gridNy
      apco2_lon_inc  = inp_dLon
      DO j=1,MAX_LAT_INC
        IF (j.LT.gridNy) THEN
          inp_dLat = (delY(j) + delY(j+1))*exf_half
        ELSE
          inp_dLat = 0.
        ENDIF
        apco2_lat_inc(j) = inp_dLat
      ENDDO
#endif /* USE_EXF_INTERPOLATION */
#endif /* ALLOW_EXF */

C     default periodic forcing to same as for physics
       bling_forcingPeriod = externForcingPeriod
       bling_forcingCycle  = externForcingCycle

      WRITE(msgBuf,'(A)') ' BLING_READPARMS: opening data.bling'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     I                    SQUEEZE_RIGHT, myThid )

      CALL OPEN_COPY_DATA_FILE( 'data.bling', 'BLING_READPARMS',
     O                          iUnit, myThid )

C--   Read parameters from open data file:

C-    Abiotic parameters
      READ(UNIT=iUnit,NML=ABIOTIC_PARMS)

C-    BLING parameters
      READ(UNIT=iUnit,NML=BIOTIC_PARMS)

C-    forcing filenames and parameters
      READ(UNIT=iUnit,NML=BLING_FORCING)

      WRITE(msgBuf,'(A)')
     &   ' BLING_READPARMS: finished reading data.BLING'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     I                    SQUEEZE_RIGHT, myThid )

C--   Close the open data file
#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

      IF ( errCount.GE.1 ) THEN
       WRITE(msgBuf,'(A,I3,A)')
     &     'BLING_READPARMS: detected', errCount,' fatal error(s)'
       CALL PRINT_ERROR( msgBuf, myThid )
       CALL ALL_PROC_DIE( 0 )
       STOP 'ABNORMAL END: S/R BLING_READPARMS'
      ENDIF

      _END_MASTER(myThid)

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_BLING */

      RETURN
      END
