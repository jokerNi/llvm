//===-- HexagonRegisterInfo.td - Hexagon Register defs -----*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//  Declarations that describe the Hexagon register file.
//===----------------------------------------------------------------------===//

let Namespace = "Hexagon" in {

  class HexagonReg<bits<5> num, string n> : Register<n> {
    field bits<5> Num;
    let HWEncoding{4-0} = num;
  }

  class HexagonDoubleReg<bits<5> num, string n, list<Register> subregs> :
        RegisterWithSubRegs<n, subregs> {
    field bits<5> Num;
    let HWEncoding{4-0} = num;
  }

  // Registers are identified with 5-bit ID numbers.
  // Ri - 32-bit integer registers.
  class Ri<bits<5> num, string n> : HexagonReg<num, n> {
    let Num = num;
  }

  // Rf - 32-bit floating-point registers.
  class Rf<bits<5> num, string n> : HexagonReg<num, n> {
    let Num = num;
  }


  // Rd - 64-bit registers.
  class Rd<bits<5> num, string n, list<Register> subregs> :
        HexagonDoubleReg<num, n, subregs> {
    let Num = num;
    let SubRegs = subregs;
  }

  // Rp - predicate registers
  class Rp<bits<5> num, string n> : HexagonReg<num, n> {
    let Num = num;
  }

  // Rc - control registers
  class Rc<bits<5> num, string n> : HexagonReg<num, n> {
    let Num = num;
  }

  // Rj - aliased integer registers
  class Rj<string n, Ri R>: HexagonReg<R.Num, n> {
    let Num = R.Num;
    let Aliases = [R];
  }

  def subreg_loreg  : SubRegIndex<32>;
  def subreg_hireg  : SubRegIndex<32, 32>;

  // Integer registers.
  foreach I = 0-31 in {
    def R#I  : Ri<I, "r"#I>,  DwarfRegNum<[I]>;
  }

  def SP : Rj<"sp", R29>, DwarfRegNum<[29]>;
  def FP : Rj<"fp", R30>, DwarfRegNum<[30]>;
  def LR : Rj<"lr", R31>, DwarfRegNum<[31]>;

  // Aliases of the R* registers used to hold 64-bit int values (doubles).
  let SubRegIndices = [subreg_loreg, subreg_hireg], CoveredBySubRegs = 1 in {
  def D0  : Rd< 0,  "r1:0",  [R0,  R1]>, DwarfRegNum<[32]>;
  def D1  : Rd< 2,  "r3:2",  [R2,  R3]>, DwarfRegNum<[34]>;
  def D2  : Rd< 4,  "r5:4",  [R4,  R5]>, DwarfRegNum<[36]>;
  def D3  : Rd< 6,  "r7:6",  [R6,  R7]>, DwarfRegNum<[38]>;
  def D4  : Rd< 8,  "r9:8",  [R8,  R9]>, DwarfRegNum<[40]>;
  def D5  : Rd<10, "r11:10", [R10, R11]>, DwarfRegNum<[42]>;
  def D6  : Rd<12, "r13:12", [R12, R13]>, DwarfRegNum<[44]>;
  def D7  : Rd<14, "r15:14", [R14, R15]>, DwarfRegNum<[46]>;
  def D8  : Rd<16, "r17:16", [R16, R17]>, DwarfRegNum<[48]>;
  def D9  : Rd<18, "r19:18", [R18, R19]>, DwarfRegNum<[50]>;
  def D10 : Rd<20, "r21:20", [R20, R21]>, DwarfRegNum<[52]>;
  def D11 : Rd<22, "r23:22", [R22, R23]>, DwarfRegNum<[54]>;
  def D12 : Rd<24, "r25:24", [R24, R25]>, DwarfRegNum<[56]>;
  def D13 : Rd<26, "r27:26", [R26, R27]>, DwarfRegNum<[58]>;
  def D14 : Rd<28, "r29:28", [R28, R29]>, DwarfRegNum<[60]>;
  def D15 : Rd<30, "r31:30", [R30, R31]>, DwarfRegNum<[62]>;
  }

  // Predicate registers.
  def P0 : Rp<0, "p0">, DwarfRegNum<[63]>;
  def P1 : Rp<1, "p1">, DwarfRegNum<[64]>;
  def P2 : Rp<2, "p2">, DwarfRegNum<[65]>;
  def P3 : Rp<3, "p3">, DwarfRegNum<[66]>;

  // Fake register to represent USR.OVF bit. Artihmetic/saturating instruc-
  // tions modify this bit, and multiple such instructions are allowed in the
  // same packet. We need to ignore output dependencies on this bit, but not
  // on the entire USR.
  def USR_OVF : Rc<?, "usr.ovf">;

  // Control registers.
  def SA0 : Rc<0, "sa0">, DwarfRegNum<[67]>;
  def LC0 : Rc<1, "lc0">, DwarfRegNum<[68]>;

  def SA1 : Rc<2, "sa1">, DwarfRegNum<[69]>;
  def LC1 : Rc<3, "lc1">, DwarfRegNum<[70]>;

  def M0 : Rc<6, "m0">, DwarfRegNum<[71]>;
  def M1 : Rc<7, "m1">, DwarfRegNum<[72]>;

  def PC : Rc<9,  "pc">, DwarfRegNum<[32]>; // is the Dwarf number correct?
  def GP : Rc<11, "gp">, DwarfRegNum<[33]>; // is the Dwarf number correct?
}

// Register classes.
//
// FIXME: the register order should be defined in terms of the preferred
// allocation order...
//
def IntRegs : RegisterClass<"Hexagon", [i32,f32], 32,
                            (add (sequence "R%u", 0, 9),
                                 (sequence "R%u", 12, 28),
                                 R10, R11, R29, R30, R31)> {
}

def DoubleRegs : RegisterClass<"Hexagon", [i64,f64], 64,
                               (add (sequence "D%u", 0, 4),
                                    (sequence "D%u", 6, 13), D5, D14, D15)>;


def PredRegs : RegisterClass<"Hexagon", [i1], 32, (add (sequence "P%u", 0, 3))>
{
  let Size = 32;
}

def CRRegs : RegisterClass<"Hexagon", [i32], 32,
                           (add (sequence "LC%u", 0, 1),
                                (sequence "SA%u", 0, 1),
                                (sequence "M%u", 0, 1), PC, GP)> {
  let Size = 32;
}

def VolatileV3 {
  list<Register> Regs = [D0, D1, D2, D3, D4, D5, D6, D7,
                         R28, R31,
                         P0, P1, P2, P3,
                         M0, M1,
                         LC0, LC1, SA0, SA1, USR_OVF];
}

def PositiveHalfWord : PatLeaf<(i32 IntRegs:$a),
[{
  return isPositiveHalfWord(N);
}]>;
