param([string]$command = "?SP")
$port = new-Object System.Io.Ports.Serialport COM5,19200,None,8,one
$port.open()
$port.ReadTimeout = 500
$port.WriteTimeout = 500
$port.Writeline("E = 0;")
$ignore=$port.Readline()
$port.Writeline($command+";")
$value=$port.Readline()
echo $value
$port.close()
