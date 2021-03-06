      program pythiaExampleRead
C
C      test program for stdhep/pythia interface
C      compare event list
C      write events and cross-section
C      read the events back in again 
C
#include "stdlun.inc"

      integer istr,mstat
      integer nevt,i,lok
C
      nevt=100
      call upyinit(nevt,istr)

C          Fill Stdhep common block 1 (only valid for Pythia)
      call stdflpyxsec(nevt)
C          Write Stdhep begin-run record   
      call stdxwrt(100,istr,lok)
      if(lok.ne.0) write(lnhout,*)
     1        ' Problem writing stdhep begin run record'
c
      do 100 i=1,nevt
        call pyevnt
        call lunhep(1)
        call tstflem(20)
        call stdxwrt(1,istr,lok)
C          Fill Stdhep common block 1 (only valid for Pythia)
        call stdflpyxsec(nevt)
        call tstflxsec(20)
 100  continue
C
C          Fill Stdhep common block 1
      call stdflpyxsec(nevt)
C          Write end-of-run record  
      call stdxwrt(200,istr,lok)
      if(lok.ne.0) write(lnhout,*) ' Problem writing end run record'

C...   Print end of run statistics.
      mstat=1
      call pystat(mstat)

c...close event file
      call stdxend(istr)
C...print histograms
      call houtpu(lnhout)
      call histdo
c...close output file
      close(unit=lnhout)
c...now open the file we wrote and read it  
      call readback(nevt)
      stop
      end

      subroutine upyinit(nevt,istr)
C
C   Pythia initialization
C
#include "pydat1.inc"
#include "stdlun.inc"

C...   PYTHIA initialization variables.
      character*4 frame
      character*5 beam,target
      integer nevt,istr
      double precision win
C
C initialize HEP logical units
      lnhwrt=23
      lnhrd=24
      lnhdcy=0
      lnhout=22
      lnhpdf=0
      lnhdmp=0
      mstu(11)=lnhout
      open(unit=lnhout,file='pythiaExampleRead.lpt',status='new')
      call stdxwinit('pythiaExampleRead.io','StdHep/Pythia example',
     1               nevt,istr,lok)
C
      call tstbkem(20)
C
C...   Initialize PYTHIA
      frame  = 'cms'
      beam   = 'pbar'
      target = 'p'
      win    = 1800.0d0
      call pygive('msel=5')
      call pygive('mstj(21)=0')
      call pyinit(frame,beam,target,win)

      return
      end

      subroutine readback(ntries)
#include "stdlun.inc"
#include "stdcm1.inc"

      integer lok,ifl,istr,ntries,i
      character*30 filrd

      data filrd/'pythiaExampleRead.io'/

      lnhout = 32  
      open(unit=lnhout,file='pythiaExampleReadBack.lpt',status='new')

      call tstbkem(20)
C...initialize MCFio once only
c      call mcfio_init()
C...now open and read events
      call stdxropen(filrd,ntries,istr,lok)
      if(lok.ne.0) write(lnhout,1001) filrd
      if(lok.ne.0) go to 200
      write(lnhout,1002) filrd
      lok = 0
      do while( lok .eq. 0 ) 
          call stdxrd(ifl,istr,lok)
          if(lok.eq.0)then
C... keep looping if this is not a STDHEP record
              if(ifl.eq.1) call tstflem(20)
              if(ifl.eq.100) write(lnhout,1003) filrd, generatorname
          endif
      enddo
      call stdxend(istr)
 200  continue
C...print histograms
      call houtpu(lnhout)
      call histdo
      return
1001  format(' could not open file ',a20)
1002  format(' file ',a20,' has been opened')
1003  format(/' file ',a20,' was generated by ',a20)
      end

