# disenoFpga

# Ejercicio No. 1

Este ejercicio implementa un semáforo digital en la Nexys A7 utilizando únicamente lógica secuencial básica en Verilog. El diseño emplea el reloj de 100 MHz de la tarjeta para generar temporización mediante un contador de 30 bits que mide ciclos de reloj y define una secuencia de 6 segundos: 2 segundos en rojo, 3 segundos en verde y 1 segundo en ámbar. La activación de cada LED se controla con una estructura `case` que evalúa puntos específicos del contador, sin recurrir a máquinas de estado finito (FSM). Este enfoque permite comprender cómo traducir tiempo físico en ciclos de reloj dentro de una FPGA, reforzando conceptos fundamentales como diseño síncrono, dimensionamiento de registros y control temporal basado en hardware.

# Ejercicio No. 2

Este ejercicio implementa un semáforo digital sobre la Nexys A7 utilizando una Máquina de Estados Finitos (FSM) tipo Moore, modelada de forma estructurada y escalable en Verilog. A diferencia del ejercicio anterior basado únicamente en un contador global, aquí el comportamiento del sistema se organiza mediante un registro de estado actual, una lógica combinacional de transición y una lógica de salida independiente. Cada estado (verde, amarillo y rojo) permanece activo durante un tiempo determinado, calculado en ciclos del reloj de 100 MHz de la tarjeta, y el contador interno se reinicia automáticamente en cada cambio de estado. Este enfoque introduce formalmente el diseño secuencial síncrono en FPGA, refuerza la separación entre lógica combinacional y registrada, y establece una base sólida para sistemas embebidos más complejos basados en control por estados.

# Ejercicio No. 3

Este ejercicio extiende la máquina de estados del semáforo incorporando una entrada externa segura y sincronizada sobre la Nexys A7. El diseño implementa una FSM tipo Moore con tres estados (verde, amarillo y rojo), donde el tiempo de permanencia en cada uno se controla mediante un contador basado en el reloj de 100 MHz. Como el pulsador es una señal asíncrona respecto al sistema, se incluye un sincronizador de doble flip-flop para evitar metastabilidad y un detector de flanco ascendente que genera un pulso limpio de un ciclo de reloj. Cuando se presiona el botón en estado verde, la transición a amarillo se adelanta, manteniéndose la secuencia automática si no hay intervención del usuario. Este ejercicio introduce formalmente el tratamiento correcto de entradas físicas en FPGA y refuerza conceptos de diseño síncrono robusto en sistemas embebidos digitales.
