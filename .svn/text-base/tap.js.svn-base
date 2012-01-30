/*
	tap.js: Tape file handling for JSSpeccy, a ZX Spectrum emulator in Javascript
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	Contact details: <matthew@west.co.tt>
	Matthew Westcott, 14 Daisy Hill Drive, Adlington, Chorley, Lancs PR6 9NE UNITED KINGDOM
*/

var tapeBlocks = [];
var nextTapeBlockIndex = 0;

function loadTap(tap) {
	var nextByte = 0;
	while (nextByte < tap.length) {
		var lowByte = tap.charCodeAt(nextByte++);
		var highByte = tap.charCodeAt(nextByte++);
		var blockLength = lowByte | (highByte << 8);
		tapeBlocks.push(tap.slice(nextByte, nextByte + blockLength));
		nextByte += blockLength;
	}
}

function loadTapeBlock() {
	var tapeBlock = tapeBlocks[nextTapeBlockIndex];
	nextTapeBlockIndex = (nextTapeBlockIndex + 1) % tapeBlocks.length;
	
	if (z80.f_ & 0x01) {
		/* carry set => LOAD */
		if (z80.a_ == tapeBlock.charCodeAt(0)) {
			blockLength = (z80.d << 8) | z80.e;
			address = (z80.ixh << 8) | z80.ixl;
			for (i = 0; i < Math.min(blockLength, tapeBlock.length - 1); i++) {
				if (address >= 0x4000) {
					memory[address] = tapeBlock.charCodeAt(i + 1);
				}
				address = (address + 1) & 0xffff;
			}
			paintFullScreen();
			if (blockLength > tapeBlock.length - 1) {
				/* block ended prematurely; signal tape loading error */
				z80.f &= 0xfe;	/* reset carry flag */
			} else {
				z80.f |= 0x01;	/* reset carry flag */
			}
		} else {
			/* flag byte does not match - signal tape loading error */
			z80.f &= 0xfe;	/* reset carry flag */
		}
	} else {
		/* carry reset => VERIFY */
		z80.f |= 0x01; /* just return success. TODO: implement VERIFY properly... */
	}
	z80.pc = 0x05e2; /* address at which to exit tape trap */
}
