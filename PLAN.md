# Plan de Desarrollo — Mini Microprocesador en FPGA
**Curso:** Diseño Digital VLSI — UNAM  
**Tarjeta:** Intel DE10-Lite (MAX 10, `10M50DAF484C7G`, 50 MHz)  
**Herramienta:** Quartus Prime Lite  
**Repositorio:** https://github.com/MagaliL/Microprocesador  

---

## Estado actual del proyecto

| Semana | Tema | Estado |
|--------|------|--------|
| 1 | Definición de arquitectura | ⬜ Pendiente |
| 2 | Implementación de ALU | ⬜ Pendiente |
| 3 | Diseño de FSM | ⬜ Pendiente |
| 4 | Integración | ⬜ Pendiente |
| 5 | Periféricos | ⬜ Pendiente |
| 6 | Validación final | ⬜ Pendiente |

> **Instrucción de sesión:** Al iniciar una nueva sesión, actualizar esta tabla y retomar desde la primera semana marcada como `🔄 En progreso` o `⬜ Pendiente`.

---

## Arquitectura del sistema

### Tipo
Microprocesador tipo **acumulador** — todas las operaciones pasan por el registro ACC.

### Parámetros fijos
| Parámetro | Valor |
|-----------|-------|
| Ancho de datos | 8 bits |
| Ancho de dirección | 8 bits |
| Ancho de instrucción | 16 bits |
| Reloj | 50 MHz (`MAX10_CLK1_50`) |
| Reset | Activo-bajo → `KEY[1]` (PIN_A7) |

### Formato de instrucción (16 bits)
```
[ OPCODE (4 bits) | OPERANDO/ADDR (8 bits) | padding (4 bits) ]
  bits 15-12          bits 11-4               bits 3-0
```

### ISA obligatoria (8 instrucciones)
| OPCODE | Mnemónico | Operación |
|--------|-----------|-----------|
| 0000 | LDA addr | ACC ← MEM[addr] |
| 0001 | STA addr | MEM[addr] ← ACC |
| 0010 | ADD addr | ACC ← ACC + MEM[addr] |
| 0011 | SUB addr | ACC ← ACC − MEM[addr] |
| 0100 | AND addr | ACC ← ACC & MEM[addr] |
| 0101 | OR  addr | ACC ← ACC \| MEM[addr] |
| 0110 | JMP addr | PC ← addr |
| 0111 | JZ  addr | Si ACC = 0x00 → PC ← addr |

### Periféricos por memoria mapeada
| Dirección | Periférico | Señal DE10-Lite |
|-----------|-----------|-----------------|
| 0xF0 | LEDs (escritura) | `LEDR[7:0]` |
| 0xF1 | Switches (lectura) | `SW[7:0]` |
| 0xF2 | Display 7-seg (escritura) | `HEX0[6:0]` |

---

## Bloques del sistema y archivos VHDL

```
Codigo/
├── MIcroprocesador.qpf         ← proyecto Quartus (ya existe)
├── MIcroprocesador.qsf         ← pin assignments (ya existe)
├── PLAN.md                     ← este documento
└── src/
    ├── microprocesador_top.vhd ← top-level (Structural)
    ├── program_counter.vhd     ← PC: registro 8-bit con load/inc
    ├── rom_programa.vhd        ← ROM 256×16 con programa de prueba
    ├── ram_datos.vhd           ← RAM 256×8 con memoria mapeada
    ├── alu.vhd                 ← ALU: ADD, SUB, AND, OR + flag zero
    ├── control_fsm.vhd         ← FSM: Fetch→Decode→Execute→Writeback
    └── sevenseg_decoder.vhd    ← decodificador BCD→7seg (reusar P6)
```

### Descripción de cada bloque

#### `microprocesador_top.vhd`
- Arquitectura `Structural`
- Puertos: `MAX10_CLK1_50`, `KEY[1]` (rst_n), `SW[7:0]`, `LEDR[7:0]`, `HEX0[6:0]`
- Instancia todos los demás módulos con prefijo `U_`
- Conecta bus de datos (8 bits), bus de dirección (8 bits) y señales de control

#### `program_counter.vhd`
- Registro 8-bit sincrónico, reset activo-bajo
- Señales de control: `pc_inc` (PC+1), `pc_load` (carga dirección)
- Modelo de referencia: similar a `stepper_seq_28byj` (registro con control de incremento/carga)

#### `rom_programa.vhd`
- Array `(0 to 255) of std_logic_vector(15 downto 0)`
- Inicializada con un programa de prueba (suma, mostrar en LEDs)
- Combinacional (sin clock) — similar a `msg_bank_p2` y `melodia_navidad`

