/*
	spectrum.js: Spectrum architecture implementation for JSSpeccy, a ZX Spectrum emulator in Javascript
	
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

var memory = [];
var canvas;
var ctx;
var imageData;
var imageDataData;
var keyStates = [];
var imageDataShadow = []; /* clone of imageDataData; - used to skip writing pixels to canvas if there's no change */

var hasImageData;
var needDrawImage = (navigator.userAgent.indexOf('Firefox/2') != -1);

var logo = [
	0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x68,0x68,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x70,0x00,0x00,0x60,0x60,0x00,0x68,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x68,0x68,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x70,0x00,0x60,0x00,0x00,0x00,0x00,0x68,0x00,0x00,0x58,0x58,0x00,0x00,0x70,0x00,0x70,0x00,0x00,0x60,0x60,0x00,0x68,0x00,0x00,0x00,0x58,0x00,0x58,0x00,
	0x00,0x00,0x70,0x00,0x00,0x60,0x00,0x00,0x00,0x00,0x68,0x00,0x58,0x00,0x58,0x00,0x70,0x70,0x70,0x00,0x60,0x00,0x00,0x00,0x68,0x00,0x00,0x00,0x58,0x00,0x58,0x00,
	0x70,0x00,0x70,0x00,0x00,0x00,0x60,0x00,0x68,0x00,0x68,0x00,0x58,0x00,0x58,0x00,0x70,0x00,0x00,0x00,0x60,0x00,0x00,0x00,0x68,0x00,0x00,0x00,0x58,0x00,0x58,0x00,
	0x00,0x70,0x00,0x00,0x60,0x00,0x60,0x00,0x00,0x68,0x00,0x00,0x58,0x58,0x00,0x00,0x00,0x70,0x70,0x00,0x60,0x00,0x00,0x00,0x00,0x68,0x68,0x00,0x00,0x58,0x58,0x00,
	0x00,0x00,0x00,0x00,0x00,0x60,0x00,0x00,0x00,0x00,0x00,0x00,0x58,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x60,0x60,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x58,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x58,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x58,0x58,0x00,0x00
];

function spectrum_init() {
	for (var i = 0x0000; i < 0x4000; i++) {
		memory[i] = roms['48.rom'].charCodeAt(i);
	}
	for (var i = 0x4000; i < 0x10000; i++) {
		memory[i] = 0;
	}
	canvas = document.getElementById('screen');
	ctx = canvas.getContext('2d');
	ctx.fillStyle = 'black';
	ctx.fillRect(0,0,256,192); /* set alpha to opaque */
	if (ctx.getImageData) {
		hasImageData = true;
		imageData = ctx.getImageData(0,0,256,192);
		imageDataData = imageData.data;
	} else {
		/* this browser does not support getImageData / putImageData;
			use horribly slow fillRect method to plot pixels instead */
		hasImageData = false;
		drawScreenByte = drawScreenByteWithoutImageData;
		drawAttrByte = drawAttrByteWithoutImageData;
	}
	
	for (i = 0; i < 256; i++) {
		memory[0x5900 + i] = logo[i];
	}
	paintFullScreen();
	paintScreen();
	
	document.onkeydown = keyDown;
	document.onkeyup = keyUp;
	document.onkeypress = keyPress;
	for (var row = 0; row < 8; row++) {
		keyStates[row] = 0xff;
	}
	
	canvas.onmousedown = joystickKeyDown;
	canvas.onmouseup = joystickKeyUp;
	document.ontouchstart = joystickTouchStart;
	document.ontouchend = joystickTouchEnd;
}

