#!/usr/bin/env python

import time
import serial

##### SERIAL CONNECTIONS

# iRobot
ser_irobot = serial.Serial(
    port='/dev/cu.usbserial',
    baudrate=57600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)

# PmodBT2 of FPGA
ser_fpga = serial.Serial(
    port='/dev/tty.RNBT-6427-RNI-SPP',
    baudrate=9600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)

##### STUFF
CLOSE_CONNECTION = 'RESET'

# Time in seconds between opcode commands sent to irobot
# TODO: might not even need this
PAUSE = 0.001

# SW0: FWD (1) <=> BWD (0)
SW0 = 'u'

# SW1: GO (1) <=> STOP (0)
SW1 = 'd'

INIT = 'i'
STOP = 's'
FWD = 'f'
BWD = 'b'
LEFT_TURN = 'l'
RIGHT_TURN = 'r'

STOP_CMD = [137, 0, 0, 0, 0]
CTL_MODE = [132]

#SW1, SW0
STATES = ['STOP/BACK', 'STOP/FWD', 'GO/BACK', 'GO/FWD']
STATE = STATES[0]

CMD_MAP = {
    INIT : [128] + CTL_MODE,
    STOP : STOP_CMD, 
    FWD : [137, 0, 100, 128, 0],
    BWD : [137, 255, 156, 128, 0],
    LEFT_TURN : [137, 0, 100, 0, 1] + [157, 0, 1] + STOP_CMD,
    RIGHT_TURN : [137, 0, 100, 255, 255] + [157, 255, 255] + STOP_CMD
}
FSM_CMDS = [SW0, SW1]

def send_cmd(ser, cmd):
    if cmd not in CMD_MAP:
        print("ERROR: unknown command: " + cmd)
        return
    print("Sending command: " + cmd)
    opcodes = CMD_MAP[cmd]
    for o in opcodes:
        ser.write(chr(o))
        time.sleep(PAUSE)
    print("Command " + cmd + " successfully sent.")


def fsm_next_state(input):
    global STATE
    #print ("Current state: " + STATE)
    # Next state
    if STATE == STATES[0]:
        if input == SW0:
            STATE = STATES[1]
        elif input == SW1:
            STATE = STATES[2]
    elif STATE == STATES[1]:
        if input == SW0:
            STATE = STATES[0]
        elif input == SW1:
            STATE = STATES[3]
    elif STATE == STATES[2]:
        if input == SW0:
            STATE = STATES[3]
        elif input == SW1:
            STATE = STATES[0]
    elif STATE == STATES[3]:
        if input == SW0:
            STATE = STATES[2]
        elif input == SW1:
            STATE = STATES[1]
    #print ("Next state: " + STATE)

def fsm_output(ser):
    global STATE

    # Output    
    if STATE == STATES[0]:
        send_cmd(ser, STOP)
    elif STATE == STATES[1]:
        send_cmd(ser, STOP)
    elif STATE == STATES[2]:
        send_cmd(ser, BWD)
    elif STATE == STATES[3]:
        CUR_VELOCITY = BWD
        send_cmd(ser, FWD)

##### INITIALIZE

ser_fpga.isOpen()
ser_irobot.isOpen()

##### USER INPUT LOOP

while True:
    input = raw_input(">> ")

    # Exit program
    if input == 'exit':
        ser_irobot.close()
        ser_fpga.close()
        exit()


    # README ----------------------------------------------
    # Bluetooth Command
    elif input == 'bt':
        while True:
            if (ser_fpga.inWaiting()>0):
                bytesToRead = ser_fpga.inWaiting()
                input = ser_fpga.read(bytesToRead)
                if CLOSE_CONNECTION in input:
                    ser_fpga.close()
                    ser_irobot.close()
                    exit()
                input = input[0] ### TODO: FIGURE OUT HOW TO STRIP INPUT!! or do it from vhdl. rstrip, lstrip, strip don't work.
                if input in FSM_CMDS: # this handles SW0 and SW1 commands
                    fsm_next_state(input)
                    fsm_output(ser_irobot)
                else: # this handles any other command (ie. left, right, initialize)
                    send_cmd(ser_irobot, input)
                    fsm_output(ser_irobot)
    # -----------------------------------------------------

    # Terminal Command
    else:

        # Use pre-programmed command
        if input in FSM_CMDS:
            fsm_next_state(input)
            fsm_output(ser_irobot)
        elif input in CMD_MAP:
            send_cmd(ser_irobot, input)
            fsm_output(ser_irobot)

        # Directly use iRobot opcode
        elif input.isdigit():
            # send the character to the device
            ser_irobot.write(chr(int(input)))
            out = ''
            # let's wait one second before reading output (let's give device time to answer)
            time.sleep(1)
            while ser_irobot.inWaiting() > 0:
                out += ser_irobot.read(1)

            if out != '':
                print ">>" + out

        else:
            print("Unrecoginzable input!")
