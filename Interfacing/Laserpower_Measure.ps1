$port = new-Object System.Io.Ports.Serialport COM6,9600,None,8,one
$port.open()
$port.ReadTimeout = 500
$port.WriteTimeout = 500
$ignore = $port.ReadExisting()
$port.Writeline("READ?`r`n")
$value=$port.ReadLine()
echo $value
$port.close()
