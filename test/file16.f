C     **********
C
C     THIS PROGRAM TESTS CODES FOR THE SOLUTION OF N NONLINEAR
C     EQUATIONS IN N VARIABLES. IT CONSISTS OF A DRIVER AND AN
C     INTERFACE SUBROUTINE FCN. THE DRIVER READS IN DATA, CALLS THE
C     NONLINEAR EQUATION SOLVER, AND FINALLY PRINTS OUT INFORMATION
C     ON THE PERFORMANCE OF THE SOLVER. THIS IS ONLY A SAMPLE DRIVER,
C     MANY OTHER DRIVERS ARE POSSIBLE. THE INTERFACE SUBROUTINE FCN
C     IS NECESSARY TO TAKE INTO ACCOUNT THE FORMS OF CALLING
C     SEQUENCES USED BY THE FUNCTION AND JACOBIAN SUBROUTINES IN
C     THE VARIOUS NONLINEAR EQUATION SOLVERS.
C
C     SUBPROGRAMS CALLED
C
C       USER-SUPPLIED ...... FCN
C
C       MINPACK-SUPPLIED ... DPMPAR,ENORM,HYBRJ1,INITPT,VECFCN
C
C       FORTRAN-SUPPLIED ... DSQRT
C
C     ARGONNE NATIONAL LABORATORY. MINPACK PROJECT. MARCH 1980.
C     BURTON S. GARBOW, KENNETH E. HILLSTROM, JORGE J. MORE
C
C     **********
      INTEGER I,IC,INFO,K,LDFJAC,LWA,N,NFEV,NJEV,NPROB,NREAD,NTRIES,
     1        NWRITE
      INTEGER NA(60),NF(60),NJ(60),NP(60),NX(60)
      DOUBLE PRECISION FACTOR,FNORM1,FNORM2,ONE,TEN,TOL
      DOUBLE PRECISION FNM(60),FJAC(40,40),FVEC(40),WA(1060),X(40)
      DOUBLE PRECISION DPMPAR,ENORM
      EXTERNAL FCN
      COMMON /REFNUM/ NPROB,NFEV,NJEV
C
C     LOGICAL INPUT UNIT IS ASSUMED TO BE NUMBER 5.
C     LOGICAL OUTPUT UNIT IS ASSUMED TO BE NUMBER 6.
C
      DATA NREAD,NWRITE /5,6/
