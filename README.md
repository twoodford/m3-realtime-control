# m3-realtime-control
Real-time FPGA-based phased array controller for M3

This FPGA code is designed to be loaded onto a CmodA7 FPGA module.  For further information about the hardware designs, see [m3.ucsd.edu](m3.ucsd.edu).

For now, we are only distributing a bit file for the FPGA.  The full source code is coming soon, once we determine our licensing.

## PC Control Interface

The CmodA7 device is powered and controlled over a USB serial connection.  The ``pa_ctl`` Matlab function is a sample of how we can access this control interface using a Matlab serial connection object.  The interface is simple enough that this interface may be easily implemented in other languages as well.

