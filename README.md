# disenoFpga

# Ejercicio No. 1

Este ejercicio implementa un semáforo digital en la Nexys A7 utilizando únicamente lógica secuencial básica en Verilog. El diseño emplea el reloj de 100 MHz de la tarjeta para generar temporización mediante un contador de 30 bits que mide ciclos de reloj y define una secuencia de 6 segundos: 2 segundos en rojo, 3 segundos en verde y 1 segundo en ámbar. La activación de cada LED se controla con una estructura `case` que evalúa puntos específicos del contador, sin recurrir a máquinas de estado finito (FSM). Este enfoque permite comprender cómo traducir tiempo físico en ciclos de reloj dentro de una FPGA, reforzando conceptos fundamentales como diseño síncrono, dimensionamiento de registros y control temporal basado en hardware.
