-- Seed de 100 pacientes para la tabla proporcionada.
-- Requisito: debe existir un registro en usuarios con id_usuario = 1.
-- Si tu nutriologo tiene otro id, cambia el valor de @seed_id_usuario.

SET @seed_id_usuario = 1;

INSERT INTO pacientes (
    id_usuario,
    nombre_completo,
    fecha_nacimiento,
    edad,
    genero,
    ocupacion,
    estado_civil,
    motivo_consulta,
    enfermedades_patologicas,
    enfermedades_heredofamiliares,
    operaciones_previas,
    consume_tabaco,
    consume_alcohol,
    otras_sustancias,
    objetivo,
    nivel_actividad,
    medicamentos,
    estatus,
    fecha_registro
)
WITH RECURSIVE seq(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 100
)
SELECT
    @seed_id_usuario,
    CONCAT(
        ELT(MOD(n, 20) + 1,
            'Ana', 'Carlos', 'Maria', 'Jose', 'Laura',
            'Miguel', 'Sofia', 'Daniel', 'Valeria', 'Jorge',
            'Fernanda', 'Luis', 'Paola', 'Ricardo', 'Camila',
            'Andres', 'Diana', 'Hector', 'Gabriela', 'Emilio'
        ),
        ' ',
        ELT(MOD(n + 3, 20) + 1,
            'Garcia', 'Lopez', 'Hernandez', 'Martinez', 'Gonzalez',
            'Perez', 'Rodriguez', 'Sanchez', 'Ramirez', 'Cruz',
            'Flores', 'Torres', 'Rivera', 'Gomez', 'Diaz',
            'Morales', 'Vargas', 'Castillo', 'Ortiz', 'Reyes'
        ),
        ' ',
        ELT(MOD(n + 7, 20) + 1,
            'Aguilar', 'Mendoza', 'Chavez', 'Rojas', 'Silva',
            'Navarro', 'Campos', 'Medina', 'Guerrero', 'Vega',
            'Salazar', 'Pacheco', 'Nunez', 'Cortes', 'Fuentes',
            'Soto', 'Ibarra', 'Leon', 'Mejia', 'Valdez'
        )
    ) AS nombre_completo,
    DATE_SUB(DATE_SUB(CURDATE(), INTERVAL (18 + MOD(n, 55)) YEAR), INTERVAL MOD(n, 12) MONTH) AS fecha_nacimiento,
    18 + MOD(n, 55) AS edad,
    ELT(MOD(n, 3) + 1, 'M', 'F', 'Otro') AS genero,
    ELT(MOD(n, 12) + 1,
        'Estudiante', 'Empleado administrativo', 'Docente', 'Ingeniero',
        'Comerciante', 'Ama de casa', 'Medico', 'Abogado',
        'Disenador', 'Contador', 'Deportista', 'Empresario'
    ) AS ocupacion,
    ELT(MOD(n, 5) + 1, 'Soltero', 'Casado', 'Union libre', 'Divorciado', 'Viudo') AS estado_civil,
    ELT(MOD(n, 8) + 1,
        'Perdida de peso y mejora de habitos',
        'Aumento de masa muscular',
        'Control de glucosa',
        'Mejorar rendimiento deportivo',
        'Educacion nutricional familiar',
        'Control de colesterol y trigliceridos',
        'Plan alimenticio por gastritis',
        'Seguimiento nutricional general'
    ) AS motivo_consulta,
    ELT(MOD(n, 10) + 1,
        'Ninguna referida',
        'Gastritis ocasional',
        'Hipertension controlada',
        'Diabetes tipo 2',
        'Colitis',
        'Hipotiroidismo',
        'Dislipidemia',
        'Ansiedad relacionada con comida',
        'Migrana',
        'Resistencia a la insulina'
    ) AS enfermedades_patologicas,
    ELT(MOD(n, 8) + 1,
        'Padre con diabetes',
        'Madre con hipertension',
        'Abuelos con cardiopatia',
        'Sin antecedentes relevantes',
        'Familiares con obesidad',
        'Antecedentes de cancer en familia',
        'Hermanos con dislipidemia',
        'Padres con enfermedad tiroidea'
    ) AS enfermedades_heredofamiliares,
    ELT(MOD(n, 7) + 1,
        'Ninguna',
        'Apendicectomia',
        'Colecistectomia',
        'Cesarea',
        'Cirugia de rodilla',
        'Amigdalectomia',
        'Cirugia dental'
    ) AS operaciones_previas,
    IF(MOD(n, 5) = 0, TRUE, FALSE) AS consume_tabaco,
    IF(MOD(n, 4) = 0, TRUE, FALSE) AS consume_alcohol,
    ELT(MOD(n, 6) + 1,
        'Ninguna',
        'Cafe diario',
        'Bebidas energeticas ocasionales',
        'Suplemento proteinico',
        'Te verde',
        'Vitaminas de venta libre'
    ) AS otras_sustancias,
    ELT(MOD(n, 8) + 1,
        'Bajar grasa corporal',
        'Ganar masa muscular',
        'Mejorar digestion',
        'Control metabolico',
        'Aumentar energia',
        'Mantener peso saludable',
        'Mejorar composicion corporal',
        'Crear habitos sostenibles'
    ) AS objetivo,
    ELT(MOD(n, 5) + 1, 'Sedentario', 'Ligero', 'Moderado', 'Activo', 'Muy activo') AS nivel_actividad,
    ELT(MOD(n, 8) + 1,
        'Ninguno',
        'Metformina',
        'Losartan',
        'Levotiroxina',
        'Omeprazol',
        'Atorvastatina',
        'Vitaminas',
        'Antihistaminico ocasional'
    ) AS medicamentos,
    ELT(MOD(n, 3) + 1, 'en_meta', 'en_proceso', 'atencion') AS estatus,
    DATE_SUB(NOW(), INTERVAL n DAY) AS fecha_registro
FROM seq;

-- Validacion rapida:
SELECT COUNT(*) AS total_pacientes FROM pacientes;
