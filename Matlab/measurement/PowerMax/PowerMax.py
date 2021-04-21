import paramiko

class PowerMax:
  def __init__(self):
    self.host = "192.168.1.4"
    self.port = "22"
    self.username = "Administrator"
    self.password = "Keysight4u!"

    
  def communicate(self):  
    self.ssh = paramiko.SSHClient()
    self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    self.ssh.connect(self.host, self.port, self.username, self.password)
    cmd = r"powershell -InputFormat none -OutputFormat TEXT -file D:\Scripts\Laserpower_Measure.ps1"
    stdin, stdout, stderr = self.ssh.exec_command(cmd)
    line = stdout.readline()
    powerstr = line.split(",")
    try:
      power = float(powerstr[0])
    except ValueError as e:
      raise ValueError("Cant connect to PowerMax, Try to reconnect the device Physically.", e, e.args)
    self.ssh.close()
    del stdin, stdout, stderr, self.ssh
    return power
  