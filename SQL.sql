##--------------CREAR BASE DE DATOS --------------

CREATE DATABASE Base_Vet;

USE Base_Vet;

##--------------CREAR TABLAS --------------
##  Zona  
CREATE TABLE Zona (
	id_zona INT AUTO_INCREMENT PRIMARY KEY, 
    nombre_zona VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL );
    
##  Veterinaria
CREATE TABLE Veterinaria (
	id_vet INT AUTO_INCREMENT PRIMARY KEY, 
    nombre_vet VARCHAR(100) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
	id_zona INT NOT NULL,
    FOREIGN KEY (id_zona) REFERENCES Zona(id_zona));
    
##  Socio
CREATE TABLE Socio (
	id_socio INT AUTO_INCREMENT PRIMARY KEY, 
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
	id_vet INT NOT NULL,
    FOREIGN KEY (id_vet) REFERENCES Veterinaria(id_vet));
    
    ## Especie 
CREATE TABLE Especie (
	id_especie INT AUTO_INCREMENT PRIMARY KEY,
    nombre_especie VARCHAR(50) NOT NULL);
    
## Raza
CREATE TABLE Raza (
id_raza INT AUTO_INCREMENT PRIMARY KEY,
nombre_raza VARCHAR(50) NOT NULL,
id_especie INT NOT NULL,
FOREIGN KEY (id_especie) REFERENCES Especie(id_especie));

##  Mascota
CREATE TABLE Mascota (
	id_mascota INT AUTO_INCREMENT PRIMARY KEY, 
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
	id_socio INT NOT NULL,
    id_especie INT NOT NULL,
    id_raza INT NOT NULL,
    FOREIGN KEY (id_socio) REFERENCES Socio(id_socio),
    FOREIGN KEY (id_especie) REFERENCES Especie(id_especie),
    FOREIGN KEY (id_raza) REFERENCES Raza(id_raza));

    
##  Metodo de Pago
CREATE TABLE Metodo_pago (
	id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY, 
    banco VARCHAR(100) NOT NULL,
    cuotas VARCHAR(100) NOT NULL);
    
##  Servicio
CREATE TABLE Servicio (
	id_servicio INT AUTO_INCREMENT PRIMARY KEY, 
    nombre_servicio VARCHAR(100) NOT NULL,
    duracion INT NOT NULL,
    costo decimal);
    
##  Empleado
CREATE TABLE Empleado (
	id_empleado INT AUTO_INCREMENT PRIMARY KEY, 
    nombre_empleado VARCHAR(100) NOT NULL,
	apellido_empleado VARCHAR(100) NOT NULL,
	especialidad VARCHAR(100) NOT NULL);
    
## Empleado-Veterinaria
CREATE TABLE EmpleadoVeterinaria (
	id_EmpleadoVeterinaria INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT NOT NULL,
    id_vet INT NOT NULL,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
    FOREIGN KEY (id_vet) REFERENCES Veterinaria(id_vet));
    
## Turno
CREATE TABLE Turno (
	id_turno INT AUTO_INCREMENT PRIMARY KEY,
    estado_turno VARCHAR(20),
    fecha_hora DATETIME NOT NULL,
    id_mascota INT NOT NULL,
    id_vet INT NOT NULL,
    id_servicio INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    id_empleado INT NOT NULL,
    FOREIGN KEY (id_mascota) REFERENCES Mascota(id_mascota),
    FOREIGN KEY (id_vet) REFERENCES Veterinaria(id_vet),
    FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio),
    FOREIGN KEY (id_metodo_pago) REFERENCES Metodo_pago(id_metodo_pago),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado));


##------- Crear Vistas -------

## veterinarias_por_zona

CREATE VIEW veterinarias_por_zona AS
SELECT 
    v.id_vet,
    v.nombre_vet,
    v.direccion,
    z.nombre_zona,
    z.ciudad
FROM Veterinaria v
JOIN Zona z ON v.id_zona = z.id_zona;

## socios_y_mascotas

CREATE VIEW socios_y_mascotas AS
SELECT 
    s.id_socio,
    s.nombre,
    s.apellido,
    m.id_mascota,
    m.nombre AS nombre_mascota
FROM Socio s
JOIN Mascota m ON s.id_socio = m.id_socio;

## turnos_detalle

CREATE VIEW turnos_detalle AS
SELECT 
    t.id_turno,
    t.fecha_hora,
    m.nombre AS mascota,
    v.nombre_vet,
    s.nombre_servicio,
    s.costo,
    mp.banco
FROM Turno t
JOIN Mascota m ON t.id_mascota = m.id_mascota
JOIN Veterinaria v ON t.id_vet = v.id_vet
JOIN Servicio s ON t.id_servicio = s.id_servicio
JOIN Metodo_pago mp ON t.id_metodo_pago = mp.id_metodo_pago;

##------- Funciones -------

## Funcion costo servicio

DELIMITER //

