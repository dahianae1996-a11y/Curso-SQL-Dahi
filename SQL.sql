
##--------------CREAR BASE DE DATOS --------------

CREATE DATABASE Base_Vet;

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
    telefono VARCHAR(100) NOT NULL,
	id_vet INT NOT NULL,
    FOREIGN KEY (id_vet) REFERENCES Veterinaria(id_vet));
    
##  Mascota
CREATE TABLE Mascota (
	id_mascota INT AUTO_INCREMENT PRIMARY KEY, 
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(100) NOT NULL,
    raza VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
	id_socio INT NOT NULL,
    FOREIGN KEY (id_socio) REFERENCES Socio(id_socio));
    
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
    costo FLOAT);
    
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
    fecha_hora DATETIME NOT NULL,
    id_mascota INT NOT NULL,
    id_vet INT NOT NULL,
    id_servicio INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    FOREIGN KEY (id_mascota) REFERENCES Mascota(id_mascota),
    FOREIGN KEY (id_vet) REFERENCES Veterinaria(id_vet),
    FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio),
    FOREIGN KEY (id_metodo_pago) REFERENCES Metodo_pago(id_metodo_pago));
USE Base_Vet;
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
    m.nombre AS nombre_mascota,
    m.especie,
    m.raza
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

CREATE FUNCTION fn_costo_servicio(idServicio INT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE costoServicio FLOAT;

    SELECT costo
    INTO costoServicio
    FROM Servicio
    WHERE id_servicio = idServicio;

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
        nombre,
        especie,
        raza
    FROM Mascota
    WHERE id_socio = p_id_socio;
END //

DELIMITER ;
    
    
