class ab20 {
	private static function fr(str, find, replace, limit) {
		var tempString = str, tempParts, pos, loopLength;
		if (typeof (find) !== "string") {
			if (replace === undefined) {
				replace = [""];
			} else if (typeof (replace) === "string") {
				replace = [replace];
			}
		} else {
			find = [find];
			replace = [replace];
		}
		var loopLength = find.length;
		for (var a = 0, c = 0; a<loopLength; a++, c=0) {
			while ((pos=tempString.indexOf(find[a])) !== -1) {
				if (limit !== undefined && c>=limit) {
					break;
				}
				tempParts = new Array(tempString.substring(0, pos), tempString.substr(pos, find[a].length), tempString.substr(pos+find[a].length));
				tempParts[1] = (replace[a] === undefined) ? ("") : replace[a];
				tempString = tempParts[0]+tempParts[1]+tempParts[2];
				c++;
			}
		}
		return tempString;
	}
	public static function encodeNum(num) {
		var sttrtime = getTimer();
		var r11 = ["aZ", "Zy", "Zx"];
		var r12 = ["zH", "jY", "uH"];
		var r13 = ["Ah", "Xh", "hO"];
		var r14 = ["Ub", "Bu", "Cb"];
		var r15 = ["Qc", "Pc", "Pe"];
		var r16 = ["Ei", "Ie", "Ef"];
		var r17 = ["Fk", "kG", "Kg"];
		var r18 = ["Jl", "Lm", "Mn"];
		var r19 = ["No", "Np", "Qp"];
		var r20 = ["Rs", "St", "Sw"];
		var murminator = random(3);
		num = String(num);
		num = fr(num, "9", r11[random(3)], 1);
		num = fr(num, "9", r11[random(3)], 1);
		num = fr(num, "9", r11[random(3)], 1);
		num = fr(num, "9", r11[random(3)], 1);
		num = fr(num, "9", r11[random(3)], 1);
		num = fr(num, "9", r11[random(3)], 1);
		num = fr(num, "8", r12[random(3)], 1);
		num = fr(num, "8", r12[random(3)], 1);
		num = fr(num, "8", r12[random(3)], 1);
		num = fr(num, "8", r12[random(3)], 1);
		num = fr(num, "8", r12[random(3)], 1);
		num = fr(num, "7", r13[random(3)], 1);
		num = fr(num, "7", r13[random(3)], 1);
		num = fr(num, "7", r13[random(3)], 1);
		num = fr(num, "7", r13[random(3)], 1);
		num = fr(num, "7", r13[random(3)], 1);
		num = fr(num, "7", r13[random(3)], 1);
		num = fr(num, "7", r13[random(3)], 1);
		num = fr(num, "7", r13[random(3)], 1);
		num = fr(num, "6", r14[random(3)], 1);
		num = fr(num, "6", r14[random(3)], 1);
		num = fr(num, "6", r14[random(3)], 1);
		num = fr(num, "6", r14[random(3)], 1);
		num = fr(num, "6", r14[random(3)], 1);
		num = fr(num, "6", r14[random(3)], 1);
		if (murminator == 1) {
			num = fr(num, "5", r15[0]);
		} else {
			num = fr(num, "5", r15[random(3)]);
		}
		num = fr(num, "4", r16[random(3)]);
		num = fr(num, "3", r17[random(3)], 1);
		num = fr(num, "3", r17[random(3)], 1);
		num = fr(num, "3", r17[random(3)], 1);
		num = fr(num, "3", r17[random(3)], 1);
		num = fr(num, "3", r17[random(3)], 1);
		num = fr(num, "3", r17[random(3)], 1);
		num = fr(num, "3", r17[random(3)], 1);
		num = fr(num, "3", r17[random(3)], 1);
		num = fr(num, "2", r18[random(3)]);
		num = fr(num, "1", r19[random(3)]);
		num = fr(num, "0", r20[random(3)], 1);
		num = fr(num, "0", r20[random(3)], 1);
		num = fr(num, "0", r20[random(3)], 1);
		num = fr(num, "0", r20[random(3)], 1);
		num = fr(num, "0", r20[random(3)], 1);
		num = fr(num, "0", r20[random(3)], 1);
		num = fr(num, "0", r20[random(3)], 1);
		num = fr(num, "0", r20[random(3)], 1);
		num = fr(num, "0", r20[random(3)], 1);
		var sttrtime2 = getTimer()-sttrtime;
		num = num+"Dd"+sttrtime2;
		return (num);
	}
	public static function encodeStr8bytes(str) {
		var strL = 0;
		var strM = str.length;
		var output = "%";
		var puts = ["%", "$", "#", "@"];
		while (strL<strM) {
			output += str.charCodeAt(strL)+puts[random(puts.length)];
			strL++;
		}
		return (output);
	}
	public static function decodeStr8bytes(str) {
		str = "PIE"+str+"PIE";
		str = fr(str, "%", "D");
		str = fr(str, "$", "D");
		str = fr(str, "#", "D");
		str = fr(str, "@", "D");
		str = fr(str, "PIED", "");
		str = fr(str, "DPIE", "");
		var str_ar = str.split("D");
		var newstr = "";
		var strL = 0;
		var strM = str_ar.length;
		while (strL<strM) {
			newstr += String(String.fromCharCode(str_ar[strL]));
			strL++;
		}
		return (newstr);
	}
	public static function decodeNum(str) {
		var r11 = ["aZ", "Zy", "Zx", "zH", "jY", "uH", "Ah", "Xh", "hO", "Ub", "Bu", "Cb", "Qc", "Pc", "Pe", "Ei", "Ie", "Ef", "Fk", "kG", "Kg", "Jl", "Lm", "Mn", "No", "Np", "Qp", "Rs", "St", "Sw"];
		str = String(str);
		str = str.split("Dd");
		str = str[0];
		str = fr(str, r11[0], "9");
		str = fr(str, r11[1], "9");
		str = fr(str, r11[2], "9");
		str = fr(str, r11[3], "8");
		str = fr(str, r11[4], "8");
		str = fr(str, r11[5], "8");
		str = fr(str, r11[6], "7");
		str = fr(str, r11[7], "7");
		str = fr(str, r11[8], "7");
		str = fr(str, r11[9], "6");
		str = fr(str, r11[10], "6");
		str = fr(str, r11[11], "6");
		str = fr(str, r11[12], "5");
		str = fr(str, r11[13], "5");
		str = fr(str, r11[14], "5");
		str = fr(str, r11[15], "4");
		str = fr(str, r11[16], "4");
		str = fr(str, r11[17], "4");
		str = fr(str, r11[18], "3");
		str = fr(str, r11[19], "3");
		str = fr(str, r11[20], "3");
		str = fr(str, r11[21], "2");
		str = fr(str, r11[22], "2");
		str = fr(str, r11[23], "2");
		str = fr(str, r11[24], "1");
		str = fr(str, r11[25], "1");
		str = fr(str, r11[26], "1");
		str = fr(str, r11[27], "0");
		str = fr(str, r11[28], "0");
		str = fr(str, r11[29], "0");
		var num = Number(str);
		return (num);
	}
}
