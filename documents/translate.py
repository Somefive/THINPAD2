import re


def convert(sub_code, op, pos):
    if len(sub_code) == 3:
        if pos == 3:
            if op == "SRA" or op == "SLL":
                return str(hex(int(sub_code, 2)))+"/"+str(int(sub_code, 2))
        if sub_code == "000":
            return "R0"
        if sub_code == "001":
            return "R1"
        if sub_code == "010":
            return "R2"
        if sub_code == "011":
            return "R3"
        if sub_code == "100":
            return "R4"
        if sub_code == "101":
            return "R5"
        if sub_code == "110":
            return "R6"
        if sub_code == "111":
            return "R7"
    return str(hex(int(sub_code, 2)))+"/"+str(int(sub_code, 2))

regs = {
    "ADDIU":    re.compile('01001([01]{3})([01]{8})'),
    "ADDIU3":   re.compile('01000([01]{3})([01]{3})0([01]{4})'),
    "ADDSP":    re.compile('01100011([01]{8})'),
    "ADDU":     re.compile('11100([01]{3})([01]{3})([01]{3})01'),
    "AND":      re.compile('11101([01]{3})([01]{3})01100'),
    "B":        re.compile('00010([01]{11})'),
    "BEQZ":     re.compile('00100([01]{3})([01]{8})'),
    "BNEZ":     re.compile('00101([01]{3})([01]{8})'),
    "BTEQZ":    re.compile('01100000([01]{8})'),
    "CMP":      re.compile('11101([01]{3})([01]{3})01010'),
    "JR":       re.compile('11101([01]{3})00000000'),
    "LI":       re.compile('01101([01]{3})([01]{8})'),
    "LW":       re.compile('10011([01]{3})([01]{3})([01]{5})'),
    "LW_SP":    re.compile('10010([01]{3})([01]{8})'),
    "MFIH":     re.compile('11110([01]{3})00000000'),
    "MFPC":     re.compile('11101([01]{3})01000000'),
    "MTIH":     re.compile('11110([01]{3})00000001'),
    "MTSP":     re.compile('01100100([01]{3})00000'),
    "NOP":      re.compile('0000100000000000'),
    "OR":       re.compile('11101([01]{3})([01]{3})01101'),
    "SLL":      re.compile('00110([01]{3})([01]{3})([01]{3})00'),
    "SRA":      re.compile('00110([01]{3})([01]{3})([01]{3})11'),
    "SUBU":     re.compile('11100([01]{3})([01]{3})([01]{3})11'),
    "SW":       re.compile('11011([01]{3})([01]{3})([01]{5})'),
    "SW_SP":    re.compile('11010([01]{3})([01]{8})'),
    "MOVE":     re.compile('01111([01]{3})([01]{3})00000'),
    "SLLV":     re.compile('11101([01]{3})([01]{3})00100'),
    "ADDSP3":   re.compile('00000([01]{3})([01]{8})'),
    "CMPI":     re.compile('01110([01]{3})([01]{8})'),
    "NEG":      re.compile('11101([01]{3})([01]{3})01011'),
}

code = input("Enter the bit string:")

while code != "":
    flag = False
    print(str(hex(int(code, 2)))+"/"+str(int(code, 2)))
    for op in regs.keys():
        match = regs[op].match(code)
        if match:
            out = op
            for i in range(1, len(match.groups())+1):
                out += " "
                out += convert(match.group(i), op, i)
            print(out)
            flag = True
            break
    if not flag:
        print("Error Code!")
    code = input("Enter the bit string:")
