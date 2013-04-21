// Example Verilator main program in C++

// Copyright (C) 2013  Embecosm Limited <info@embecosm.com>

// Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

// This file is one of the examples for the ChipHack workshop

// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or (at your
// option) any later version.

// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
// License for more details.

// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


#include "Vbasics.h"
#include "verilated.h"
#if VM_TRACE
# include <verilated_vcd_c.h>	// Trace file format header
#endif

#include <iostream>


int main (int   argc,
	  char *argv[],
	  char *env[])
{
  Verilated::commandArgs (argc, argv);
  Vbasics *top = new Vbasics;

  int  clk;
  int  led;
  int  old_led;
  int  key;
  int  reset;
  int  button;

  vluint64_t main_time = 0;	// Current simulation time (64-bit unsigned)

  clk = 0;
  reset = 1;
  button = 1;
  key = (button << 1) | reset;
  old_led = led - 1;

#if VM_TRACE
  // Set if called with --trace
  Verilated::traceEverOn(true);
  VerilatedVcdC *tracer = new VerilatedVcdC;
  top->trace (tracer, 99);
  tracer->open ("basics_dump.vcd");
#endif

  do
    {
      top->KEY = key;
      top->CLOCK_50 = clk;

      top->eval ();
#if VM_TRACE
      tracer->dump (main_time);
#endif

      led = top->LED;
      if (led != old_led)
	{
	  std::cout << "led = " << std::hex << led << std::endl;
	  old_led = led;
	}

      clk = 1 - clk;			// Advance the clock
      main_time += 1;			// One "time unit" per clock edge.
    }
  while (led != 0xfc);

  top->final();

#if VM_TRACE
  tracer->close ();
#endif

}