var keyCodes = {
	49: {row: 3, mask: 0x01}, /* 1 */
	50: {row: 3, mask: 0x02}, /* 2 */
	51: {row: 3, mask: 0x04}, /* 3 */
	52: {row: 3, mask: 0x08}, /* 4 */
	53: {row: 3, mask: 0x10}, /* 5 */
	54: {row: 4, mask: 0x10}, /* 6 */
	55: {row: 4, mask: 0x08}, /* 7 */
	56: {row: 4, mask: 0x04}, /* 8 */
	57: {row: 4, mask: 0x02}, /* 9 */
	48: {row: 4, mask: 0x01}, /* 0 */

	81: {row: 2, mask: 0x01}, /* Q */
	87: {row: 2, mask: 0x02}, /* W */
	69: {row: 2, mask: 0x04}, /* E */
	82: {row: 2, mask: 0x08}, /* R */
	84: {row: 2, mask: 0x10}, /* T */
	89: {row: 5, mask: 0x10}, /* Y */
	85: {row: 5, mask: 0x08}, /* U */
	73: {row: 5, mask: 0x04}, /* I */
	79: {row: 5, mask: 0x02}, /* O */
	80: {row: 5, mask: 0x01}, /* P */

	65: {row: 1, mask: 0x01}, /* A */
	83: {row: 1, mask: 0x02}, /* S */
	68: {row: 1, mask: 0x04}, /* D */
	70: {row: 1, mask: 0x08}, /* F */
	71: {row: 1, mask: 0x10}, /* G */
	72: {row: 6, mask: 0x10}, /* H */
	74: {row: 6, mask: 0x08}, /* J */
	75: {row: 6, mask: 0x04}, /* K */
	76: {row: 6, mask: 0x02}, /* L */
	13: {row: 6, mask: 0x01}, /* enter */

	16: {row: 0, mask: 0x01}, /* caps */
	192: {row: 0, mask: 0x01}, /* backtick as caps - because firefox screws up a load of key codes when pressing shift */
	90: {row: 0, mask: 0x02}, /* Z */
	88: {row: 0, mask: 0x04}, /* X */
	67: {row: 0, mask: 0x08}, /* C */
	86: {row: 0, mask: 0x10}, /* V */
	66: {row: 7, mask: 0x10}, /* B */
	78: {row: 7, mask: 0x08}, /* N */
	77: {row: 7, mask: 0x04}, /* M */
	17: {row: 7, mask: 0x02}, /* sym - gah, firefox screws up ctrl+key too */
	32: {row: 7, mask: 0x01}, /* space */
};

var palette = [
	[0,0,0],
	[0,0,192],
	[192,0,0],
	[192,0,192],
	[0,192,0],
	[0,192,192],
	[192,192,0],
	[192,192,192],
	[0,0,0],
	[0,0,255],
	[255,0,0],
	[255,0,255],
	[0,255,0],
	[0,255,255],
	[255,255,0],
	[255,255,255]
];

function keyDown(evt) {
	registerKeyDown(evt.keyCode)
	if (!evt.metaKey) return false;
}
function registerKeyDown(keyNum) {
	var keyCode = keyCodes[keyNum];
	if (keyCode == null) return;
	keyStates[keyCode.row] &= ~(keyCode.mask);
}
function keyUp(evt) {
	registerKeyUp(evt.keyCode);
	if (!evt.metaKey) return false;
}
function registerKeyUp(keyNum) {
	var keyCode = keyCodes[keyNum];
	if (keyCode == null) return;
	keyStates[keyCode.row] |= keyCode.mask;
}
function keyPress(evt) {
	if (!evt.metaKey) return false;
}

function locateJoystickKeyFromCanvas(evt) {
	var selectId;
	if (evt.layerX < 160) {
		selectId = 'select_key_left';
	} else if (evt.layerX > 480) {
		selectId = 'select_key_right';
	} else if (evt.layerY < 256) {
		selectId = 'select_key_up';
	} else {
		selectId = 'select_key_down';
	}
	var select = document.getElementById(selectId);
	var opt = select.options[select.selectedIndex];
	return opt.value;
}
function locateJoystickKeyFromScreen(evt) {
	var selectId;
	if (evt.screenX < screen.width / 4) {
		selectId = 'select_key_left';
	} else if (evt.screenX > screen.width * 3/4) {
		selectId = 'select_key_right';
	} else if (evt.screenY < screen.height / 2) {
		selectId = 'select_key_up';
	} else {
		selectId = 'select_key_down';
	}
	var select = document.getElementById(selectId);
	var opt = select.options[select.selectedIndex];
	return opt.value;
}
function joystickKeyDown(evt) {
	registerKeyDown(locateJoystickKeyFromCanvas(evt));
}
function joystickKeyUp(evt) {
	registerKeyUp(locateJoystickKeyFromCanvas(evt));
}
function joystickTouchStart(evt) {
	for (var i = 0; i < evt.changedTouches.length; i++) {
		registerKeyDown(locateJoystickKeyFromScreen(evt.changedTouches[i]));
	}
}
function joystickTouchEnd(evt) {
	for (var i = 0; i < evt.changedTouches.length; i++) {
		registerKeyUp(locateJoystickKeyFromScreen(evt.changedTouches[i]));
	}
}

