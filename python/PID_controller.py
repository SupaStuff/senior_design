
# coding: utf-8

# In[1]:

from pprint import pprint
import matplotlib.pyplot as plt
import math
import numpy as np
import itertools

import matplotlib.animation as animation
from IPython.display import display, HTML



# In[2]:

class PID(object):
    def __init__(self, dState=0, iState=0, iMin=0, iMax=100, Kp=1, Ki=0, Kd=0):
        self.dState = dState  # Last position input
        self.iState = iState  # Integrator state
        self.iMin   = iMin    # minimum allowable integrator state
        self.iMax   = iMax    # maximum allowable integrator state
        self.Kp     = Kp      # proportional gain
        self.Ki     = Ki      # integral gain
        self.Kd     = Kd      # derivative gain


# In[3]:

def updatePID(pid, error, position):
    
    #proportional term
    p = pid.Kp * error
    
    # calculate the integral state with appropriate limiting
    pid.iState += error
    if pid.iState > pid.iMax:
        pid.iState = pid.iMax
    elif pid.iState < pid.iMin:
        pid.iState = pid.iMin
    
    i = pid.Ki * pid.iState
    
    #derivative term
    d = pid.Kd * (pid.dState - position)
    pid.dState = position
    
    return p + i + d    


# In[4]:

def newtonsLawOfCooling(T_0, T_a=15.1, k=0.001859):
    t = itertools.count(0)
    return lambda x: x + (T_0 - T_a)*(math.exp(-k) - 1)*math.exp(-k*next(t))


# In[5]:

def humidityfunct(k):
    return lambda x: x + k


# In[6]:

def CO2funct(k):
    return lambda x: x + k


# In[7]:

def plantsys(u_t, measured, plant_process, adder=lambda x,y: x+y):
    return plant_process(adder(measured, u_t))


# In[8]:

def heatercooler(x,y):
    return x + (min(y,3) if y>0 else max(y,-3))


# In[9]:

def simulate(initial, desired, PIDs, functs, ctrls=[]):
    n = len(PIDs)
    measurements = [initial]
    measured     = np.array(initial)
    desire = np.array(desired)
    
    for i in range(100):
        error    = desire - measured
        u_t      = [updatePID(pid, err, measure) for pid, err, measure in zip(PIDs, error, measured)]
        measured = [plantsys(u, measure, funct, ctrl)  for u, measure, funct, ctrl in zip(u_t, measured, functs, ctrls)]
        measurements.append(measured)
    return np.array(measurements)


# In[10]:

def simulate1(initial, desired, PIDs, funct, ctrl=lambda x,y: x+y):
    measurements = [initial]
    measured = initial
    
    for i in range(100):
        error    = desired - measured
        u_t      = updatePID(PIDs, error, measured)
        measured = plantsys(u_t, measured, funct, ctrl)
        measurements.append(measured)
    return np.array(measurements)


# In[11]:

def zieglerNichols(initial, desired, funct):
    pid = PID()
    K_c = 1.0
    T_i = 0.0
    T_d = 0.0
    
    OK = False
    i = 0
    
    res = []
    
    while(not OK):
        measurements = simulate([initial], [desired], [pid], [funct])[0]
        error = measurements - desired
        res.append(sum(error**2), K_c)
        
        K_c += 0.001
        
        i += 1
        if(i == 10000):
            OK = True

# ### Simulate

# In[13]:

desiredTemp = 23.9
measuredTemp = 20
P=40.0
I=30.0
D=20.0

tuning = np.empty((P,I,D),dtype=object)
for p in range(int(P)):
    for i in range(int(I)):
        for d in range(int(D)):
            PIDtemp = PID(Kp=(p+10)/10, Ki=i/10, Kd=d/10)
            tuning[p,i,d] = simulate1(measuredTemp, desiredTemp, PIDtemp,
                                      newtonsLawOfCooling(T_0=measuredTemp), heatercooler)


# ### Animate

# In[14]:

fig, ax = plt.subplots()

p=0
i=0
d=0

n=101
x = np.arange(n)
plt.plot(x, [desiredTemp]*n)
line, = ax.plot(x, tuning[p,i,d])
ttl = ax.text(.5, 1.05, 'P=1\tI=0\tD=0', transform = ax.transAxes, va='center')

def init():
    ax.set_xlim(0, 101)
    ax.set_ylim(0, 30)
    return line,

def animate(it):
    global p,i,d
    d+=1
    if d==D:
        d=0
        i+=1
        if i==I:
            i=0
            p+=1
            ##shouldn't have to check this
    ttl.set_text("P=%2.1f I=%2.1f D=%2.1f " % ((p+10)/10,i/10,d/10))
    line.set_ydata(tuning[p,i,d])  # update the data
    
    return line,

anim = animation.FuncAnimation(fig, animate, np.arange(P*I*D), init_func=init, blit=True)

plt.show()
#display(HTML(anim.to_html5_video()))

