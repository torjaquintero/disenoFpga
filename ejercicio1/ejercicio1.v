`timescale 1ns / 1ps
//================================================================
//                          Sys On Chip
//
//  Curso de programación en lenguaje Verilog
//  Ejercicio No. 1 - Semáforo básico sin máquina de estados
//  Tarjeta de desarrollo: Nexys A7
//
//  Descripción técnica:
//  ---------------------------------------------------------------
//  Este módulo implementa un semáforo utilizando únicamente
//  un contador síncrono que se incrementa con el reloj de 100 MHz
//  de la tarjeta.
//
//  La temporización se obtiene contando ciclos de reloj:
//
//      - Rojo   : 2 segundos
//      - Verde  : 3 segundos
//      - Ámbar  : 1 segundo
//
//  Duración total del ciclo: 6 segundos.
//
//  No se emplean máquinas de estado (FSM).
//  La selección del color activo se realiza mediante una
//  estructura case basada en el valor del contador.
//================================================================

module semaforo (

    input  wire clk,     // Reloj principal de 100 MHz de la Nexys A7
    output reg  rojo,    // Salida para LED rojo
    output reg  ambar,   // Salida para LED ámbar
    output reg  verde    // Salida para LED verde
);

    //============================================================
    // 1. Parámetros de temporización
    //============================================================

    // Frecuencia del reloj de la tarjeta (100 MHz)
    parameter FRECUENCIA_RELOJ = 100_000_000;

    // Duración de cada estado en segundos
    parameter TIEMPO_ROJO   = 2;
    parameter TIEMPO_VERDE  = 3;
    parameter TIEMPO_AMBAR  = 1;

    // Conversión de segundos a ciclos de reloj
    parameter CICLOS_ROJO  = FRECUENCIA_RELOJ * TIEMPO_ROJO;
    parameter CICLOS_VERDE = FRECUENCIA_RELOJ * TIEMPO_VERDE;
    parameter CICLOS_AMBAR = FRECUENCIA_RELOJ * TIEMPO_AMBAR;

    // Duración total del ciclo
    parameter CICLO_TOTAL = CICLOS_ROJO + CICLOS_VERDE + CICLOS_AMBAR;

    //============================================================
    // 2. Contador principal
    //============================================================

    // 30 bits permiten contar hasta 1,073,741,823
    // Es suficiente para cubrir los 600,000,000 ciclos requeridos.
    reg [29:0] contador_tiempo = 0;

    //============================================================
    // 3. Lógica secuencial
    //============================================================

    always @(posedge clk) begin

        //--------------------------------------------------------
        // 3.1 Incremento del contador
        //--------------------------------------------------------
        if (contador_tiempo >= CICLO_TOTAL) begin
            contador_tiempo <= 0;   // Reinicia el ciclo completo
        end else begin
            contador_tiempo <= contador_tiempo + 1;
        end

        //--------------------------------------------------------
        // 3.2 Control de los LEDs mediante estructura case
        //--------------------------------------------------------
        // Solo se modifican las salidas cuando el contador
        // alcanza los puntos de cambio de estado.
        //--------------------------------------------------------

        case (contador_tiempo)

            // Inicio del ciclo -> LED rojo activo
            0: begin
                rojo  <= 1;
                verde <= 0;
                ambar <= 0;
            end

            // Cambio a verde después de 2 segundos
            CICLOS_ROJO: begin
                rojo  <= 0;
                verde <= 1;
                ambar <= 0;
            end

            // Cambio a ámbar después de 5 segundos (2+3)
            (CICLOS_ROJO + CICLOS_VERDE): begin
                rojo  <= 0;
                verde <= 0;
                ambar <= 1;
            end

        endcase
    end

endmodule
