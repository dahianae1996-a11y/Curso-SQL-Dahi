
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
    
    