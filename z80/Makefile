# JSSpeccy: A ZX Spectrum emulator in Javascript
# Copyright (C) 2008 Matthew Westcott

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Contact details: <matthew@west.co.tt>
# Matthew Westcott, 14 Daisy Hill Drive, Adlington, Chorley, Lancs PR6 9NE UNITED KINGDOM

.PHONY: all
all: z80_ops_full.js z80_full.js

z80_ops_full.js: z80_ops.jscpp z80_macros.jscpp opcodes_base.jscpp z80_cb.jscpp z80_ddfd.jscpp z80_ddfdcb.jscpp z80_ed.jscpp
	cpp -P z80_ops.jscpp z80_ops_full.js

z80_full.js: z80.jscpp z80_macros.jscpp opcodes_base.jscpp z80_cb.jscpp z80_ddfd.jscpp z80_ddfdcb.jscpp z80_ed.jscpp
	cpp -P z80.jscpp z80_full.js

opcodes_base.jscpp: z80.pl opcodes_base.dat
	perl z80.pl opcodes_base.dat > opcodes_base.jscpp

z80_cb.jscpp: z80.pl opcodes_cb.dat
	perl z80.pl opcodes_cb.dat > z80_cb.jscpp

z80_ddfd.jscpp: z80.pl opcodes_ddfd.dat
	perl z80.pl opcodes_ddfd.dat > z80_ddfd.jscpp

z80_ddfdcb.jscpp: z80.pl opcodes_ddfd.dat
	perl z80.pl opcodes_ddfdcb.dat > z80_ddfdcb.jscpp

z80_ed.jscpp: z80.pl opcodes_ed.dat
	perl z80.pl opcodes_ed.dat > z80_ed.jscpp

.PHONY: clean
clean:
	rm -f z80_ops_full.js z80_full.js opcodes_base.jscpp z80_cb.jscpp z80_ddfd.jscpp z80_ddfdcb.jscpp z80_ed.jscpp
