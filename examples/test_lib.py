from lib3d_mec_ginac import *
import sys

try:
    set_gravity_direction('up')
    theta, dtheta, ddtheta = new_coord('theta', -3.14159/6, 0)
    l1 = new_param('l1', 0.4)
    print("Coordinates and parameters defined successfully!")
    print("theta =", theta)
    print("l1 =", l1)
    print("l1*theta =", l1*theta)   
    print("diff(l1*theta, theta) =",diff(l1*theta, theta))
    print("diff(l1*theta^2, theta) =",diff(l1*theta*theta, theta))
    print("Verification completed successfully!")
except Exception as e:
    print("Error during library verification:", e)
    sys.exit(1)
