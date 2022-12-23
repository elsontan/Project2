{Object_Title_and_Purpose}
{

    Project: EE-17 Assignment
    Platform: Parallax Project USB Board
    Author: Elson Tan Jun Hao 2102036
    Date: 15 Nov 2021
    Log:
        Date:   Desc:
        15 Nov 2021: Implementing Time-Of-Flight sensors and ultrasonic sensors
        22 Nov 2021: Integrate the Sensors and motor control together to stop motors when obstacles detected
        09 Feb 2021: Added UltraSonic 3 and 4 for left and right sensing
}

CON
        'Declaration for Sensor Address

        tofAdd = $29
        ultraAdd = $57

        Tof1RST = 6
        Tof2RST = 7
VAR
  long cogStack[64], cog
  long _Ms_001
  'long  tofMainMem, ultraMainMem

OBJ
  Term      : "FullDuplexSerial.spin"    'UART Communication for debugging
  TCA      : "TCA9548Av2.spin"
PUB Start(mainMSVal,tofMainMem,ultraMainMem)
{{Launch Sensor into new cog}}

  _Ms_001 := mainMSVal

  'Stop

  Pause(1000)

  cog := cognew(runAllSensors(tofMainMem, ultraMainMem),@cogStack) + 1

  return cog
PUB runAllSensors(tofMainMem, ultraMainMem) | i
{{Main code running sensors retrieving & updating main memory}}
  '' Init TCA9548A
  TCA.PInit2
  Pause(100)

  ''Init ToF
  TCA.PSelect(0,0)
  tofInit(0)
  Pause(500)
  TCA.PSelect(1,0)
  tofInit(1)
  Pause(500)

  repeat

    'ToF Front
    TCA.PSelect(0,0)
    long[tofMainMem][0] := TCA.GetSingleRange(tofAdd)

    'ToF Back
    TCA.PSelect(1,0)
    long[tofMainMem][1] := TCA.GetSingleRange(tofAdd)

    'Ultrasonic Front
    TCA.PSelect(2,0)
    TCA.PWriteByte(2, $57, $01)  ' Trigger Sensor
    Pause(30)
    long[ultraMainMem][0] := TCA.readHCSR04(2, ultraAdd)*100/254
    Pause(1)
    TCA.resetHCSR04(2, ultraAdd)

    'Ultrasonic Back
    TCA.PSelect(3,0)
    TCA.PWriteByte(3, ultraAdd, $01)  ' Trigger Sensor
    Pause(30)
    long[ultraMainMem][1] := TCA.readHCSR04(3, ultraAdd)*100/254
    Pause(1)
    TCA.resetHCSR04(3, ultraAdd)

    'Ultrasonic Left
    TCA.PSelect(4,0)
    TCA.PWriteByte(4, ultraAdd, $01)  ' Trigger Sensor
    Pause(30)
    long[ultraMainMem][2] := TCA.readHCSR04(4, ultraAdd)*100/254
    Pause(1)
    TCA.resetHCSR04(4, ultraAdd)

    'Ultrasonic Right
    TCA.PSelect(5,0)
    TCA.PWriteByte(5, ultraAdd, $01)  ' Trigger Sensor
    Pause(30)
    long[ultraMainMem][3] := TCA.readHCSR04(5, ultraAdd)*100/254
    Pause(1)
    TCA.resetHCSR04(5, ultraAdd)



PUB OnSensors | tofMainMem, ultraMainMem
  ''Run and print readings for sensors
  Term.Str(String(13, "Tof 1 Reading: "))
  Term.Dec(long[tofMainMem][0])
  Term.Str(String(13, "Tof 2 Reading: "))
  Term.Dec(long[tofMainMem][1])
  Term.Str(String(13, "Ultrasonic 1 Readings: "))
  Term.Dec(long[ultraMainMem][0])
  Term.Str(String(13, "Ultrasonic 2 Readings: "))
  Term.Dec(long[ultraMainMem][1])
  Term.Str(String(13, "Ultrasonic 3 Readings: "))
  Term.Dec(long[ultraMainMem][2])
  Term.Str(String(13, "Ultrasonic 4 Readings: "))
  Term.Dec(long[ultraMainMem][3])

  Pause(200)
  Term.Tx(0) 'Clear terminal

PUB Stop
  if cog    ''Avoid reintialization of cog
    cogstop (~cog-1)
  return


PRI tofInit(I2Cdevice)

  'Declaration & Initialisation
  'Term.Start(31, 30, 0, 115200)

  case I2Cdevice
    0:
      ''ToF 1 initialization
      TCA.initVL6180X(Tof1RST)
      TCA.ChipReset(1,Tof1RST)
      Pause(1000)
      TCA.FreshReset(tofAdd)
      TCA.MandatoryLoad(tofAdd)
      TCA.RecommendedLoad(tofAdd)
      TCA.FreshReset(tofAdd)

    1:      ''ToF 2 initialization
      TCA.initVL6180X(Tof2RST)
      TCA.ChipReset(1,Tof2RST)
      Pause(1000)
      TCA.FreshReset(tofAdd)
      TCA.MandatoryLoad(tofAdd)
      TCA.RecommendedLoad(tofAdd)
      TCA.FreshReset(tofAdd)

  return

PRI Pause(ms) | t
  t := cnt - 1088
  repeat ( ms#>0 )
    waitcnt(t += _Ms_001)
  return