`timescale 1ns / 1ps
//================================================================
//                          Sys On Chip
//
//  Curso de programación en lenguaje Verilog
//  Ejercicio No. 2 - Semáforo con FSM formal
//  Tarjeta de desarrollo: Nexys A7 (Artix-7)
//
//  Descripción técnica:
//  ---------------------------------------------------------------
//  Este diseño implementa un semáforo utilizando una
//  Máquina de Estados Finitos (FSM) tipo Moore.
//
//  A diferencia del ejercicio 1, aquí el comportamiento
//  se modela explícitamente mediante:
//
//      1) Registro de estado actual
//      2) Lógica de transición
//      3) Lógica de salida
//
//  Cada estado tiene su propio tiempo de permanencia,
//  controlado por un contador que se reinicia al cambiar
//  de estado.
//
//  Secuencia temporal:
//      VERDE    -> 5 segundos
//      AMARILLO -> 1 segundo
//      ROJO     -> 5 segundos
//================================================================

module semaforo_fsm(

    input  wire reloj,          // Reloj principal de 100 MHz
    input  wire reset,          // Reset síncrono activo en alto
    output reg  led_verde,      // LED verde
    output reg  led_amarillo,   // LED amarillo
    output reg  led_rojo        // LED rojo
);

    //============================================================
    // 1. Parámetros de temporización
    //============================================================

    // Frecuencia base del sistema
    parameter FRECUENCIA_RELOJ = 100_000_000;

    // Duración de cada estado en segundos
    parameter TIEMPO_VERDE    = 5;
    parameter TIEMPO_AMARILLO = 1;
    parameter TIEMPO_ROJO     = 5;

    // Conversión a ciclos de reloj
    parameter CICLOS_VERDE    = FRECUENCIA_RELOJ * TIEMPO_VERDE;
    parameter CICLOS_AMARILLO = FRECUENCIA_RELOJ * TIEMPO_AMARILLO;
    parameter CICLOS_ROJO     = FRECUENCIA_RELOJ * TIEMPO_ROJO;

    //============================================================
    // 2. Registros internos
    //============================================================

    // Contador de tiempo por estado
    // 32 bits permiten contar hasta más de 4 mil millones
    reg [31:0] contador_tiempo;

    // Codificación de estados (2 bits son suficientes para 3 estados)
    localparam ESTADO_VERDE    = 2'b00;
    localparam ESTADO_AMARILLO = 2'b01;
    localparam ESTADO_ROJO     = 2'b10;

    // Registro del estado actual
    reg [1:0] estado_actual;

    // Registro del estado siguiente (salida de la lógica combinacional)
    reg [1:0] estado_siguiente;

    //============================================================
    // 3. BLOQUE SECUENCIAL
    //============================================================
    // Se ejecuta en cada flanco positivo del reloj.
    // Aquí se almacenan:
    //  - El estado actual
    //  - El contador
    //============================================================

    always @(posedge reloj) begin

        if (reset) begin
            // Inicialización síncrona del sistema
            estado_actual   <= ESTADO_VERDE;
            contador_tiempo <= 0;
        end
        else begin
            // Actualización del estado
            estado_actual <= estado_siguiente;

            // Si hay cambio de estado, reiniciamos el contador
            if (estado_actual != estado_siguiente)
                contador_tiempo <= 0;
            else
                contador_tiempo <= contador_tiempo + 1;
        end
    end

    //============================================================
    // 4. LÓGICA DE TRANSICIÓN DE ESTADOS (COMBINACIONAL)
    //============================================================
    // Define cuándo se pasa de un estado a otro.
    // No almacena información, solo calcula estado_siguiente.
    //============================================================

    always @(*) begin

        // Por defecto, permanecer en el mismo estado
        estado_siguiente = estado_actual;

        case (estado_actual)

            //----------------------------------------------------
            // Estado VERDE
            //----------------------------------------------------
            ESTADO_VERDE:
                if (contador_tiempo >= CICLOS_VERDE)
                    estado_siguiente = ESTADO_AMARILLO;

            //----------------------------------------------------
            // Estado AMARILLO
            //----------------------------------------------------
            ESTADO_AMARILLO:
                if (contador_tiempo >= CICLOS_AMARILLO)
                    estado_siguiente = ESTADO_ROJO;

            //----------------------------------------------------
            // Estado ROJO
            //----------------------------------------------------
            ESTADO_ROJO:
                if (contador_tiempo >= CICLOS_ROJO)
                    estado_siguiente = ESTADO_VERDE;

            //----------------------------------------------------
            // Protección ante estados inválidos
            //----------------------------------------------------
            default:
                estado_siguiente = ESTADO_VERDE;

        endcase
    end

    //============================================================
    // 5. LÓGICA DE SALIDA (FSM tipo Moore)
    //============================================================
    // En una máquina de Moore, las salidas dependen
    // exclusivamente del estado actual.
    //============================================================

    always @(*) begin

        // Valores por defecto (evita inferencia de latches)
        led_verde    = 0;
        led_amarillo = 0;
        led_rojo     = 0;

        case (estado_actual)
            ESTADO_VERDE:    led_verde    = 1;
            ESTADO_AMARILLO: led_amarillo = 1;
            ESTADO_ROJO:     led_rojo     = 1;
        endcase

    end

endmodule
