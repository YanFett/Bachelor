#from xmlrpc.server 
from SimpleXMLRPCServer import SimpleXMLRPCServer
import time ,os, sys		# for waiting between monitoring calls
from subprocess import Popen, PIPE
import numpy as np
import requests
def _get_Xepr():
	try:

		p = Popen(["Xepr","--apipath"], stdin=PIPE, stdout=PIPE, stderr=PIPE)

		output=p.communicate()[0]

		isXepr = True

	except OSError:

		isXepr = False

		try:

			p = Popen(["Xenon","--apipath"], stdin=PIPE, stdout=PIPE, stderr=PIPE)

			output=p.communicate()[0]

			isXenon = True

		except OSError:

			isXenon = False

			try:

				p = Popen(["Xenon_nano","--apipath"], stdin=PIPE, stdout=PIPE, stderr=PIPE)

				output=p.communicate()[0]

				isXenonNano = True

			except OSError:

				isXenonNano = False

	# this adds the path to the api into the system path
	#output = '/opt/Bruker/xenon/XeprAPI' # because bruker is unable to path their own software...
	#did not fix the error
	if not output is None:

		sys.path.insert(0,output)

	####################################################################################################

	import XeprAPI		# load Xepr API module
	return XeprAPI.Xepr()	# start talking with Xepr API

def _get_Exp(Xepr):
	# try to get the current experiment from xenon/Xepr for monitoring the frequency
	try:

		return Xepr.XeprExperiment()

	except XeprAPI.ExperimentError:

			print("No Experiment in Primary","No Experiment has been selected in the Primary Viewport of Xepr.")

			exit()

def _get_Hidden(Xepr):
	# try to get the current experiment from xenon/Xepr for monitoring the frequency
	try:

		return Xepr.XeprExperiment("AcqHidden")

	except XeprAPI.ExperimentError:

			print("No Experiment in Primary","No Experiment has been selected in the Primary Viewport of Xepr.")

			exit()

class Experiment:
	def __init__(self):
		Xepr = _get_Xepr()
		self.Exp = _get_Exp(Xepr)
		self.Hidden = _get_Hidden(Xepr)

	def start(self):
		currentExp = self.Exp

		currentExp.aqExpRun()

		# delay to make sure experiment is running

		while currentExp.isRunning==False:
			pass
		return True

	def tupl(self):
		tupl = list()
		currentExp = self.Exp
		tupl.append(currentExp["FieldValue"].value)
		tupl.append(currentExp["FrequencyMon"].value)
		tupl.append(currentExp["SignalLevel"].value)
		return tupl
	
	def get_frequency(self):
		return self.get("FrequencyMon",False)

	def get_power(self):
		return self.get("Power",False)

	def get(self,string,Hidden):
		if(Hidden):
			currentExp = self.Hidden
		else:
			currentExp = self.Exp			
		return currentExp[string].value

	def _set(self,string,Hidden,Value):
		if(Hidden):
			currentExp = self.Hidden
		else:
			currentExp = self.Exp			
		currentExp[string].value = Value
		return currentExp[string].value;


	def get_TimeConstant(self):
		return self.get('TimeConst',False)

	def set_TimeConstant(self,TimeConstant):
		return self.set('TimeConst',False,TimeConstant)

	def start_IrisDown(self):
		Hidden = self.Hidden
		Hidden['IrisDown'].value = True
		#time.sleep(3)
		#Hidden['IrisDown'].value = False
		return Hidden ['IrisDown'].value 
	
	def start_IrisFullDown(self):
		TurnTime = 5.75 # One Turn unprecise
		Hidden = self.Hidden
		Hidden['IrisDown'].value = True
		time.sleep(TurnTime)
		Hidden['IrisDown'].value = False
		return not Hidden['IrisDown'].value 
	
	def start_IrisQuarterDown(self):
		TurnTime = 2.2725 # Quarter Turn
		Hidden = self.Hidden
		Hidden['IrisDown'].value = True
		time.sleep(TurnTime)
		Hidden['IrisDown'].value = False
		return not Hidden['IrisDown'].value 
	
	def start_IrisUp(self):
		Hidden = self.Hidden
		Hidden['IrisUp'].value = True
		#time.sleep(3)
		#Hidden['IrisDown'].value = False
		return Hidden ['IrisUp'].value 
	
	def start_IrisFullUp(self):
		TurnTime = 5.75 # One Turn unprecise
		Hidden = self.Hidden
		Hidden['IrisUp'].value = True
		time.sleep(TurnTime)
		Hidden['IrisUp'].value = False
		return not Hidden['IrisUp'].value 
	
	def start_IrisQuarterUp(self):
		TurnTime = 2.2725 # Quarter Turn
		Hidden = self.Hidden
		Hidden['IrisUp'].value = True
		time.sleep(TurnTime)
		Hidden['IrisUp'].value = False
		return not Hidden['IrisUp'].value 
	

	def stop_Iris(self):
		Hidden = self.Hidden
		Hidden['IrisDown'].value = False
		Hidden['IrisUp'].value = False
		return not (Hidden['IrisDown'].value or Hidden['IrisUp'].value)

	def start_experiment(self):
		currentExp = self.Exp	
		currentExp.aqExpRun()
		return currentExp.isRunning

	def is_running(self):
		currentExp = self.Exp		
		return currentExp.isRunning

	def setup_sweep(self,centerfield, sweepwidth, ModAmp, PpModAmp, SweepTime, TimeConstant):
		currentExp = self.Exp	
		currentExp["CenterField"].value = centerfield
		currentExp["SweepWidth"].value = sweepwidth
		currentExp["SweepTime"].value = SweepTime
		currentExp["ModAmp"].value = ModAmp
		currentExp["ModResol"].value =  PpModAmp
		currentExp["TimeConst"].value =  TimeConstant*1000
		return True
	
	

