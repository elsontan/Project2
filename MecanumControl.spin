{Object_Title_and_Purpose}
{

    Project: EE-14 Assignment
    Platform: Parallax Project USB Board
    Author: Elson Tan Jun Hao 2102036
    Date: 17 Feb 2022
    Log:
        Date:   Desc:
        17 Feb 2022             Create functions of the basic movements for the mecanum wheels.
        23 Feb 2022             Added the acceleration and deceleration for forward,reverse,left
        24 Feb 2022             Changed back to fixed speed for recording assignment
}


CON
        '_clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        '_xinfreq = 5_000_000
        '_ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        '_Ms_001 = _ConClkFreq / 1_000

        ' RoboClaw1
        R1S1 = 3
        R1S2 = 2

        ' RoboClaw2
        R2S1 = 5
        R2S2 = 4

        ' SimpleSerial
        SSBaud = 57_600


        'FrontLeft
        'Rvs = 1, Stop = 64, Fwd = 127

        'FrontRight
        'Rvs = 128, Stop 192, Fwd = 255

        'BackLeft
        'Rvs = 1, Stop = 64, Fwd = 127

        'BackRight
        'Rvs = 128, Stop 192, Fwd = 255

        FwdSpd1 = 96
        FwdSpd2 = 224
        RvsSpd1 = 32
        RvsSpd2 = 160

        Stop1 = 64
        Stop2 = 192

        Shutdown = 0

VAR
  long cog2Stack[64],cog2ID, arr[2]
  long _Ms_001


OBJ
  MD[2]      : "FullDuplexSerial.spin"

PUB Start (mainMSVal,dir,spd)

  _Ms_001 := mainMSVal

  StopCore

  cog2ID := cognew(RunMotor(dir,spd), @cog2Stack)

  return

PUB RunMotor(dir,spd)

  MotorInit     'Initializing motors

  repeat
    arr[0] := long[dir]
    arr[1] := long[spd]

    case arr[0]
      $01:
        Forward

      $02:
        Reverse

      $03:
        Left

      $04:
        Right

      $05:
        FwdLeft

      $06:
        FwdRight

      $07:
        RvsLeft

      $08:
        RvsRight
{
      $09:
        TurnCW

      $0A:
        TurnACW
}
      $AA:
        StopAll

      $0B:
        Shutoff

    'Pause(50)



PUB StopCore

''Stop cog and place into dormant state.
   if cog2ID
     ''Set Speed to 0%
     'StopAll
     'Shutoff
     cogstop (cog2ID~)

PUB MotorInit

  MD[0].Start(R1S2, R1S1, 0, SSBaud)
  MD[1].Start(R2S2, R2S1, 0, SSBaud)

  'Cleaning buffer bytes
  if MD[0].RxCheck
    MD[0].RxFlush

  return

PUB Forward

  MD[0].Tx(Stop1+arr[1])
  MD[0].Tx(Stop2+arr[1])
  MD[1].Tx(Stop1+arr[1])
  MD[1].Tx(Stop2+arr[1])

PUB Reverse

  MD[0].Tx(Stop1-arr[1])
  MD[0].Tx(Stop2-arr[1])
  MD[1].Tx(Stop1-arr[1])
  MD[1].Tx(Stop2-arr[1])

PUB Left

  MD[0].Tx(Stop1-arr[1])
  MD[0].Tx(Stop2+arr[1])
  MD[1].Tx(Stop1+arr[1])
  MD[1].Tx(Stop2-arr[1])

PUB Right

  MD[0].Tx(Stop1+arr[1])
  MD[0].Tx(Stop2-arr[1])
  MD[1].Tx(Stop1-arr[1])
  MD[1].Tx(Stop2+arr[1])

PUB FwdLeft

  MD[0].Tx(Stop1)
  MD[0].Tx(Stop2+arr[1])
  MD[1].Tx(Stop1+arr[1])
  MD[1].Tx(Stop2)

PUB FwdRight

  MD[0].Tx(Stop1+arr[1])
  MD[0].Tx(Stop2)
  MD[1].Tx(Stop1)
  MD[1].Tx(Stop2+arr[1])

PUB RvsLeft

  MD[0].Tx(Stop1-arr[1])
  MD[0].Tx(Stop2)
  MD[1].Tx(Stop1)
  MD[1].Tx(Stop2-arr[1])

PUB RvsRight

  MD[0].Tx(Stop1)
  MD[0].Tx(Stop2-arr[1])
  MD[1].Tx(Stop1-arr[1])
  MD[1].Tx(Stop2)

PUB TurnCW

  MD[0].Tx(Stop1+arr[1])
  MD[0].Tx(Stop2-arr[1])
  MD[1].Tx(Stop1+arr[1])
  MD[1].Tx(Stop2-arr[1])

PUB TurnACW

  MD[0].Tx(Stop1-arr[1])
  MD[0].Tx(Stop2+arr[1])
  MD[1].Tx(Stop1-arr[1])
  MD[1].Tx(Stop2+arr[1])

PUB StopAll

  MD[0].Tx(Stop1)
  MD[0].Tx(Stop2)
  MD[1].Tx(Stop1)
  MD[1].Tx(Stop2)

PUB Shutoff

  MD[0].Tx(0)
  MD[1].Tx(0)

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)
  return

DAT