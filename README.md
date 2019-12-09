# m3-realtime-control
Real-time FPGA-based phased array controller for M3

This FPGA code is designed to be loaded onto a CmodA7 FPGA module.  For further information about the hardware designs, see [m3.ucsd.edu](m3.ucsd.edu).

For now, we are only distributing a bit file for the FPGA.  The full source code is coming soon, once we determine our licensing.

## PC Control Interface

The CmodA7 device is powered and controlled over a USB serial connection.  The ``pa_ctl`` Matlab function is a sample of how we can access this control interface using a Matlab serial connection object.  The interface is simple enough that this interface may be easily implemented in other languages as well.

## CmodA7 Code

The ``CmodA7_ctrl_top.bit`` is built with Vivado 2018.2, and can be used to program the CmodA7 device using the free WebPack version of Vivado.  The ``CmodA7_ctrl_top.bin`` file can be used to persistently program the FPGA using the on-board configuration memory.  See [Digilent's instructions](https://reference.digilentinc.com/learn/programmable-logic/tutorials/cmod-a7-programming-guide/start#programming_the_cmod_a7_using_quad_spi) for more details.