C
      DATA ONE,TEN /1.0D0,1.0D1/
      TOL = DSQRT(DPMPAR(1))
      LDFJAC = 40
      LWA = 1060
      IC = 0
   10 CONTINUE
         READ (NREAD,50) NPROB,N,NTRIES
         IF (NPROB .LE. 0) GO TO 30
         FACTOR = ONE
         DO 20 K = 1, NTRIES
            IC = IC + 1
            CALL INITPT(N,X,NPROB,FACTOR)
            CALL VECFCN(N,X,FVEC,NPROB)
            FNORM1 = ENORM(N,FVEC)
            WRITE (NWRITE,60) NPROB,N
            NFEV = 0
            NJEV = 0
            CALL HYBRJ1(FCN,N,X,FVEC,FJAC,LDFJAC,TOL,INFO,WA,LWA)
            FNORM2 = ENORM(N,FVEC)
            NP(IC) = NPROB
            NA(IC) = N
            NF(IC) = NFEV
            NJ(IC) = NJEV
            NX(IC) = INFO
            FNM(IC) = FNORM2
            WRITE (NWRITE,70)
     1            FNORM1,FNORM2,NFEV,NJEV,INFO,(X(I), I = 1, N)
            FACTOR = TEN*FACTOR
   20       CONTINUE
         GO TO 10
   30 CONTINUE
      WRITE (NWRITE,80) IC
      WRITE (NWRITE,90)
      DO 40 I = 1, IC
         WRITE (NWRITE,100) NP(I),NA(I),NF(I),NJ(I),NX(I),FNM(I)
   40    CONTINUE
      STOP
   50 FORMAT (3I5)
   60 FORMAT ( //// 5X, 8H PROBLEM, I5, 5X, 10H DIMENSION, I5, 5X //)
   70 FORMAT (5X, 33H INITIAL L2 NORM OF THE RESIDUALS, D15.7 // 5X,
     1        33H FINAL L2 NORM OF THE RESIDUALS  , D15.7 // 5X,
     2        33H NUMBER OF FUNCTION EVALUATIONS  , I10 // 5X,
     3        33H NUMBER OF JACOBIAN EVALUATIONS  , I10 // 5X,
     4        15H EXIT PARAMETER, 18X, I10 // 5X,
     5        27H FINAL APPROXIMATE SOLUTION // (5X, 5D15.7))
   80 FORMAT (12H1SUMMARY OF , I3, 16H CALLS TO HYBRJ1 /)
   90 FORMAT (46H NPROB   N    NFEV   NJEV  INFO  FINAL L2 NORM /)
  100 FORMAT (I4, I6, 2I7, I6, 1X, D15.7)
C
C     LAST CARD OF DRIVER.
C
      END
      SUBROUTINE FCN(N,X,FVEC,FJAC,LDFJAC,IFLAG)
      INTEGER N,LDFJAC,IFLAG
      DOUBLE PRECISION X(N),FVEC(N),FJAC(LDFJAC,N)
C     **********
C
C     THE CALLING SEQUENCE OF FCN SHOULD BE IDENTICAL TO THE
C     CALLING SEQUENCE OF THE FUNCTION SUBROUTINE IN THE NONLINEAR
C     EQUATION SOLVER. FCN SHOULD ONLY CALL THE TESTING FUNCTION
C     AND JACOBIAN SUBROUTINES VECFCN AND VECJAC WITH THE
C     APPROPRIATE VALUE OF PROBLEM NUMBER (NPROB).
C
C     SUBPROGRAMS CALLED
C
C       MINPACK-SUPPLIED ... VECFCN,VECJAC
C
C     ARGONNE NATIONAL LABORATORY. MINPACK PROJECT. MARCH 1980.
C     BURTON S. GARBOW, KENNETH E. HILLSTROM, JORGE J. MORE
C
C     **********
      INTEGER NPROB,NFEV,NJEV
      COMMON /REFNUM/ NPROB,NFEV,NJEV
      IF (IFLAG .EQ. 1) CALL VECFCN(N,X,FVEC,NPROB)
      IF (IFLAG .EQ. 2) CALL VECJAC(N,X,FJAC,LDFJAC,NPROB)
      IF (IFLAG .EQ. 1) NFEV = NFEV + 1
      IF (IFLAG .EQ. 2) NJEV = NJEV + 1
      RETURN
C
C     LAST CARD OF INTERFACE SUBROUTINE FCN.
C
      END
      SUBROUTINE VECJAC(N,X,FJAC,LDFJAC,NPROB)
      INTEGER N,LDFJAC,NPROB
      DOUBLE PRECISION X(N),FJAC(LDFJAC,N)
C     **********
C
C     SUBROUTINE VECJAC
C
C     THIS SUBROUTINE DEFINES THE JACOBIAN MATRICES OF FOURTEEN
C     TEST FUNCTIONS. THE PROBLEM DIMENSIONS ARE AS DESCRIBED
C     IN THE PROLOGUE COMMENTS OF VECFCN.
C
C     THE SUBROUTINE STATEMENT IS
C
C       SUBROUTINE VECJAC(N,X,FJAC,LDFJAC,NPROB)
C
C     WHERE
C
C       N IS A POSITIVE INTEGER VARIABLE.
C
C       X IS AN ARRAY OF LENGTH N.
C
C       FJAC IS AN N BY N ARRAY. ON OUTPUT FJAC CONTAINS THE
C         JACOBIAN MATRIX OF THE NPROB FUNCTION EVALUATED AT X.
C
C       LDFJAC IS A POSITIVE INTEGER VARIABLE NOT LESS THAN N
C         WHICH SPECIFIES THE LEADING DIMENSION OF THE ARRAY FJAC.
C
C       NPROB IS A POSITIVE INTEGER VARIABLE WHICH DEFINES THE
C         NUMBER OF THE PROBLEM. NPROB MUST NOT EXCEED 14.
C
C     SUBPROGRAMS CALLED
C
C       FORTRAN-SUPPLIED ... DATAN,DCOS,DEXP,DMIN1,DSIN,DSQRT,
C                            MAX0,MIN0
C
C     ARGONNE NATIONAL LABORATORY. MINPACK PROJECT. MARCH 1980.
C     BURTON S. GARBOW, KENNETH E. HILLSTROM, JORGE J. MORE
C
C     **********
      INTEGER I,IVAR,J,K,K1,K2,ML,MU
      DOUBLE PRECISION C1,C3,C4,C5,C6,C9,EIGHT,FIFTN,FIVE,FOUR,H,
     *                 HUNDRD,ONE,PROD,SIX,SUM,SUM1,SUM2,TEMP,TEMP1,
     *                 TEMP2,TEMP3,TEMP4,TEN,THREE,TI,TJ,TK,TPI,
     *                 TWENTY,TWO,ZERO
      DOUBLE PRECISION DFLOAT
      DATA ZERO,ONE,TWO,THREE,FOUR,FIVE,SIX,EIGHT,TEN,FIFTN,TWENTY,
     *     HUNDRD
     *     /0.0D0,1.0D0,2.0D0,3.0D0,4.0D0,5.0D0,6.0D0,8.0D0,1.0D1,
     *      1.5D1,2.0D1,1.0D2/
      DATA C1,C3,C4,C5,C6,C9 /1.0D4,2.0D2,2.02D1,1.98D1,1.8D2,2.9D1/
      DFLOAT(IVAR) = IVAR
C
C     JACOBIAN ROUTINE SELECTOR.
C
      GO TO (10,20,50,60,90,100,200,230,290,320,350,380,420,450),
     *      NPROB
C
C     ROSENBROCK FUNCTION.
C
   10 CONTINUE
      FJAC(1,1) = -ONE
      FJAC(1,2) = ZERO
      FJAC(2,1) = -TWENTY*X(1)
      FJAC(2,2) = TEN
      GO TO 490
C
C     POWELL SINGULAR FUNCTION.
C
   20 CONTINUE
      DO 40 K = 1, 4
         DO 30 J = 1, 4
            FJAC(K,J) = ZERO
   30       CONTINUE
   40    CONTINUE
      FJAC(1,1) = ONE
      FJAC(1,2) = TEN
      FJAC(2,3) = DSQRT(FIVE)
      FJAC(2,4) = -FJAC(2,3)
      FJAC(3,2) = TWO*(X(2) - TWO*X(3))
      FJAC(3,3) = -TWO*FJAC(3,2)
      FJAC(4,1) = TWO*DSQRT(TEN)*(X(1) - X(4))
      FJAC(4,4) = -FJAC(4,1)
      GO TO 490
C
C     POWELL BADLY SCALED FUNCTION.
C
   50 CONTINUE
      FJAC(1,1) = C1*X(2)
      FJAC(1,2) = C1*X(1)
      FJAC(2,1) = -DEXP(-X(1))
      FJAC(2,2) = -DEXP(-X(2))
      GO TO 490
C
C     WOOD FUNCTION.
C
   60 CONTINUE
      DO 80 K = 1, 4
         DO 70 J = 1, 4
            FJAC(K,J) = ZERO
   70       CONTINUE
   80    CONTINUE
      TEMP1 = X(2) - THREE*X(1)**2
      TEMP2 = X(4) - THREE*X(3)**2
      FJAC(1,1) = -C3*TEMP1 + ONE
      FJAC(1,2) = -C3*X(1)
      FJAC(2,1) = -TWO*C3*X(1)
      FJAC(2,2) = C3 + C4
      FJAC(2,4) = C5
      FJAC(3,3) = -C6*TEMP2 + ONE
      FJAC(3,4) = -C6*X(3)
      FJAC(4,2) = C5
      FJAC(4,3) = -TWO*C6*X(3)
      FJAC(4,4) = C6 + C4
      GO TO 490
C
C     HELICAL VALLEY FUNCTION.
C
   90 CONTINUE
      TPI = EIGHT*DATAN(ONE)
      TEMP = X(1)**2 + X(2)**2
      TEMP1 = TPI*TEMP
      TEMP2 = DSQRT(TEMP)
      FJAC(1,1) = HUNDRD*X(2)/TEMP1
      FJAC(1,2) = -HUNDRD*X(1)/TEMP1
      FJAC(1,3) = TEN
      FJAC(2,1) = TEN*X(1)/TEMP2
      FJAC(2,2) = TEN*X(2)/TEMP2
      FJAC(2,3) = ZERO
      FJAC(3,1) = ZERO
      FJAC(3,2) = ZERO
      FJAC(3,3) = ONE
      GO TO 490
C
C     WATSON FUNCTION.
C
  100 CONTINUE
      DO 120 K = 1, N
         DO 110 J = K, N
            FJAC(K,J) = ZERO
  110       CONTINUE
  120    CONTINUE
      DO 170 I = 1, 29
         TI = DFLOAT(I)/C9
         SUM1 = ZERO
         TEMP = ONE
         DO 130 J = 2, N
            SUM1 = SUM1 + DFLOAT(J-1)*TEMP*X(J)
            TEMP = TI*TEMP
  130       CONTINUE
         SUM2 = ZERO
         TEMP = ONE
         DO 140 J = 1, N
            SUM2 = SUM2 + TEMP*X(J)
            TEMP = TI*TEMP
  140       CONTINUE
         TEMP1 = TWO*(SUM1 - SUM2**2 - ONE)
         TEMP2 = TWO*SUM2
         TEMP = TI**2
         TK = ONE
         DO 160 K = 1, N
            TJ = TK
            DO 150 J = K, N
               FJAC(K,J) = FJAC(K,J)
     *                     + TJ
     *                       *((DFLOAT(K-1)/TI - TEMP2)
     *                         *(DFLOAT(J-1)/TI - TEMP2) - TEMP1)
               TJ = TI*TJ
  150          CONTINUE
            TK = TEMP*TK
  160       CONTINUE
  170    CONTINUE
      FJAC(1,1) = FJAC(1,1) + SIX*X(1)**2 - TWO*X(2) + THREE
      FJAC(1,2) = FJAC(1,2) - TWO*X(1)
      FJAC(2,2) = FJAC(2,2) + ONE
      DO 190 K = 1, N
         DO 180 J = K, N
            FJAC(J,K) = FJAC(K,J)
  180       CONTINUE
  190    CONTINUE
      GO TO 490
C
C     CHEBYQUAD FUNCTION.
C
  200 CONTINUE
      TK = ONE/DFLOAT(N)
      DO 220 J = 1, N
         TEMP1 = ONE
         TEMP2 = TWO*X(J) - ONE
         TEMP = TWO*TEMP2
         TEMP3 = ZERO
         TEMP4 = TWO
         DO 210 K = 1, N
            FJAC(K,J) = TK*TEMP4
            TI = FOUR*TEMP2 + TEMP*TEMP4 - TEMP3
            TEMP3 = TEMP4
            TEMP4 = TI
            TI = TEMP*TEMP2 - TEMP1
            TEMP1 = TEMP2
            TEMP2 = TI
  210       CONTINUE
  220    CONTINUE
      GO TO 490
C
C     BROWN ALMOST-LINEAR FUNCTION.
C
  230 CONTINUE
      PROD = ONE
      DO 250 J = 1, N
         PROD = X(J)*PROD
         DO 240 K = 1, N
            FJAC(K,J) = ONE
  240       CONTINUE
         FJAC(J,J) = TWO
  250    CONTINUE
      DO 280 J = 1, N
         TEMP = X(J)
         IF (TEMP .NE. ZERO) GO TO 270
         TEMP = ONE
         PROD = ONE
         DO 260 K = 1, N
            IF (K .NE. J) PROD = X(K)*PROD
  260       CONTINUE
  270    CONTINUE
         FJAC(N,J) = PROD/TEMP
  280    CONTINUE
      GO TO 490
C
C     DISCRETE BOUNDARY VALUE FUNCTION.
C
  290 CONTINUE
      H = ONE/DFLOAT(N+1)
      DO 310 K = 1, N
         TEMP = THREE*(X(K) + DFLOAT(K)*H + ONE)**2
         DO 300 J = 1, N
            FJAC(K,J) = ZERO
  300       CONTINUE
         FJAC(K,K) = TWO + TEMP*H**2/TWO
         IF (K .NE. 1) FJAC(K,K-1) = -ONE
         IF (K .NE. N) FJAC(K,K+1) = -ONE
  310    CONTINUE
      GO TO 490
C
C     DISCRETE INTEGRAL EQUATION FUNCTION.
C
  320 CONTINUE
      H = ONE/DFLOAT(N+1)
      DO 340 K = 1, N
         TK = DFLOAT(K)*H
         DO 330 J = 1, N
            TJ = DFLOAT(J)*H
            TEMP = THREE*(X(J) + TJ + ONE)**2
            FJAC(K,J) = H*DMIN1(TJ*(ONE-TK),TK*(ONE-TJ))*TEMP/TWO
  330       CONTINUE
         FJAC(K,K) = FJAC(K,K) + ONE
  340    CONTINUE
      GO TO 490
C
C     TRIGONOMETRIC FUNCTION.
C
  350 CONTINUE
      DO 370 J = 1, N
         TEMP = DSIN(X(J))
         DO 360 K = 1, N
            FJAC(K,J) = TEMP
  360       CONTINUE
         FJAC(J,J) = DFLOAT(J+1)*TEMP - DCOS(X(J))
  370    CONTINUE
      GO TO 490
C
C     VARIABLY DIMENSIONED FUNCTION.
C
  380 CONTINUE
      SUM = ZERO
      DO 390 J = 1, N
         SUM = SUM + DFLOAT(J)*(X(J) - ONE)
  390    CONTINUE
      TEMP = ONE + SIX*SUM**2
      DO 410 K = 1, N
         DO 400 J = K, N
            FJAC(K,J) = DFLOAT(K*J)*TEMP
            FJAC(J,K) = FJAC(K,J)
  400       CONTINUE
         FJAC(K,K) = FJAC(K,K) + ONE
  410    CONTINUE
      GO TO 490
C
C     BROYDEN TRIDIAGONAL FUNCTION.
C
  420 CONTINUE
      DO 440 K = 1, N
         DO 430 J = 1, N
            FJAC(K,J) = ZERO
  430       CONTINUE
         FJAC(K,K) = THREE - FOUR*X(K)
         IF (K .NE. 1) FJAC(K,K-1) = -ONE
         IF (K .NE. N) FJAC(K,K+1) = -TWO
  440    CONTINUE
      GO TO 490
C
C     BROYDEN BANDED FUNCTION.
C
  450 CONTINUE
      ML = 5
      MU = 1
      DO 480 K = 1, N
         DO 460 J = 1, N
            FJAC(K,J) = ZERO
  460       CONTINUE
         K1 = MAX0(1,K-ML)
         K2 = MIN0(K+MU,N)
         DO 470 J = K1, K2
            IF (J .NE. K) FJAC(K,J) = -(ONE + TWO*X(J))
  470       CONTINUE
         FJAC(K,K) = TWO + FIFTN*X(K)**2
  480    CONTINUE
  490 CONTINUE
      RETURN
C
C     LAST CARD OF SUBROUTINE VECJAC.
C
      END
      SUBROUTINE INITPT(N,X,NPROB,FACTOR)
      INTEGER N,NPROB
      DOUBLE PRECISION FACTOR
      DOUBLE PRECISION X(N)
C     **********
C
C     SUBROUTINE INITPT
C
C     THIS SUBROUTINE SPECIFIES THE STANDARD STARTING POINTS FOR
C     THE FUNCTIONS DEFINED BY SUBROUTINE VECFCN. THE SUBROUTINE
C     RETURNS IN X A MULTIPLE (FACTOR) OF THE STANDARD STARTING
C     POINT. FOR THE SIXTH FUNCTION THE STANDARD STARTING POINT IS
C     ZERO, SO IN THIS CASE, IF FACTOR IS NOT UNITY, THEN THE
C     SUBROUTINE RETURNS THE VECTOR  X(J) = FACTOR, J=1,...,N.
C
C     THE SUBROUTINE STATEMENT IS
C
C       SUBROUTINE INITPT(N,X,NPROB,FACTOR)
C
C     WHERE
C
C       N IS A POSITIVE INTEGER INPUT VARIABLE.
C
C       X IS AN OUTPUT ARRAY OF LENGTH N WHICH CONTAINS THE STANDARD
C         STARTING POINT FOR PROBLEM NPROB MULTIPLIED BY FACTOR.
C
C       NPROB IS A POSITIVE INTEGER INPUT VARIABLE WHICH DEFINES THE
C         NUMBER OF THE PROBLEM. NPROB MUST NOT EXCEED 14.
C
C       FACTOR IS AN INPUT VARIABLE WHICH SPECIFIES THE MULTIPLE OF
C         THE STANDARD STARTING POINT. IF FACTOR IS UNITY, NO
C         MULTIPLICATION IS PERFORMED.
C
C     ARGONNE NATIONAL LABORATORY. MINPACK PROJECT. MARCH 1980.
C     BURTON S. GARBOW, KENNETH E. HILLSTROM, JORGE J. MORE
C
C     **********
      INTEGER IVAR,J
      DOUBLE PRECISION C1,H,HALF,ONE,THREE,TJ,ZERO
      DOUBLE PRECISION DFLOAT
      DATA ZERO,HALF,ONE,THREE,C1 /0.0D0,5.0D-1,1.0D0,3.0D0,1.2D0/
      DFLOAT(IVAR) = IVAR
C
C     SELECTION OF INITIAL POINT.
C
      GO TO (10,20,30,40,50,60,80,100,120,120,140,160,180,180), NPROB
C
C     ROSENBROCK FUNCTION.
C
   10 CONTINUE
      X(1) = -C1
      X(2) = ONE
      GO TO 200
C
C     POWELL SINGULAR FUNCTION.
C
   20 CONTINUE
      X(1) = THREE
      X(2) = -ONE
      X(3) = ZERO
      X(4) = ONE
      GO TO 200
C
C     POWELL BADLY SCALED FUNCTION.
C
   30 CONTINUE
      X(1) = ZERO
      X(2) = ONE
      GO TO 200
C
C     WOOD FUNCTION.
C
   40 CONTINUE
      X(1) = -THREE
      X(2) = -ONE
      X(3) = -THREE
      X(4) = -ONE
      GO TO 200
C
C     HELICAL VALLEY FUNCTION.
C
   50 CONTINUE
      X(1) = -ONE
      X(2) = ZERO
      X(3) = ZERO
      GO TO 200
C
C     WATSON FUNCTION.
C
   60 CONTINUE
      DO 70 J = 1, N
         X(J) = ZERO
   70    CONTINUE
      GO TO 200
C
C     CHEBYQUAD FUNCTION.
C
   80 CONTINUE
      H = ONE/DFLOAT(N+1)
      DO 90 J = 1, N
         X(J) = DFLOAT(J)*H
   90    CONTINUE
      GO TO 200
C
C     BROWN ALMOST-LINEAR FUNCTION.
C
  100 CONTINUE
      DO 110 J = 1, N
         X(J) = HALF
  110    CONTINUE
      GO TO 200
C
C     DISCRETE BOUNDARY VALUE AND INTEGRAL EQUATION FUNCTIONS.
C
  120 CONTINUE
      H = ONE/DFLOAT(N+1)
      DO 130 J = 1, N
         TJ = DFLOAT(J)*H
         X(J) = TJ*(TJ - ONE)
  130    CONTINUE
      GO TO 200
C
C     TRIGONOMETRIC FUNCTION.
C
  140 CONTINUE
      H = ONE/DFLOAT(N)
      DO 150 J = 1, N
         X(J) = H
  150    CONTINUE
      GO TO 200
C
C     VARIABLY DIMENSIONED FUNCTION.
C
  160 CONTINUE
      H = ONE/DFLOAT(N)
      DO 170 J = 1, N
         X(J) = ONE - DFLOAT(J)*H
  170    CONTINUE
      GO TO 200
C
C     BROYDEN TRIDIAGONAL AND BANDED FUNCTIONS.
C
  180 CONTINUE
      DO 190 J = 1, N
         X(J) = -ONE
  190    CONTINUE
  200 CONTINUE
C
C     COMPUTE MULTIPLE OF INITIAL POINT.
C
      IF (FACTOR .EQ. ONE) GO TO 250
      IF (NPROB .EQ. 6) GO TO 220
         DO 210 J = 1, N
            X(J) = FACTOR*X(J)
  210       CONTINUE
         GO TO 240
  220 CONTINUE
         DO 230 J = 1, N
            X(J) = FACTOR
  230       CONTINUE
  240 CONTINUE
  250 CONTINUE
      RETURN
C
C     LAST CARD OF SUBROUTINE INITPT.
C
      END
      SUBROUTINE VECFCN(N,X,FVEC,NPROB)
      INTEGER N,NPROB
      DOUBLE PRECISION X(N),FVEC(N)
C     **********
C
C     SUBROUTINE VECFCN
C
C     THIS SUBROUTINE DEFINES FOURTEEN TEST FUNCTIONS. THE FIRST
C     FIVE TEST FUNCTIONS ARE OF DIMENSIONS 2,4,2,4,3, RESPECTIVELY,
C     WHILE THE REMAINING TEST FUNCTIONS ARE OF VARIABLE DIMENSION
C     N FOR ANY N GREATER THAN OR EQUAL TO 1 (PROBLEM 6 IS AN
C     EXCEPTION TO THIS, SINCE IT DOES NOT ALLOW N = 1).
C
C     THE SUBROUTINE STATEMENT IS
C
C       SUBROUTINE VECFCN(N,X,FVEC,NPROB)
C
C     WHERE
C
C       N IS A POSITIVE INTEGER INPUT VARIABLE.
C
C       X IS AN INPUT ARRAY OF LENGTH N.
C
C       FVEC IS AN OUTPUT ARRAY OF LENGTH N WHICH CONTAINS THE NPROB
C         FUNCTION VECTOR EVALUATED AT X.
C
C       NPROB IS A POSITIVE INTEGER INPUT VARIABLE WHICH DEFINES THE
C         NUMBER OF THE PROBLEM. NPROB MUST NOT EXCEED 14.
C
C     SUBPROGRAMS CALLED
C
C       FORTRAN-SUPPLIED ... DATAN,DCOS,DEXP,DSIGN,DSIN,DSQRT,
C                            MAX0,MIN0
C
C     ARGONNE NATIONAL LABORATORY. MINPACK PROJECT. MARCH 1980.
C     BURTON S. GARBOW, KENNETH E. HILLSTROM, JORGE J. MORE
C
C     **********
      INTEGER I,IEV,IVAR,J,K,K1,K2,KP1,ML,MU
      DOUBLE PRECISION C1,C2,C3,C4,C5,C6,C7,C8,C9,EIGHT,FIVE,H,ONE,
     *                 PROD,SUM,SUM1,SUM2,TEMP,TEMP1,TEMP2,TEN,THREE,
     *                 TI,TJ,TK,TPI,TWO,ZERO
      DOUBLE PRECISION DFLOAT
      DATA ZERO,ONE,TWO,THREE,FIVE,EIGHT,TEN
     *     /0.0D0,1.0D0,2.0D0,3.0D0,5.0D0,8.0D0,1.0D1/
      DATA C1,C2,C3,C4,C5,C6,C7,C8,C9
     *     /1.0D4,1.0001D0,2.0D2,2.02D1,1.98D1,1.8D2,2.5D-1,5.0D-1,
     *      2.9D1/
      DFLOAT(IVAR) = IVAR
C
C     PROBLEM SELECTOR.
C
      GO TO (10,20,30,40,50,60,120,170,200,220,270,300,330,350), NPROB
C
C     ROSENBROCK FUNCTION.
C
   10 CONTINUE
      FVEC(1) = ONE - X(1)
      FVEC(2) = TEN*(X(2) - X(1)**2)
      GO TO 380
C
C     POWELL SINGULAR FUNCTION.
C
   20 CONTINUE
      FVEC(1) = X(1) + TEN*X(2)
      FVEC(2) = DSQRT(FIVE)*(X(3) - X(4))
      FVEC(3) = (X(2) - TWO*X(3))**2
      FVEC(4) = DSQRT(TEN)*(X(1) - X(4))**2
      GO TO 380
C
C     POWELL BADLY SCALED FUNCTION.
C
   30 CONTINUE
      FVEC(1) = C1*X(1)*X(2) - ONE
      FVEC(2) = DEXP(-X(1)) + DEXP(-X(2)) - C2
      GO TO 380
C
C     WOOD FUNCTION.
C
   40 CONTINUE
      TEMP1 = X(2) - X(1)**2
      TEMP2 = X(4) - X(3)**2
      FVEC(1) = -C3*X(1)*TEMP1 - (ONE - X(1))
      FVEC(2) = C3*TEMP1 + C4*(X(2) - ONE) + C5*(X(4) - ONE)
      FVEC(3) = -C6*X(3)*TEMP2 - (ONE - X(3))
      FVEC(4) = C6*TEMP2 + C4*(X(4) - ONE) + C5*(X(2) - ONE)
      GO TO 380
C
C     HELICAL VALLEY FUNCTION.
C
   50 CONTINUE
      TPI = EIGHT*DATAN(ONE)
      TEMP1 = DSIGN(C7,X(2))
      IF (X(1) .GT. ZERO) TEMP1 = DATAN(X(2)/X(1))/TPI
      IF (X(1) .LT. ZERO) TEMP1 = DATAN(X(2)/X(1))/TPI + C8
      TEMP2 = DSQRT(X(1)**2+X(2)**2)
      FVEC(1) = TEN*(X(3) - TEN*TEMP1)
      FVEC(2) = TEN*(TEMP2 - ONE)
      FVEC(3) = X(3)
      GO TO 380
C
C     WATSON FUNCTION.
C
   60 CONTINUE
      DO 70 K = 1, N
         FVEC(K) = ZERO
   70    CONTINUE
      DO 110 I = 1, 29
         TI = DFLOAT(I)/C9
         SUM1 = ZERO
         TEMP = ONE
         DO 80 J = 2, N
            SUM1 = SUM1 + DFLOAT(J-1)*TEMP*X(J)
            TEMP = TI*TEMP
   80       CONTINUE
         SUM2 = ZERO
         TEMP = ONE
         DO 90 J = 1, N
            SUM2 = SUM2 + TEMP*X(J)
            TEMP = TI*TEMP
   90       CONTINUE
         TEMP1 = SUM1 - SUM2**2 - ONE
         TEMP2 = TWO*TI*SUM2
         TEMP = ONE/TI
         DO 100 K = 1, N
            FVEC(K) = FVEC(K) + TEMP*(DFLOAT(K-1) - TEMP2)*TEMP1
            TEMP = TI*TEMP
  100       CONTINUE
  110    CONTINUE
      TEMP = X(2) - X(1)**2 - ONE
      FVEC(1) = FVEC(1) + X(1)*(ONE - TWO*TEMP)
      FVEC(2) = FVEC(2) + TEMP
      GO TO 380
C
C     CHEBYQUAD FUNCTION.
C
  120 CONTINUE
      DO 130 K = 1, N
         FVEC(K) = ZERO
  130    CONTINUE
      DO 150 J = 1, N
         TEMP1 = ONE
         TEMP2 = TWO*X(J) - ONE
         TEMP = TWO*TEMP2
         DO 140 I = 1, N
            FVEC(I) = FVEC(I) + TEMP2
            TI = TEMP*TEMP2 - TEMP1
            TEMP1 = TEMP2
            TEMP2 = TI
  140       CONTINUE
  150    CONTINUE
      TK = ONE/DFLOAT(N)
      IEV = -1
      DO 160 K = 1, N
         FVEC(K) = TK*FVEC(K)
         IF (IEV .GT. 0) FVEC(K) = FVEC(K) + ONE/(DFLOAT(K)**2 - ONE)
         IEV = -IEV
  160    CONTINUE
      GO TO 380
C
C     BROWN ALMOST-LINEAR FUNCTION.
C
  170 CONTINUE
      SUM = -DFLOAT(N+1)
      PROD = ONE
      DO 180 J = 1, N
         SUM = SUM + X(J)
         PROD = X(J)*PROD
  180    CONTINUE
      DO 190 K = 1, N
         FVEC(K) = X(K) + SUM
  190    CONTINUE
      FVEC(N) = PROD - ONE
      GO TO 380
C
C     DISCRETE BOUNDARY VALUE FUNCTION.
C
  200 CONTINUE
      H = ONE/DFLOAT(N+1)
      DO 210 K = 1, N
         TEMP = (X(K) + DFLOAT(K)*H + ONE)**3
         TEMP1 = ZERO
         IF (K .NE. 1) TEMP1 = X(K-1)
         TEMP2 = ZERO
         IF (K .NE. N) TEMP2 = X(K+1)
         FVEC(K) = TWO*X(K) - TEMP1 - TEMP2 + TEMP*H**2/TWO
  210    CONTINUE
      GO TO 380
C
C     DISCRETE INTEGRAL EQUATION FUNCTION.
C
  220 CONTINUE
      H = ONE/DFLOAT(N+1)
      DO 260 K = 1, N
         TK = DFLOAT(K)*H
         SUM1 = ZERO
         DO 230 J = 1, K
            TJ = DFLOAT(J)*H
            TEMP = (X(J) + TJ + ONE)**3
            SUM1 = SUM1 + TJ*TEMP
  230       CONTINUE
         SUM2 = ZERO
         KP1 = K + 1
         IF (N .LT. KP1) GO TO 250
         DO 240 J = KP1, N
            TJ = DFLOAT(J)*H
            TEMP = (X(J) + TJ + ONE)**3
            SUM2 = SUM2 + (ONE - TJ)*TEMP
  240       CONTINUE
  250    CONTINUE
         FVEC(K) = X(K) + H*((ONE - TK)*SUM1 + TK*SUM2)/TWO
  260    CONTINUE
      GO TO 380
C
C     TRIGONOMETRIC FUNCTION.
C
  270 CONTINUE
      SUM = ZERO
      DO 280 J = 1, N
         FVEC(J) = DCOS(X(J))
         SUM = SUM + FVEC(J)
  280    CONTINUE
      DO 290 K = 1, N
         FVEC(K) = DFLOAT(N+K) - DSIN(X(K)) - SUM - DFLOAT(K)*FVEC(K)
  290    CONTINUE
      GO TO 380
C
C     VARIABLY DIMENSIONED FUNCTION.
C
  300 CONTINUE
      SUM = ZERO
      DO 310 J = 1, N
         SUM = SUM + DFLOAT(J)*(X(J) - ONE)
  310    CONTINUE
      TEMP = SUM*(ONE + TWO*SUM**2)
      DO 320 K = 1, N
         FVEC(K) = X(K) - ONE + DFLOAT(K)*TEMP
  320    CONTINUE
      GO TO 380
C
C     BROYDEN TRIDIAGONAL FUNCTION.
C
  330 CONTINUE
      DO 340 K = 1, N
         TEMP = (THREE - TWO*X(K))*X(K)
         TEMP1 = ZERO
         IF (K .NE. 1) TEMP1 = X(K-1)
         TEMP2 = ZERO
         IF (K .NE. N) TEMP2 = X(K+1)
         FVEC(K) = TEMP - TEMP1 - TWO*TEMP2 + ONE
  340    CONTINUE
      GO TO 380
C
C     BROYDEN BANDED FUNCTION.
C
  350 CONTINUE
      ML = 5
      MU = 1
      DO 370 K = 1, N
         K1 = MAX0(1,K-ML)
         K2 = MIN0(K+MU,N)
         TEMP = ZERO
         DO 360 J = K1, K2
            IF (J .NE. K) TEMP = TEMP + X(J)*(ONE + X(J))
  360       CONTINUE
         FVEC(K) = X(K)*(TWO + FIVE*X(K)**2) + ONE - TEMP
  370    CONTINUE
  380 CONTINUE
      RETURN
C
C     LAST CARD OF SUBROUTINE VECFCN.
C
      END