#### `ram_datos.vhd`
- Array `(0 to 255) of std_logic_vector(7 downto 0)`
- Lectura combinacional, escritura sincrónica
- Lógica de memoria mapeada: si `addr >= 0xF0` → redireccionar a periférico
- Modelo de referencia: similar a `reg10x6` (P2) y `archivo_registros` (P4)

#### `alu.vhd`
- Combinacional pura
- Entradas: `op_a[7:0]`, `op_b[7:0]`, `alu_op[2:0]`
- Salidas: `result[7:0]`, `zero_flag`
- Operaciones: ADD(000), SUB(001), AND(010), OR(011), pass-A(100)
- Modelo de referencia: similar a `decodificador_7seg` (lógica combinacional con case)

#### `control_fsm.vhd`
- FSM de 4 estados: `FETCH`, `DECODE`, `EXECUTE`, `WRITEBACK`
- Reset activo-bajo, sincrónico al clock de 50 MHz
- Genera todas las señales de control del datapath
- Modelo de referencia: misma estructura que `ultrasonic_core` (P6) y `RX` (P8)

#### `sevenseg_decoder.vhd`
- **Reusar directamente** de `practica-6/practica-6-docs/sevenseg_decoder.vhd`
- BCD 4-bit → 7 segmentos activo-bajo
- Conectado a HEX0 para mostrar valor de ACC o dato de periférico 0xF2

---

## Semana 1 — Definición de arquitectura

**Objetivo:** Tener todos los archivos VHDL creados con sus entidades, puertos y señales definidos (sin lógica interna todavía). El proyecto debe compilar sin errores de síntesis estructural.

### Tareas
- [ ] Crear carpeta `src/` dentro de `Codigo/`
- [ ] Escribir `microprocesador_top.vhd` — entidad + arquitectura Structural vacía con todas las señales internas declaradas
- [ ] Escribir `program_counter.vhd` — entidad completa + lógica de incremento/carga
- [ ] Escribir `rom_programa.vhd` — entidad + ROM inicializada con programa mínimo de prueba
- [ ] Escribir `ram_datos.vhd` — entidad + lógica de lectura/escritura + stub de memoria mapeada
- [ ] Escribir `alu.vhd` — entidad completa (la lógica va en Semana 2)
- [ ] Escribir `control_fsm.vhd` — entidad completa (la FSM va en Semana 3)
- [ ] Copiar `sevenseg_decoder.vhd` de practica-6
- [ ] Agregar todos los `.vhd` al proyecto Quartus (`.qsf`)
- [ ] Verificar que Analysis & Synthesis pase sin errores
- [ ] Commit al repositorio

### Convenciones a seguir (basadas en prácticas)
```vhdl
-- Top-level (igual que practica5_top, Top_RGB_5)
architecture Structural of microprocesador_top is
begin
    U_PC  : entity work.program_counter  port map(...);
    U_ROM : entity work.rom_programa     port map(...);
    U_RAM : entity work.ram_datos        port map(...);
    U_ALU : entity work.alu              port map(...);
    U_FSM : entity work.control_fsm      port map(...);
    U_HEX : entity work.sevenseg_decoder port map(...);
end architecture Structural;
```

---

## Semana 2 — Implementación de ALU

**Objetivo:** ALU completamente funcional con las 4 operaciones + flag zero.

### Tareas
- [ ] Implementar lógica interna de `alu.vhd` (case en alu_op)
- [ ] Conectar correctamente al datapath en `microprocesador_top.vhd`
- [ ] Programa de prueba en ROM que ejercite ADD y SUB
- [ ] Verificar síntesis limpia
- [ ] Commit al repositorio

---

## Semana 3 — Diseño de FSM

**Objetivo:** Ciclo Fetch→Decode→Execute→Writeback funcional para todas las instrucciones ISA.

### Tareas
- [ ] Implementar los 4 estados en `control_fsm.vhd`
- [ ] Definir todas las señales de control generadas por la FSM
- [ ] Implementar decodificación de OPCODE → señales de control
- [ ] Implementar lógica de salto (JMP, JZ) vía `pc_load` + `zero_flag`
- [ ] Verificar síntesis limpia
- [ ] Commit al repositorio

### Señales de control de la FSM
| Señal | Descripción |
|-------|-------------|
| `pc_inc` | Incrementa PC en 1 |
| `pc_load` | Carga dirección en PC (JMP/JZ) |
| `acc_we` | Escribe resultado en ACC |
| `ram_we` | Escribe en RAM (STA) |
| `ir_load` | Carga instrucción en registro IR |
| `alu_op[2:0]` | Selección de operación ALU |
| `mux_alu_src` | Fuente del operando B de ALU (RAM o inmediato) |

---

## Semana 4 — Integración

