<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The inputs of the device are the outputs of an analog processing and we therefore have 7 signals per channel representing the amplitude of the emission at the frequency associated with the channel. This data is encoded and upon detection of a signal, memorization is triggered. It lasts 200 us and once it is finished the state machine controls it and sends the recorded data. To manage recording and sending simultaneously, we use the double buffer technique. We write in one part of the memory and read the data recorded in the other. This data is sent serially for each channel. An RTC module allows you to retrieve the time of appearance of the pulse. In fact it is recorded in a register when a input signal is detected and this is the firt data to be sent.

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