function contend_memory(addr) {
	return 0; /* TODO: implement */
}
function contend_port(addr) {
	return 0; /* TODO: implement */
}
function readbyte(addr) {
	return readbyte_internal(addr);
}
function readbyte_internal(addr) {
	return memory[addr];
}
function readport(addr) {
	if ((addr & 0x0001) == 0x0000) {
		/* read keyboard */
		var result = 0xff;
		for (var row = 0; row < 8; row++) {
			if (!(addr & (1 << (row+8)))) { /* bit held low, so scan this row */
				result &= keyStates[row];
			}
		}
		return result;
	} else if ((addr & 0x00e0) == 0x0000) {
		/* kempston joystick: treat this as attached but unused
		 (for the benefit of Manic Miner) */
		return 0x00;
	} else {
		return 0xff; /* unassigned port */
	}
}
function writeport(addr, val) {
	if ((addr & 0x0001) == 0) {
		var borderColour = palette[val & 0x07];
		var borderColourCss = 'rgb('+borderColour[0]+','+borderColour[1]+','+borderColour[2]+')';
		canvas.style.borderColor = borderColourCss;
	}
}
function writebyte(addr, val) {
	return writebyte_internal(addr, val)
}
function writebyte_internal(addr, val) {
	if (addr < 0x4000) return;
	if (addr < 0x5800) {
		var oldByte = memory[addr];
		memory[addr] = val;
		if (val != oldByte) drawScreenByte(addr, val);
	} else if (addr < 0x5b00) {
		var oldByte = memory[addr];
		memory[addr] = val;
		if (val != oldByte) drawAttrByte(addr, val);
	} else {
		memory[addr] = val;
	}
}
function drawScreenByteWithoutImageData(addr, val) {
	/* 0 1 0 y7 y6 y2 y1 y0 / y5 y4 y3 x4 x3 x2 x1 x0 */
	var x = (addr & 0x001f); /* counted in characters */
	var y = ((addr & 0x0700) >> 8) | ((addr & 0x00e0) >> 2) | ((addr & 0x1800) >> 5); /* counted in pixels */
	var attributeByte = memory[0x5800 | ((y & 0xf8) << 2) | x];
	if ((attributeByte & 0x80) && (flashFrame & 0x10)) {
		/* invert flashing attributes */
		var ink = palette[(attributeByte & 0x78) >> 3];
		var paper = palette[((attributeByte & 0x40) >> 3) | (attributeByte & 0x07)];
	} else {
		var ink = palette[((attributeByte & 0x40) >> 3) | (attributeByte & 0x07)];
		var paper = palette[(attributeByte & 0x78) >> 3];
	}
	var inkRgb = 'rgb(' + ink[0] + ',' + ink[1] + ',' + ink[2] + ')';
	var paperRgb = 'rgb(' + paper[0] + ',' + paper[1] + ',' + paper[2] + ')';
	var xp = x << 3;
	var pixelAddress = (y << 10) | (x << 5);
	for (var bit = 0x80; bit != 0; bit >>= 1) {
		if (val & bit) {
			ctx.fillStyle = inkRgb;
			ctx.fillRect(xp, y, 1, 1);
			xp++;
		} else {
			ctx.fillStyle = paperRgb;
			ctx.fillRect(xp, y, 1, 1);
			xp++;
		}
	}
}

