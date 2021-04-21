import paramiko

class Communicate_Coherent:
  def __init__(self):
    self.host = "192.168.1.4"
    self.port = "22"
    self.username = "Administrator"
    self.password = "Keysight4u!"

    
  def communicate(self, command):  
    self.ssh = paramiko.SSHClient()
    self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    self.ssh.connect(self.host, self.port, self.username, self.password)
    cmd = r'powershell -InputFormat none -OutputFormat TEXT -file D:\Scripts\Laserpower_Read.ps1 -command "'+ command+'"'
    stdin, stdout, stderr = self.ssh.exec_command(cmd)
    line = stdout.readline()
    #if a number is returned, cast it, if not, dont.
    try:
      power = float(line)
    except ValueError:
      power = line
    self.ssh.close()
    del stdin, stdout, stderr, self.ssh
    return power
  