**Objetivo:** Sistema completo funcionando: ejecuta programas almacenados en ROM.

### Tareas
- [ ] Conectar todos los módulos en `microprocesador_top.vhd`
- [ ] Cargar programa de prueba completo en `rom_programa.vhd`
- [ ] Verificar que LDA, STA, ADD, SUB, AND, OR, JMP, JZ funcionen
- [ ] Probar en hardware con programa de suma simple: resultado visible en `LEDR`
- [ ] Commit al repositorio

### Programa de prueba sugerido (ensamblador → ROM)
```
LDA 0x00   ; ACC = MEM[0x00]  (valor inicial)
ADD 0x01   ; ACC = ACC + MEM[0x01]
STA 0xF0   ; LEDR = ACC  (mostrar en LEDs)
JMP 0x00   ; loop infinito
```

---

## Semana 5 — Periféricos

**Objetivo:** Memoria mapeada funcional: LEDs, Switches y display 7-seg responden a instrucciones STA/LDA.

### Tareas
- [ ] Implementar lógica de memoria mapeada en `ram_datos.vhd`
  - Escritura a 0xF0 → registro de salida a `LEDR[7:0]`
  - Lectura de 0xF1 → retorna `SW[7:0]`
  - Escritura a 0xF2 → registro de salida a `sevenseg_decoder` → `HEX0`
- [ ] Conectar puertos de periféricos en `microprocesador_top.vhd`
- [ ] Programa de prueba que lea switches y muestre en LEDs
- [ ] Commit al repositorio

### Programa de prueba periféricos
```
LDA 0xF1   ; ACC = SW[7:0]
STA 0xF0   ; LEDR = ACC
STA 0xF2   ; HEX0 = ACC (nibble bajo)
JMP 0x00   ; loop
```

---

## Semana 6 — Validación final

**Objetivo:** Sistema listo para evaluación presencial.

### Tareas
- [ ] Probar con programa proporcionado por el profesor (formato libre)
- [ ] Practicar agregar nueva instrucción (modificar `alu.vhd`, `control_fsm.vhd`, OPCODE en ISA)
- [ ] Grabar video demo (≤5 min) mostrando:
  - Programa ejecutándose en la FPGA
  - LEDs y display respondiendo
  - Explicación de cada bloque
- [ ] Escribir reporte con: arquitectura, FSM, ALU, resultados, limitaciones
- [ ] Commit final con todo el código y reporte
- [ ] Verificar que el repositorio esté público y organizado

---

## Rúbrica (recordatorio)

| Criterio | Pts |
|----------|-----|
| Arquitectura y diseño | 30 |
| Funcionalidad | 40 |
| Evaluación en laboratorio | 40 |
| **Total base** | **110** |
| Extra: instrucciones adicionales | +10 |
| Extra: múltiples registros (RISC) | +10 |

---

## Referencia rápida — Patrones de código (prácticas anteriores)

### Instanciación de componentes
```vhdl
U_ALU : entity work.alu
    port map(
        op_a     => acc_out,
        op_b     => ram_dout,
        alu_op   => alu_op_s,
        result   => alu_result,
        zero_flag => zero_flag_s
    );
```

### FSM sincrónica con reset activo-bajo (patrón P5, P6, P8)
```vhdl
process(clk, rst_n)
begin
    if rst_n = '0' then
        state <= FETCH;
    elsif rising_edge(clk) then
        state <= next_state;
    end if;
end process;
```

### ROM combinacional (patrón msg_bank_p2, melodia_navidad)
```vhdl
type rom_t is array (0 to 255) of std_logic_vector(15 downto 0);
constant ROM : rom_t := (
    0  => x"0000",  -- LDA 0x00
    1  => x"20_01",  -- ADD 0x01
    ...
    others => x"0000"
);
dout <= ROM(to_integer(unsigned(addr)));
```

### RAM con escritura sincrónica (patrón reg10x6)
```vhdl
process(clk)
begin
    if rising_edge(clk) then
        if we = '1' then
            mem(to_integer(unsigned(addr))) <= din;
        end if;
    end if;
end process;
dout <= mem(to_integer(unsigned(addr)));
```

---

## Pin assignments clave (DE10-Lite)

| Señal VHDL | Pin | Descripción |
|------------|-----|-------------|
| `MAX10_CLK1_50` | PIN_P11 | Reloj 50 MHz |
| `KEY[1]` / `rst_n` | PIN_A7 | Reset activo-bajo |
| `KEY[0]` | PIN_B8 | (libre para uso futuro) |
| `SW[0..7]` | banco SW | Periférico 0xF1 |
| `LEDR[0..7]` | banco LED | Periférico 0xF0 |
| `HEX0[0..6]` | banco HEX | Periférico 0xF2 |