function drawScreenByte(addr, val) {
	/* 0 1 0 y7 y6 y2 y1 y0 / y5 y4 y3 x4 x3 x2 x1 x0 */
	var x = (addr & 0x001f); /* counted in characters */
	var y = ((addr & 0x0700) >> 8) | ((addr & 0x00e0) >> 2) | ((addr & 0x1800) >> 5); /* counted in pixels */
	var attributeByte = memory[0x5800 | ((y & 0xf8) << 2) | x];
	if ((attributeByte & 0x80) && (flashFrame & 0x10)) {
		/* invert flashing attributes */
		var ink = palette[(attributeByte & 0x78) >> 3];
		var paper = palette[((attributeByte & 0x40) >> 3) | (attributeByte & 0x07)];
	} else {
		var ink = palette[((attributeByte & 0x40) >> 3) | (attributeByte & 0x07)];
		var paper = palette[(attributeByte & 0x78) >> 3];
	}
	var pixelAddress = (y << 10) | (x << 5);
	for (var bit = 0x80; bit != 0; bit >>= 1) {
		if (val & bit) {
			if (imageDataShadow[pixelAddress] != ink[0]) {
				imageDataData[pixelAddress] = ink[0];
				imageDataShadow[pixelAddress] = ink[0];
			}
			pixelAddress++;
			if (imageDataShadow[pixelAddress] != ink[1]) {
				imageDataData[pixelAddress] = ink[1];
				imageDataShadow[pixelAddress] = ink[1];
			}
			pixelAddress++;
			if (imageDataShadow[pixelAddress] != ink[2]) {
				imageDataData[pixelAddress] = ink[2];
				imageDataShadow[pixelAddress] = ink[2];
			}
			pixelAddress += 2;
		} else {
			if (imageDataShadow[pixelAddress] != paper[0]) {
				imageDataData[pixelAddress] = paper[0];
				imageDataShadow[pixelAddress] = paper[0];
			}
			pixelAddress++;
			if (imageDataShadow[pixelAddress] != paper[1]) {
				imageDataData[pixelAddress] = paper[1];
				imageDataShadow[pixelAddress] = paper[1];
			}
			pixelAddress++;
			if (imageDataShadow[pixelAddress] != paper[2]) {
				imageDataData[pixelAddress] = paper[2];
				imageDataShadow[pixelAddress] = paper[2];
			}
			pixelAddress += 2;
		}
	}
}

function drawAttrByteWithoutImageData(addr, val) {
	/* 0 1 0 1 1 0 y4 y3 / y2 y1 y0 x4 x3 x2 x1 x0 */
	var x0 = (addr & 0x001f); /* counted in characters */
	var y0 = (addr & 0x03e0) >> 2; /* counted in pixels */
	if ((val & 0x80) && (flashFrame & 0x10)) {
		/* invert flashing attributes */
		var ink = palette[(val & 0x78) >> 3];
		var paper = palette[((val & 0x40) >> 3) | (val & 0x07)];
	} else {
		var ink = palette[((val & 0x40) >> 3) | (val & 0x07)];
		var paper = palette[(val & 0x78) >> 3];
	}
	
	var inkRgb = 'rgb(' + ink[0] + ',' + ink[1] + ',' + ink[2] + ')';
	var paperRgb = 'rgb(' + paper[0] + ',' + paper[1] + ',' + paper[2] + ')';

	for (var y = 0; y < 8; y++) {
		var screenByte = memory[0x4000 | ((y0 & 0xc0) << 5) | (y << 8) | ((y0 & 0x38) << 2) | x0];
		var xp = x0 << 3;
		for (var bit = 0x80; bit != 0; bit >>= 1) {
			if (screenByte & bit) {
				ctx.fillStyle = inkRgb;
				ctx.fillRect(xp, y | y0, 1, 1);
				xp++;
			} else {
				ctx.fillStyle = paperRgb;
				ctx.fillRect(xp, y | y0, 1, 1);
				xp++;
			}
		}
	}
}

