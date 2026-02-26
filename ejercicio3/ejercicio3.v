`timescale 1ns / 1ps
//================================================================
//                          Sys On Chip
//
//  Curso de programación en lenguaje Verilog
//  Ejercicio No. 3 - Semáforo FSM con botón sincronizado
//  Tarjeta de desarrollo: Nexys A7 (Artix-7)
//
//  Descripción técnica:
//  ---------------------------------------------------------------
//  Este diseño amplía la FSM del ejercicio anterior agregando
//  una entrada externa (botón).
//
//  Se implementan tres bloques fundamentales para señales
//  asíncronas:
//
//    1) Sincronizador doble flip-flop
//    2) Detector de flanco
//    3) FSM tipo Moore con prioridad por evento externo
//
//  El botón permite forzar la transición anticipada desde
//  VERDE hacia AMARILLO.
//
//  Se mantiene la temporización automática si no se presiona
//  el botón.
//================================================================

module semaforo_boton(

    input  wire reloj,          // Reloj principal 100 MHz
    input  wire reset,          // Reset síncrono activo en alto
    input  wire boton,          // Entrada asíncrona (pulsador físico)
    output reg  led_verde,
    output reg  led_amarillo,
    output reg  led_rojo
);

    //============================================================
    // 1. SINCRONIZADOR DE ENTRADA (Protección contra metastabilidad)
    //============================================================
    // El botón es una señal asíncrona respecto al reloj.
    // Se utilizan dos flip-flops en cascada para sincronizarla.
    //============================================================

    reg boton_sync_0;
    reg boton_sync_1;

    always @(posedge reloj) begin
        boton_sync_0 <= boton;
        boton_sync_1 <= boton_sync_0;
    end

    wire boton_sincronizado = boton_sync_1;

    //============================================================
    // 2. DETECTOR DE FLANCO ASCENDENTE
    //============================================================
    // Permite generar un pulso de un ciclo de reloj cuando
    // el botón pasa de 0 a 1.
    //============================================================

    reg boton_anterior;

    always @(posedge reloj)
        boton_anterior <= boton_sincronizado;

    wire flanco_boton = boton_sincronizado & ~boton_anterior;

    //============================================================
    // 3. PARÁMETROS DE TEMPORIZACIÓN
    //============================================================

    parameter FRECUENCIA_RELOJ = 100_000_000;

    parameter TIEMPO_VERDE    = 5;
    parameter TIEMPO_AMARILLO = 1;
    parameter TIEMPO_ROJO     = 5;

    parameter CICLOS_VERDE    = FRECUENCIA_RELOJ * TIEMPO_VERDE;
    parameter CICLOS_AMARILLO = FRECUENCIA_RELOJ * TIEMPO_AMARILLO;
    parameter CICLOS_ROJO     = FRECUENCIA_RELOJ * TIEMPO_ROJO;

    //============================================================
    // 4. REGISTROS INTERNOS
    //============================================================

    reg [31:0] contador_tiempo;

    localparam ESTADO_VERDE    = 2'b00;
    localparam ESTADO_AMARILLO = 2'b01;
    localparam ESTADO_ROJO     = 2'b10;

    reg [1:0] estado_actual;
    reg [1:0] estado_siguiente;

    //============================================================
    // 5. REGISTRO DE ESTADO (LÓGICA SECUENCIAL)
    //============================================================

    always @(posedge reloj) begin
        if (reset)
            estado_actual <= ESTADO_VERDE;
        else
            estado_actual <= estado_siguiente;
    end

    //============================================================
    // 6. CONTADOR CON RESET POR TRANSICIÓN
    //============================================================
    // El contador mide el tiempo dentro de cada estado.
    // Se reinicia automáticamente cuando ocurre un cambio
    // de estado.
    //============================================================

    always @(posedge reloj) begin
        if (reset)
            contador_tiempo <= 0;
        else if (estado_actual != estado_siguiente)
            contador_tiempo <= 0;
        else
            contador_tiempo <= contador_tiempo + 1;
    end

    //============================================================
    // 7. LÓGICA DE TRANSICIÓN (COMBINACIONAL)
    //============================================================
    // El botón tiene prioridad en el estado VERDE.
    //============================================================

    always @(*) begin

        estado_siguiente = estado_actual;

        case (estado_actual)

            //----------------------------------------------------
            // ESTADO VERDE
            //----------------------------------------------------
            ESTADO_VERDE:
                if (flanco_boton)
                    estado_siguiente = ESTADO_AMARILLO;
                else if (contador_tiempo >= CICLOS_VERDE)
                    estado_siguiente = ESTADO_AMARILLO;

            //----------------------------------------------------
            // ESTADO AMARILLO
            //----------------------------------------------------
            ESTADO_AMARILLO:
                if (contador_tiempo >= CICLOS_AMARILLO)
                    estado_siguiente = ESTADO_ROJO;

            //----------------------------------------------------
            // ESTADO ROJO
            //----------------------------------------------------
            ESTADO_ROJO:
                if (contador_tiempo >= CICLOS_ROJO)
                    estado_siguiente = ESTADO_VERDE;

            default:
                estado_siguiente = ESTADO_VERDE;

        endcase
    end

    //============================================================
    // 8. LÓGICA DE SALIDA (FSM tipo Moore)
    //============================================================
    // Las salidas dependen exclusivamente del estado actual.
    //============================================================

    always @(*) begin
        led_verde    = (estado_actual == ESTADO_VERDE);
        led_amarillo = (estado_actual == ESTADO_AMARILLO);
        led_rojo     = (estado_actual == ESTADO_ROJO);
    end

endmodule
