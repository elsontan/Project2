  {Object_Title_and_Purpose}
{
  Project: EE-17 Assignment
  Platform: Parallax Project USB Board
  Author: Elson Tan Jun Hao 2102036
  Date: 27 March 2022

}
CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001 = _ConClkFreq / 1_000


VAR
  long  Dir, Spd
  long  tofMainMem[2], ultraMainMem[4], movement, spdval

OBJ
  Term      : "FullDuplexSerial.spin" 'UART communication for debugging
  Sensor    : "SensorMUXControl.spin"   'Blackbox/Object
  MotorCtrl : "MecanumControl.spin"
  Comm      : "Comm2Control.spin"

PUB Main

  ''Declaration & Initialisation
  Comm.Start(_Ms_001,@Dir,@Spd)  'Initialise communication from comm control
  MotorCtrl.Start(_Ms_001,@movement,@spdval)
  Sensor.Start(_Ms_001, @tofMainMem,@ultraMainMem)

  repeat

    case Dir
      1:  'Forward
        if (tofMainMem[0]>175 OR (ultraMainMem[0]>0 and ultraMainMem[0]<250))
          movement := $AA
        else
          movement := Dir
          spdval := Spd

      2:  'Reverse
        if (tofMainMem[1]>175 OR (ultraMainMem[1]>0 and ultraMainMem[1]<250))
          movement := $AA
        else
          movement := Dir
          spdval := Spd

      3:  'Strafe Left
        if (ultraMainMem[2]>0 and ultraMainMem[2]<250)
          movement := $AA
        else
          movement := Dir
          spdval := Spd

      4:  'Strafe Right
        if (ultraMainMem[3]>0 and ultraMainMem[3]<250)
          movement := $AA
        else
          movement := Dir
          spdval := Spd

      5:  'Forward Left
        if (tofMainMem[0]>175 OR (ultraMainMem[0]>0 and ultraMainMem[0]<250) OR (ultraMainMem[2]>0 and ultraMainMem[2]<250))
          movement := $AA
        else
          movement := Dir
          spdval := Spd

      6:  'Forward Right
        if (tofMainMem[0]>175 OR (ultraMainMem[0]>0 and ultraMainMem[0]<250) OR (ultraMainMem[3]>0 and ultraMainMem[3]<250))
          movement := $AA
        else
          movement := Dir
          spdval := Spd

      7:  'Rvs Left
        if (tofMainMem[1]>175 OR (ultraMainMem[1]>0 and ultraMainMem[1]<250) OR (ultraMainMem[2]>0 and ultraMainMem[2]<250))
          movement := $AA
        else
          movement := Dir
          spdval := Spd

      8:  'Rvs Right
        if (tofMainMem[1]>175 OR (ultraMainMem[1]>0 and ultraMainMem[1]<250) OR (ultraMainMem[3]>0 and ultraMainMem[3]<250))
          movement := $AA
        else
          movement := Dir
          spdval := Spd


PRI Pause(ms) | t
  t := cnt - 1088
  repeat ( ms#>0 )
    waitcnt(t += _Ms_001)
  return