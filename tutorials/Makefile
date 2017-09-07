# Make file for ChipHack slides

# Copyright (C) 2017 Embecosm Limited <www.embecosm.com>

# Contributor: Jeremy Bennett <jeremy.bennett@embecosm.com>

# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.

# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http:#www.gnu.org/licenses/>.

DIRS = mystorm-setup         \
       basic-verilog         \
       combinatorial-verilog \
       sequential-verilog    \
       uart                  \
       edsac-peripherals     \
       hatim-edsac

.PHONY: all
all:
	for d in ${DIRS} ;                   \
	do                                   \
	    cd $$d ;                         \
	    make SPHINXOPTS=-Wn slides ;     \
	    make html ;                      \
            cd .. ;                          \
	done

.PHONY: clean
clean:
	for d in ${DIRS} ;                   \
	do                                   \
	    cd $$d ;                         \
	    make clean  ;                    \
            cd .. ;                          \
	done
