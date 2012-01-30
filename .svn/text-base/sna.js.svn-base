/*
	sna.js: Snapshot file handling for JSSpeccy, a ZX Spectrum emulator in Javascript
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

function loadSna(sna) {
	var registers = [
		'i', 'l_', 'h_', 'e_', 'd_', 'c_', 'b_', 'f_', 'a_',
		'l', 'h', 'e', 'd', 'c', 'b',
		'iyl', 'iyh', 'ixl', 'ixh'];
	for (var i = 0; i < registers.length; i++) {
		z80[registers[i]] = sna.charCodeAt(i);
	}
	z80.iff1 = z80.iff2 = (sna.charCodeAt(19) & 0x04) ? 1 : 0;
	var r = sna.charCodeAt(20);
	z80.r = r & 0x7f;
	z80.r7 = r & 0x80;
	z80.f = sna.charCodeAt(21);
	z80.a = sna.charCodeAt(22);
	z80.sp = sna.charCodeAt(23) | (sna.charCodeAt(24) << 8);
	z80.im = sna.charCodeAt(25);
	writeport(0xfe, sna.charCodeAt(26) & 0x07);
	for (var i = 0; i < 0xc000; i++) {
		memory[i + 0x4000] = sna.charCodeAt(i + 27);
	}
	paintFullScreen();
	/* simulate a retn to populate pc correctly */
	var lowbyte =readbyte_internal(z80.sp++);
	z80.sp &= 0xffff;
	var highbyte=readbyte_internal(z80.sp++);
	z80.sp &= 0xffff;
	z80.pc = lowbyte | (highbyte << 8);
}
