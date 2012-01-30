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
all: z80 roms.js snapshots.js

.PHONY: z80
z80:
	$(MAKE) -C z80

roms.js: bin2js.pl roms/*
	perl bin2js.pl roms > roms.js

snapshots.js: bin2js.pl snapshots/*
	perl bin2js.pl snapshots > snapshots.js

.PHONY: clean
clean:
	$(MAKE) -C z80 clean
	rm -f roms.js snapshots.js
