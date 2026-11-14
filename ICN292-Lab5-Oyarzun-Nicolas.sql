DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;
CREATE TABLE tiendas(
    id_tienda INT AUTO_INCREMENT,
    nombre VARCHAR(60),
    comuna VARCHAR(50),
    PRIMARY KEY(id_tienda)  
);
CREATE TABLE vendedores(
    id_vendedor INT AUTO_INCREMENT,
    nombre VARCHAR(80),
    id_tienda INT,
    fecha_ingreso DATE,
    PRIMARY KEY(id_vendedor),
    FOREIGN KEY(id_tienda) REFERENCES tiendas(id_tienda)
);
CREATE TABLE bicicletas(
    id_bicicleta INT AUTO_INCREMENT,
    modelo VARCHAR(60),
    categoría ENUM ('Eléctrica', 'Infantil', 'Montaña', 'Ruta', 'Urbana'),
    precio DECIMAL(10,2),
    PRIMARY KEY(id_bicicleta)
);
CREATE TABLE ventas(
    id_venta INT AUTO_INCREMENT,
    id_vendedor INT,
    bicicleta INT,
    fecha DATE,
    unidades INT,
    PRIMARY KEY(id_venta),
    FOREIGN KEY(id_vendedor) REFERENCES vendedores(id_vendedor),
    FOREIGN KEY(bicicleta) REFERENCES bicicletas(id_bicicleta)
);

INSERT INTO tiendas(nombre, comuna) VALUES
('Andes Providencia','Providencia'),
('Andes Maipú','Maipú'),
('Andes Concepción','Concepción'),
('Andes La Serena','La Serena');

INSERT INTO vendedores(nombre,id_tienda,fecha_ingreso) VALUES
('Camila Ortiz',1,'2024-06-20'),
('Diego Fuentes',1,'2024-01-15'),
('Javiera Soto',2,'2023-07-24'),
('Matías Herrera',2,'2024-01-15'),
('Paula Riquelme',3,'2022-11-02'),
('Ignacio Vera',3,'2024-08-19'),
('Fernanda Lillo',1,'2025-02-03'),
('Rubén Castro',NULL,'2025-06-10');

INSERT INTO bicicletas(modelo,categoría,precio) VALUES
('Cordillera 29','Montaña',549990.00),
('Ruta Austral','Ruta',899990.00),
('Urbana Pro',	'Urbana',	329990.00),
('Pequeño Andes','Infantil',149990.00),
('Volt City','Eléctrica',1249990.00),
('Trail Master','Montaña',749990.00),
('Urbana Lite','Urbana',229990.00),
('Sprint R7','Ruta',1099990.00);

INSERT INTO ventas(id_vendedor,bicicleta,fecha,unidades) VALUES
(1,1,'2025-03-04',2),
(1,3,'2025-03-18',1),
(1,5,'2025-04-02',1),
(2,2,'2025-03-04',1),
(2,1,'2025-04-11',3),
(2,7,'2025-05-06',2),
(3,4,'2025-03-21',4),
(3,3,'2025-04-15',2),
(3,6,'2025-05-20',1),
(4,1,'2025-03-27',1),
(4,5,'2025-05-09',2),
(5,2,'2025-04-08',1),
(5,6,'2025-04-23',2),
(5,4,'2025-06-02',5),
(6,3,'2025-05-13',3),
(6,7,'2025-06-17',1),
(6,1,'2025-06-24',2),
(1,6,'2025-06-30',1);

#Consultas
#Consulta 1
SELECT v.nombre as vendedor, COUNT(ve.id_vendedor) AS ventas_vendedor
FROM vendedores v
LEFT JOIN ventas ve ON v.id_vendedor = ve.id_vendedor
GROUP BY v.nombre, ve.id_vendedor
ORDER BY ventas_vendedor DESC, v.nombre;
#Consulta 2 
SELECT t.nombre AS tienda, COUNT(ve.id_vendedor) AS ventas_registradas, SUM(ve.unidades) AS unidades_vendidas
FROM tiendas t 
LEFT JOIN vendedores v ON t.id_tienda = v.id_tienda
LEFT JOIN ventas ve ON  v.id_vendedor = ve.id_vendedor
GROUP BY t.nombre, v.id_tienda
ORDER BY unidades_vendidas DESC;
#Consulta 3
SELECT t.nombre, COUNT(v.id_tienda) AS empleados
FROM tiendas t 
LEFT JOIN vendedores v ON t.id_tienda = v.id_tienda
GROUP BY t.nombre, v.id_tienda
HAVING empleados = 0;
#Consulta 4
SELECT b.modelo
FROM bicicletas b
LEFT JOIN ventas v ON b.id_bicicleta = v.bicicleta
    AND YEAR(v.fecha) = 2025
    AND MONTH(v.fecha) = 6
WHERE v.bicicleta IS NULL
ORDER BY b.modelo;
#Consulta 5
SELECT ve.nombre,t.nombre
FROM vendedores ve
 LEFT JOIN tiendas t ON ve.id_tienda = t.id_tienda
 LEFT JOIN ventas v ON ve.id_vendedor = v.id_vendedor
 GROUP BY ve.nombre, t.nombre, v.unidades
 HAVING v.unidades = 0 OR v.unidades IS NULL;
#Consulta 6
SELECT ve.nombre AS vendedor1, ve.fecha_ingreso AS fecha1,
       v2.nombre AS vendedor2, v2.fecha_ingreso AS fecha2,
       t.nombre AS tienda
FROM vendedores ve
JOIN vendedores v2 ON ve.id_tienda = v2.id_tienda
    AND (ve.fecha_ingreso < v2.fecha_ingreso
    OR (ve.fecha_ingreso = v2.fecha_ingreso
    AND ve.id_vendedor < v2.id_vendedor))
LEFT JOIN tiendas t ON ve.id_tienda = t.id_tienda
ORDER BY t.nombre, ve.fecha_ingreso;
 #Consulta 7
SELECT t.nombre, SUM(precio*v.unidades) AS ventas_totales
FROM ventas v
JOIN bicicletas b ON v.bicicleta=b.id_bicicleta
LEFT JOIN vendedores ve ON v.id_vendedor=ve.id_vendedor
JOIN tiendas t ON ve.id_tienda= t.id_tienda
WHERE b.categoría IN ('Montaña', 'Ruta')
GROUP BY t.nombre
HAVING ventas_totales > 2000000
ORDER BY ventas_totales DESC;
#Consulta 8
SELECT modelo,precio
FROM bicicletas  
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;
#Consulta 9
SELECT ve.nombre, AVG(v.unidades) AS promedio
FROM vendedores ve
JOIN ventas v ON ve.id_vendedor= v.id_vendedor
GROUP BY ve.nombre
HAVING promedio > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio DESC, ve.nombre;
#Consulta 10
SELECT ve.nombre, SUM(v.unidades*b.precio) AS total_vendido
FROM ventas v
RIGHT JOIN vendedores ve ON v.id_vendedor = ve.id_vendedor
LEFT JOIN bicicletas b ON v.bicicleta = b.id_bicicleta
GROUP BY ve.nombre
ORDER BY total_vendido DESC;