CREATE FUNCTION fn_costo_servicio(p_id_Servicio INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE costoServicio DECIMAL(10,2);

    SELECT costo
    INTO costoServicio
    FROM Servicio
    WHERE id_servicio = p_id_Servicio;

    RETURN costoServicio;
END //

DELIMITER ;

## Funcion calcular edad mascota

DELIMITER //

CREATE FUNCTION fn_calcular_edad_mascota(fecha_nac DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());
END //

DELIMITER ;

## -------STORED PROCEDURES-------

## Registrar Turno

DELIMITER //

CREATE PROCEDURE registrar_turno (
    IN p_fecha_hora DATETIME,
    IN p_id_mascota INT,
    IN p_id_vet INT,
    IN p_id_servicio INT,
    IN p_id_metodo_pago INT
)
BEGIN
    INSERT INTO Turno (
        fecha_hora,
        id_mascota,
        id_vet,
        id_servicio,
        id_metodo_pago
    )
    VALUES (
        p_fecha_hora,
        p_id_mascota,
        p_id_vet,
        p_id_servicio,
        p_id_metodo_pago
    );
END //

DELIMITER ;

## Turno por Veterinaria

DELIMITER //

CREATE PROCEDURE listar_turnos_por_veterinaria (
    IN p_id_vet INT
)
BEGIN
    SELECT 
        t.id_turno,
        t.fecha_hora,
        m.nombre AS mascota,
        s.nombre_servicio
    FROM Turno t
    JOIN Mascota m ON t.id_mascota = m.id_mascota
    JOIN Servicio s ON t.id_servicio = s.id_servicio
    WHERE t.id_vet = p_id_vet;
END //

DELIMITER ;

## Mascota por Socios

DELIMITER //

CREATE PROCEDURE mascotas_por_socio (
    IN p_id_socio INT
)
BEGIN
    SELECT 
        id_mascota,
        nombre
    FROM Mascota
    WHERE id_socio = p_id_socio;
END //

DELIMITER ;

## -------Agregar datos-----

INSERT INTO Zona (nombre_zona, ciudad) VALUES
('Centro', 'Montevideo'),
('Cordon', 'Montevideo');

INSERT INTO Veterinaria (nombre_vet, direccion, id_zona) VALUES
('Vet Centro', '18 de Julio 1234', 1),
('Vet Cordon', 'Gral Rivera 4567', 2);

INSERT INTO Socio (nombre, apellido, telefono, id_vet) VALUES
('Ana', 'Pérez', '099123456', 1),
('Juan', 'Gómez', '098654321', 2);

INSERT INTO Especie (nombre_especie) VALUES
('Perro'),
('Gato');

INSERT INTO Raza (nombre_raza, id_especie) VALUES
('Labrador', 1),
('Caniche', 1),
('Siames', 2);

INSERT INTO Mascota (nombre, fecha_nacimiento, id_socio, id_especie, id_raza) VALUES
('Toby', '2020-05-10', 1, 1, 2),
('Isi', '2023-09-12', 1, 2, 1),
('Tita', '2000-06-27', 1, 1, 1),
('Mishi', '2019-08-20', 2, 2, 3);

INSERT INTO Metodo_pago (banco, cuotas) VALUES
('BROU', '1'),
('Santander', '3');

INSERT INTO Servicio (nombre_servicio, duracion, costo) VALUES
('Consulta', 30, 1500.00),
('Vacunación', 20, 1000.00),
('Castracion', 120, 5000.00);

INSERT INTO Empleado (nombre_empleado, apellido_empleado, especialidad) VALUES
('Laura', 'Rodríguez', 'Clínica'),
('Carlos', 'Fernández', 'Cirugía');

INSERT INTO Turno (estado_turno, fecha_hora, id_mascota, id_vet, id_servicio, id_metodo_pago, id_empleado) VALUES

('Confirmado', '2026-01-22 09:00:00', 3, 1, 3, 2, 2),
('Confirmado', '2026-01-23 14:30:00', 1, 1, 2, 1, 1),
('Cancelado',  '2026-01-24 16:00:00', 2, 1, 1, 1, 1),


('Confirmado', '2026-01-25 10:15:00', 4, 2, 1, 2, 1),
('Confirmado', '2026-01-26 11:00:00', 4, 2, 2, 2, 2),
('Confirmado', '2026-01-27 15:45:00', 2, 2, 1, 1, 2);

## -------Consultas para informes-------

	## Turnos por Veterinaria
SELECT 
    v.nombre_vet,
    COUNT(t.id_turno) AS total_turnos
FROM Turno t
JOIN Veterinaria v ON t.id_vet = v.id_vet
GROUP BY v.nombre_vet;

	## Servicios más Solicitados
SELECT 
    s.nombre_servicio,
    COUNT(t.id_turno) AS cantidad
FROM Turno t
JOIN Servicio s ON t.id_servicio = s.id_servicio
GROUP BY s.nombre_servicio
ORDER BY cantidad DESC;

	## Mascotas por especie
SELECT 
    e.nombre_especie,
    COUNT(m.id_mascota) AS cantidad
FROM Mascota m
JOIN Especie e ON m.id_especie = e.id_especie
GROUP BY e.nombre_especie;