port = 7998
ip = "192.168.1.1"
server = SimpleXMLRPCServer((ip, port))
print("Listening on port "+str(port)+ "...") 
experiment = Experiment()
#these functions all have to return something, otherwise there will be an error that "allow_none" should be allowed
def start_measurement():
	return experiment.start()
def get_tuple():
	return experiment.tupl()
def get_frequency():
	return experiment.get_frequency()
def get_power():
	return experiment.get_power()
def get(string, Bool):
	Hidden = Bool == 'True'
	return experiment.get(string, Hidden)
def _set(string,Bool,Value):
	Hidden = Bool == 'True'
	Value = float(Value)
	return experiment._set(string, Hidden,Value)	

def start_IrisDown():
	return experiment.start_IrisDown()
def start_IrisUp():
	return experiment.start_IrisUp()
def stop_Iris():
	return experiment.stop_Iris()
def start_IrisQuarterDown():
	return experiment.start_IrisQuarterDown()
def start_IrisQuarterUp():
	return experiment.start_IrisQuarterUp()
def start_experiment():
	return experiment.start_experiment()
def is_running():
	return experiment.is_running()
def setup_sweep(centerfield, sweepwidth, ModAmp, PpModAmp, SweepTime, TimeConstant):
	return experiment.setup_sweep(centerfield, sweepwidth, ModAmp, PpModAmp, SweepTime, TimeConstant)	
def get_TimeConstant():
	return experiment.get_TimeConstant()
def set_TimeConstant(TimeConstant):
	return experiment.set_TimeConstant(TimeConstant)
def set_precise_field(field):
	  headers = {
		  'User-Agent':     'Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0',
		  'Accept':         'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
		  'Accept-Language':'en-US,en;q=0.5',
		  'Accept-Encoding':'gzip, deflate',
		  'Referer':        'http://192.168.1.104/hall_service.html',
		  'Origin': 	  'http://192.168.1.104',
		  'Authorization':  'Basic cm9vdDpCUlVLRVI=',
		  'Connection':     'keep-alive',
		  'Upgrade-Insecure-Requests': '1',
		  'Content-Type':   'application/x-www-form-urlencoded',
		  'Content-Length': '45'
	  }
	  # define your URL params (!= of the body of the POST request)
	  params = {
	  }
	  # define the body of the POST request
	  data = { 
		  'WebHallServiceFieldVal': field,
		  'Submit': 'Modify'
	  }
	  # send the POST request
	  site_adress = 'http://192.168.1.104/Forms/hall_service_1'
	  response = requests.post(site_adress, params=params, data=data, headers=headers)
	  # here is the response
	  return True;


server.register_function(set_precise_field,"set_precise_field")
server.register_function(start_experiment, "start_experiment")
server.register_function(is_running, "is_running")
server.register_function(setup_sweep, "setup_sweep")
server.register_function(start_measurement, "start_measurement")
server.register_function(get_tuple,"get_tuple")
server.register_function(get_frequency,"get_frequency")
server.register_function(get_power,"get_power")
server.register_function(get,"get")
server.register_function(start_IrisDown,"start_IrisDown")
server.register_function(start_IrisUp,"start_IrisUp")
server.register_function(start_IrisQuarterDown,"start_IrisQuarterDown")
server.register_function(start_IrisQuarterUp,"start_IrisQuarterUp")
server.register_function(stop_Iris,"stop_Iris")
server.register_function(get_TimeConstant,"get_TimeConstant")
server.register_function(set_TimeConstant,"set_TimeConstant")
server.register_function(_set,"set")
server.serve_forever()

