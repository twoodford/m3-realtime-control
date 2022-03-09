# m3-realtime-control
Real-time FPGA-based phased array controller for M3

This FPGA code is designed to be loaded onto a CmodA7 FPGA module.  For further information about the hardware designs, see [m3.ucsd.edu](http://m3.ucsd.edu).

The code here is available under the modified BSD license in ``LICENSE.txt``.  Note that the software in this repository is not licensed for commercial use.  See the license file for more information on using this software commercially.

## PC Control Interface

The CmodA7 device is powered and controlled over a USB serial connection.  The ``pa_ctl`` Matlab function is a sample of how we can access this control interface using a Matlab serial connection object.  The interface is simple enough that this interface may be easily implemented in other languages as well.

**Important Instructions for Linux**: If you see a "no ports available" message from Matlab, you may not have the correct permissions to access the USB serial device.  On many Linux distributions, including Ubuntu, you can grant yourself access by adding yourself to the `dialout` group, eg. using the command `sudo gpasswd -a your_username_here dialout`.  On other distributions, check the output of `ls -l /dev/ttyUSB*` to find out which group has access to these serial devices.

## CmodA7 Code

The ``CmodA7_ctrl_top.bit`` is built with Vivado 2018.2, and can be used to program the CmodA7 device using the free WebPack version of Vivado.  The ``CmodA7_ctrl_top.bin`` file can be used to persistently program the FPGA using the on-board configuration memory.  See [Digilent's instructions](https://reference.digilentinc.com/learn/programmable-logic/tutorials/cmod-a7-programming-guide/start#programming_the_cmod_a7_using_quad_spi) for more details.

Note that newer CmodA7 models come with a mx25l3233f-spi-x1_x2_x4 memory device, at odds with the instructions referenced above.  If you see an error when attempting to program the device, try removing the default memory configuration device, and adding this device.  Note that Vivado 2019.1 is known not to correctly program these devices, so you should use Vivado 2018.2 instead.
