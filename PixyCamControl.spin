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


VAR
  long  symbol

OBJ
  Term      : "FullDuplexSerial.spin"    'UART Communication for debugging
  TCA       : "TCA9548Av2.spin"
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


PRI private_method_name


DAT
name    byte  "string_data",0
