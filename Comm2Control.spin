{Object_Title_and_Purpose}
{

    Project: EE-17 Assignment
    Platform: Parallax Project USB Board
    Author: Elson Tan Jun Hao 2102036
    Date: 17 Feb 2022
    Log:
        Date:   Desc:
        23 Feb 2022             Assigned new diagonal direction using other command bytes and checksum byte
                                , Baud rate changed to 57_000
}

CON


        commStart =$7A          'Start
        commRxPin1 = 12
        commTxPin1 = 13
        commBaud = 57_600

        commForward = $01        'Forward
        commReverse = $02        'Reverse
        commLeft =  $03         'Left
        commRight =  $04        'Right
        commFwdLeft = $05       'Diagonally forward left
        commFwdRight = $06     'Diagonally forward right
        commRvsLeft = $07       'Diagonally back left
        commRvsRight = $08      'Diagonally back right
        commTurnCW = $09
        commTurnACW = $0A

        commStopAll =  $AA      'Stop
        commShutDown = $0B


        commChecksum = $7F
        commRxPin = 20
        commTxPin = 21


VAR  'Global Variable

  long cog3ID , cog3Stack[64], check, checksum
  long _Ms_001, dir, spd, tmp

OBJ   ' Objects
  Cortex      : "FullDuplexSerial.spin" 'UART communication for debugging
  Term        : "FullDuplexSerial.spin"

PUB Start(mainMSVal1,direction,speed)

  _Ms_001 := mainMSVal1

  Pause(1000)

  cog3ID := cognew(Value(direction,speed),@cog3Stack)

  return
PUB Value(direction,speed)

  Cortex.Start(commRxPin,commTxPin,0,115200)
  Term.Start(31, 30, 0, 230400)

  Pause(1000)

  'Receiver
  repeat
    check := Cortex.Rx  'tmp repeatly check for the command
    Term.Str(String(13, "Start: "))
    Term.Hex(check, 2)
    if check == CommStart  'When tmp is $7A

      tmp := Cortex.Rx
      dir := tmp        'Direction byte

      tmp := Cortex.Rx
      spd := tmp        'Speed byte

      tmp := Cortex.Rx
      checksum := (dir^spd) ^ commChecksum

      terminal
      if tmp == checksum
       long[direction] := dir
       long[speed] := spd

PUB terminal |  direction,speed


    Term.Str(String(13, "Direction: "))
    Term.Hex(dir, 2)
    Term.Str(String(13, "Speed: "))
    Term.Dec(spd)
    Term.Str(String(13, "Checksum: "))
    Term.Hex(tmp, 2)
    Pause(200)

PUB StopCore
  if cog3ID    ''Avoid reinitialization of cog
    cogstop (cog3ID~)

PUB Stop
  Cortex.Tx($AA)

PUB Continue
  Cortex.Tx(dir)
PRI Pause(ms) | t
  t := cnt - 1088
  repeat ( ms#>0 )
    waitcnt(t += _Ms_001)
  return