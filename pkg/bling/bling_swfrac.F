#include "BLING_OPTIONS.h"

CBOP
      subroutine BLING_SWFRAC(
C     U               swfrac_ir, swfrac_rd, swfrac_bg
C     I               bi, bj, imin, imax, jmin, jmax,
     I               myIter, myTime, myThid )

C     =================================================================
C     | subroutine bling_swfrac
C     | o calculate fraction of incoming radiation at each level in each
C     |   band
C     =================================================================

      implicit none

C     === Global variables ===
C     swfrac_ir    ::   Fraction of incoming infrared radiation 
C     swfrac_red   ::   Fraction of incoming red light
C     swfrac_bg    ::   Fraction of incoming blue-green light

#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "FFIELDS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "BLING_VARS.h"
#include "PTRACERS_SIZE.h"
#include "PTRACERS_PARAMS.h"
#ifdef ALLOW_AUTODIFF
# include "tamc.h"
#endif
 
C     === Routine arguments ===
C     bi,bj         :: tile indices
C     iMin,iMax     :: computation domain: 1rst index range
C     jMin,jMax     :: computation domain: 2nd  index range
C     myTime        :: current time
C     myIter        :: current timestep
C     myThid        :: thread Id. number
C      INTEGER bi, bj, imin, imax, jmin, jmax
      INTEGER myThid
      INTEGER myIter
      _RL     myTime
C     === Output ===

      _RL k_ir
      _RL kChl_rd
      _RL kChl_bg
      _RL atten_rd
      _RL atten_bg
      _RL atten_ir 

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO j = 1, sNy
         DO i = 1, sNx
        DO k=1,Nr
         IF (hFacC(i,j,k,bi,bj).gt.0) THEN
c  Attenuation coefficient adjusted to chlorophyll in kth layer
          kChl_rd = k0_rd + chi_rd * (chl(i,j,k,bi,bj)**e_rd)
          kChl_bg = k0_bg + chi_bg * (chl(i,j,k,bi,bj)**e_bg)
c  Light attenuation from one more layer
          atten_ir = k_ir           * drF(k) * hFacC(i,j,k,bi,bj)
          atten_rd = kChl_rd * drF(k) * hFacC(i,j,k,bi,bj)
          atten_bg = kChl_bg * drF(k) * hFacC(i,j,k,bi,bj)
c  Irradiance at bottom of cell
          IF (k.eq.1) THEN
           swfrac_ir(i,j,k,bi,bj) = (1 _d 0  - parfrac) * exp(-atten_ir)
           swfrac_rd(i,j,k,bi,bj) = parfrac * exp(-atten_rd) / 2 _d 0
           swfrac_bg(i,j,k,bi,bj) = parfrac * exp(-atten_bg) / 2 _d 0
          ELSE
           swfrac_ir(i,j,k,bi,bj) = swfrac_ir(i,j,k-1,bi,bj)
     &       * exp(-atten_ir)
           swfrac_rd(i,j,k,bi,bj) = swfrac_rd(i,j,k-1,bi,bj)
     &       * exp(-atten_rd)
           swfrac_bg(i,j,k,bi,bj) = swfrac_bg(i,j,k-1,bi,bj)
     &       * exp(-atten_bg)
          ENDIF
         ENDIF
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      _EXCH_XYZ_RL( swfrac_ir, myThid )
      _EXCH_XYZ_RL( swfrac_rd, myThid )
      _EXCH_XYZ_RL( swfrac_bg, myThid )

      RETURN
      END
