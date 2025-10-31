/// Definir la función para calcular el hexagrama
(
~calcularHexagrama = {
    // Código para calcular el hexagrama (por ejemplo, generar un número aleatorio entre 1 y 64)
    var numeroHexagrama = (1..64).choose;
    numeroHexagrama
};
)

// Importar los patrones desde otro documento .scd
include("/Users/sdcarr/Documents/GitHub/My-setup-sc-live-coding/Setup/patrones.scd");

// Activar los patrones y modificar los argumentos según sea necesario
(
~activarPatrones = { |numeroHexagrama|
    // Calcula el hexagrama
    var hexagrama = ~calcularHexagrama.value;

    // Activa los patrones correspondientes al hexagrama
    switch(hexagrama,
        // Define los casos para cada hexagrama y activa los patrones correspondientes
        1, [ // Hexagrama 1
            // Activa los patrones necesarios para el hexagrama 1
            // Modifica los argumentos de los patrones si es necesario
        ],
        // Define los casos para otros hexagramas
        _,
        [
            // Activa los patrones correspondientes para otros hexagramas
            // Modifica los argumentos de los patrones si es necesario
        ]
    );
};
)

// Crear una función para desactivar los patrones progresivamente
(
~desactivarPatronesProgresivamente = {
    // Código para desactivar los patrones progresivamente
    // Por ejemplo, detener los eventos gradualmente o reducir su intensidad
};
)

// Ejemplo de uso:
// Calcular el hexagrama
var hexagramaCalculado = ~calcularHexagrama.value;
// Activar los patrones correspondientes al hexagrama calculado
~activarPatrones.value(hexagramaCalculado);
// Luego, puedes modificar los patrones según sea necesario
// Finalmente, cuando desees, puedes desactivar los patrones progresivamente
// ~desactivarPatronesProgresivamente.value;
