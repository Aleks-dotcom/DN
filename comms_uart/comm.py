import serial
import time

serialPort = serial.Serial(
    port="COM1", baudrate=9600, bytesize=8, timeout=2, stopbits=serial.STOPBITS_ONE
)
serialString = ""  # Used to hold data coming over UART

valid = ['run','debug','step','print','break','help']
state = 'DEBUG'
how_many_breaks = 0
args = 0
msg_help = """
possible commands:
	HELP  'help' => help
	RUN   'run' => continue execution 
	DEBUG 'debug' => enter debug mode
	PRINT 'print' => print all the registers in processor pipeline
	BREAK 'break <args>' => set a breakpoint at addr <args>
	STEP  'step <args>' => step over <args> clock cycles
"""
print(msg_help)
try:
	while 1:
		time.sleep(.1)
		command = input(f"$ ({state}): ").split(' ')
		try:
			assert command[0] in valid
		except:		
			print(f"invalid command '{command[0]}'")

		if len(command) > 1:
			args = int(command[1])

		command = str(command[0])


		if command == 'debug':
			state = 'DEBUG'
			serialPort.write(b'd')

		if command == 'run':
			serialPort.write(b'i')
			state = 'RUNNING'

		if command == 'step':
			if args > 0:
				serialPort.write(b't'+args.encode())
			else:
				serialPort.write(b't1')

		if command == 'print':
			serialPort.write(b'r')
			time.sleep(.5)
			print(serialPort.read(10000))
			# TODO: parse the data returned from serial...

		if command == 'break':
			if how_many_breaks > 10:
				print('to much breaks already!')
			else:
				if args > 0:
					serialPort.write(b't'+str(args).encode())
					print(f'breakpoint at address {args} set')
					how_many_breaks +=1
				else:
					print('break command needs <args> > 0')

		if command == 'help':
			print(msg_help)


except KeyboardInterrupt as keyboard_e:
	print("\n\nBYE :)")
except serial.SerialException as serial_e:
	print(f'serial dies: {serial_e}')