function drawAttrByte(addr, val) {
	/* 0 1 0 1 1 0 y4 y3 / y2 y1 y0 x4 x3 x2 x1 x0 */
	var x0 = (addr & 0x001f); /* counted in characters */
	var y0 = (addr & 0x03e0) >> 2; /* counted in pixels */
	if ((val & 0x80) && (flashFrame & 0x10)) {
		/* invert flashing attributes */
		var ink = palette[(val & 0x78) >> 3];
		var paper = palette[((val & 0x40) >> 3) | (val & 0x07)];
	} else {
		var ink = palette[((val & 0x40) >> 3) | (val & 0x07)];
		var paper = palette[(val & 0x78) >> 3];
	}
	
	for (var y = 0; y < 8; y++) {
		var pixelAddress = ((y0 | y) << 10) | (x0 << 5);
		var screenByte = memory[0x4000 | ((y0 & 0xc0) << 5) | (y << 8) | ((y0 & 0x38) << 2) | x0];
		for (var bit = 0x80; bit != 0; bit >>= 1) {
			if (screenByte & bit) {
				if (imageDataShadow[pixelAddress] != ink[0]) {
					imageDataData[pixelAddress] = ink[0];
					imageDataShadow[pixelAddress] = ink[0];
				}
				pixelAddress++;
				if (imageDataShadow[pixelAddress] != ink[1]) {
					imageDataData[pixelAddress] = ink[1];
					imageDataShadow[pixelAddress] = ink[1];
				}
				pixelAddress++;
				if (imageDataShadow[pixelAddress] != ink[2]) {
					imageDataData[pixelAddress] = ink[2];
					imageDataShadow[pixelAddress] = ink[2];
				}
				pixelAddress += 2;
			} else {
				if (imageDataShadow[pixelAddress] != paper[0]) {
					imageDataData[pixelAddress] = paper[0];
					imageDataShadow[pixelAddress] = paper[0];
				}
				pixelAddress++;
				if (imageDataShadow[pixelAddress] != paper[1]) {
					imageDataData[pixelAddress] = paper[1];
					imageDataShadow[pixelAddress] = paper[1];
				}
				pixelAddress++;
				if (imageDataShadow[pixelAddress] != paper[2]) {
					imageDataData[pixelAddress] = paper[2];
					imageDataShadow[pixelAddress] = paper[2];
				}
				pixelAddress += 2;
			}
		}
	}
}

function paintScreen() {
	if ((flashFrame & 0x0f) == 0) {
		/* need to redraw flashing attributes on this frame */
		for (var addr = 0x5800; addr < 0x5b00; addr++) {
			if (memory[addr] & 0x80) {
				drawAttrByte(addr, memory[addr]);
			}
		}
	}
	if (hasImageData) {
		ctx.putImageData(imageData, 0, 0);
		if (needDrawImage) ctx.drawImage(canvas, 0, 0); /* FF2 appears to need this */
	}
}

function paintFullScreen() {
	/* force repaint of whole screen */
	var pixelAddress = 0; /* offset into imageData */
	var rowAttributeAddress = 0x5800;
	for (var third = 0x4000; third < 0x5800; third += 0x0800) {
		var charRowMax = third + 0x0100;
		for (var charRow = third; charRow < charRowMax; charRow += 0x20) {
			var pixRowMax = charRow + 0x0800;
			for (var pixRow = charRow; pixRow < pixRowMax; pixRow += 0x0100) {
				var charColMax = pixRow + 0x20;
				var attributeAddress = rowAttributeAddress;
				for (var charCol = pixRow; charCol < charColMax; charCol++) {
					var attributeByte = memory[attributeAddress];
					attributeAddress++;
					
					if ((attributeByte & 0x80) && (flashFrame & 0x10)) {
						/* invert flashing attributes */
						var ink = palette[(attributeByte & 0x78) >> 3];
						var paper = palette[((attributeByte & 0x40) >> 3) | (attributeByte & 0x07)];
					} else {
						var ink = palette[((attributeByte & 0x40) >> 3) | (attributeByte & 0x07)];
						var paper = palette[(attributeByte & 0x78) >> 3];
					}
					
					screenByte = memory[charCol];
					
					for (var bit = 0x80; bit != 0; bit >>= 1) {
						if (screenByte & bit) {
							imageDataShadow[pixelAddress] = ink[0];
							imageDataData[pixelAddress++] = ink[0];
							imageDataShadow[pixelAddress] = ink[1];
							imageDataData[pixelAddress++] = ink[1];
							imageDataShadow[pixelAddress] = ink[2];
							imageDataData[pixelAddress++] = ink[2];
							pixelAddress++;
						} else {
							imageDataShadow[pixelAddress] = paper[0];
							imageDataData[pixelAddress++] = paper[0];
							imageDataShadow[pixelAddress] = paper[1];
							imageDataData[pixelAddress++] = paper[1];
							imageDataShadow[pixelAddress] = paper[2];
							imageDataData[pixelAddress++] = paper[2];
							pixelAddress++;
						}
					}
				}
			}
			rowAttributeAddress += 0x20;
		}
	}
//	for (var addr = 0x5800; addr < 0x5b00; addr++) {
//		drawAttrByte(addr, memory[addr]);
//	}
	
}
