-- ============================================================
--  Base de datos: bdabarrotes
--  Descripción  : Sistema de gestión de tienda de abarrotes
--  Motor        : MySQL 8.0+
--  Fecha        : 2026-05-13
-- ============================================================

CREATE DATABASE IF NOT EXISTS bdabarrotes
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;

USE bdabarrotes;

-- ------------------------------------------------------------
-- 1. CATEGORIA
-- ------------------------------------------------------------
CREATE TABLE categoria (
  id_categoria   INT            NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(80)    NOT NULL,
  descripcion    VARCHAR(255)       NULL,
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);

-- ------------------------------------------------------------
-- 2. UNIDAD_MEDIDA
-- ------------------------------------------------------------
CREATE TABLE unidad_medida (
  id_unidad      INT            NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(60)    NOT NULL,
  abreviatura    VARCHAR(10)    NOT NULL,
  CONSTRAINT pk_unidad PRIMARY KEY (id_unidad),
  CONSTRAINT uq_unidad_abrev UNIQUE (abreviatura)
);

-- ------------------------------------------------------------
-- 3. PUESTO
-- ------------------------------------------------------------
CREATE TABLE puesto (
  id_puesto      INT            NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(80)    NOT NULL,
  descripcion    VARCHAR(255)       NULL,
  CONSTRAINT pk_puesto PRIMARY KEY (id_puesto),
  CONSTRAINT uq_puesto_nombre UNIQUE (nombre)
);

-- ------------------------------------------------------------
-- 4. ALMACEN
-- ------------------------------------------------------------
CREATE TABLE almacen (
  id_almacen     INT            NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(80)    NOT NULL,
  ubicacion      VARCHAR(255)       NULL,
  CONSTRAINT pk_almacen PRIMARY KEY (id_almacen)
);

-- ------------------------------------------------------------
-- 5. PRODUCTO
-- ------------------------------------------------------------
CREATE TABLE producto (
  id_producto    INT             NOT NULL AUTO_INCREMENT,
  codigo_barras  VARCHAR(50)         NULL,
  nombre         VARCHAR(120)    NOT NULL,
  descripcion    VARCHAR(255)        NULL,
  id_categoria   INT             NOT NULL,
  id_unidad      INT             NOT NULL,
  precio_venta   DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  precio_costo   DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  stock_minimo   INT             NOT NULL DEFAULT 0,
  activo         TINYINT(1)      NOT NULL DEFAULT 1,
  CONSTRAINT pk_producto     PRIMARY KEY (id_producto),
  CONSTRAINT uq_cod_barras   UNIQUE (codigo_barras),
  CONSTRAINT fk_prod_categ   FOREIGN KEY (id_categoria)
      REFERENCES categoria (id_categoria)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_prod_unidad  FOREIGN KEY (id_unidad)
      REFERENCES unidad_medida (id_unidad)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 6. INVENTARIO
-- ------------------------------------------------------------
CREATE TABLE inventario (
  id_inventario       INT          NOT NULL AUTO_INCREMENT,
  id_producto         INT          NOT NULL,
  id_almacen          INT          NOT NULL,
  cantidad            INT          NOT NULL DEFAULT 0,
  fecha_actualizacion DATE         NOT NULL,
  CONSTRAINT pk_inventario    PRIMARY KEY (id_inventario),
  CONSTRAINT uq_inv_prod_alm  UNIQUE (id_producto, id_almacen),
  CONSTRAINT fk_inv_producto  FOREIGN KEY (id_producto)
      REFERENCES producto (id_producto)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_inv_almacen   FOREIGN KEY (id_almacen)
      REFERENCES almacen (id_almacen)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 7. PROVEEDOR
-- ------------------------------------------------------------
CREATE TABLE proveedor (
  id_proveedor   INT            NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(120)   NOT NULL,
  rfc            VARCHAR(15)        NULL,
  telefono       VARCHAR(20)        NULL,
  email          VARCHAR(100)       NULL,
  direccion      VARCHAR(255)       NULL,
  activo         TINYINT(1)     NOT NULL DEFAULT 1,
  CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor),
  CONSTRAINT uq_prov_rfc UNIQUE (rfc)
);

-- ------------------------------------------------------------
-- 8. EMPLEADO
-- ------------------------------------------------------------
CREATE TABLE empleado (
  id_empleado    INT            NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(80)    NOT NULL,
  apellido       VARCHAR(80)    NOT NULL,
  telefono       VARCHAR(20)        NULL,
  id_puesto      INT            NOT NULL,
  fecha_alta     DATE           NOT NULL,
  activo         TINYINT(1)     NOT NULL DEFAULT 1,
  CONSTRAINT pk_empleado    PRIMARY KEY (id_empleado),
  CONSTRAINT fk_emp_puesto  FOREIGN KEY (id_puesto)
      REFERENCES puesto (id_puesto)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 9. CLIENTE
-- ------------------------------------------------------------
CREATE TABLE cliente (
  id_cliente      INT            NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(120)   NOT NULL,
  telefono        VARCHAR(20)        NULL,
  email           VARCHAR(100)       NULL,
  direccion       VARCHAR(255)       NULL,
  credito_limite  DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  activo          TINYINT(1)     NOT NULL DEFAULT 1,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente)
);

-- ------------------------------------------------------------
-- 10. FORMA_PAGO
-- ------------------------------------------------------------
CREATE TABLE forma_pago (
  id_forma_pago  INT            NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(60)    NOT NULL,
  CONSTRAINT pk_forma_pago    PRIMARY KEY (id_forma_pago),
  CONSTRAINT uq_forma_nombre  UNIQUE (nombre)
);

-- ------------------------------------------------------------
-- 11. ORDEN_COMPRA
-- ------------------------------------------------------------
CREATE TABLE orden_compra (
  id_orden        INT            NOT NULL AUTO_INCREMENT,
  id_proveedor    INT            NOT NULL,
  id_empleado     INT            NOT NULL,
  fecha_orden     DATE           NOT NULL,
  fecha_esperada  DATE               NULL,
  estatus         VARCHAR(30)    NOT NULL DEFAULT 'PENDIENTE'
                  COMMENT 'PENDIENTE | RECIBIDA | CANCELADA',
  total           DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
  CONSTRAINT pk_orden          PRIMARY KEY (id_orden),
  CONSTRAINT fk_oc_proveedor   FOREIGN KEY (id_proveedor)
      REFERENCES proveedor (id_proveedor)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_oc_empleado    FOREIGN KEY (id_empleado)
      REFERENCES empleado (id_empleado)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 12. DETALLE_ORDEN_COMPRA
-- ------------------------------------------------------------
CREATE TABLE detalle_orden_compra (
  id_detalle      INT            NOT NULL AUTO_INCREMENT,
  id_orden        INT            NOT NULL,
  id_producto     INT            NOT NULL,
  cantidad        INT            NOT NULL,
  precio_unitario DECIMAL(10,2)  NOT NULL,
  subtotal        DECIMAL(12,2)  NOT NULL,
  CONSTRAINT pk_det_oc         PRIMARY KEY (id_detalle),
  CONSTRAINT fk_doc_orden      FOREIGN KEY (id_orden)
      REFERENCES orden_compra (id_orden)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_doc_producto   FOREIGN KEY (id_producto)
      REFERENCES producto (id_producto)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 13. VENTA
-- ------------------------------------------------------------
CREATE TABLE venta (
  id_venta       INT            NOT NULL AUTO_INCREMENT,
  id_cliente     INT                NULL COMMENT 'NULL = público general',
  id_empleado    INT            NOT NULL,
  fecha_venta    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  subtotal       DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
  impuesto       DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
  total          DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
  estatus        VARCHAR(30)    NOT NULL DEFAULT 'COMPLETADA'
                 COMMENT 'COMPLETADA | CANCELADA | CREDITO',
  CONSTRAINT pk_venta         PRIMARY KEY (id_venta),
  CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente)
      REFERENCES cliente (id_cliente)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_venta_emp    FOREIGN KEY (id_empleado)
      REFERENCES empleado (id_empleado)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 14. DETALLE_VENTA
-- ------------------------------------------------------------
CREATE TABLE detalle_venta (
  id_detalle      INT            NOT NULL AUTO_INCREMENT,
  id_venta        INT            NOT NULL,
  id_producto     INT            NOT NULL,
  cantidad        INT            NOT NULL,
  precio_unitario DECIMAL(10,2)  NOT NULL,
  descuento       DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  subtotal        DECIMAL(12,2)  NOT NULL,
  CONSTRAINT pk_det_venta      PRIMARY KEY (id_detalle),
  CONSTRAINT fk_dv_venta       FOREIGN KEY (id_venta)
      REFERENCES venta (id_venta)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_dv_producto    FOREIGN KEY (id_producto)
      REFERENCES producto (id_producto)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 15. PAGO_VENTA
-- ------------------------------------------------------------
CREATE TABLE pago_venta (
  id_pago        INT            NOT NULL AUTO_INCREMENT,
  id_venta       INT            NOT NULL,
  id_forma_pago  INT            NOT NULL,
  monto          DECIMAL(12,2)  NOT NULL,
  fecha_pago     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_pago_venta     PRIMARY KEY (id_pago),
  CONSTRAINT fk_pv_venta       FOREIGN KEY (id_venta)
      REFERENCES venta (id_venta)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pv_forma_pago  FOREIGN KEY (id_forma_pago)
      REFERENCES forma_pago (id_forma_pago)
      ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================================
--  DATOS INICIALES (catálogos básicos)
-- ============================================================

INSERT INTO categoria (nombre, descripcion) VALUES
  ('Lácteos',        'Leche, queso, yogurt y derivados'),
  ('Bebidas',        'Refrescos, jugos, agua y bebidas alcohólicas'),
  ('Abarrotes',      'Arroz, frijol, pasta, enlatados y conservas'),
  ('Limpieza',       'Detergentes, desinfectantes y artículos de limpieza'),
  ('Higiene personal','Jabón, shampoo, pasta dental y cuidado personal'),
  ('Botanas',        'Papas, cacahuates, dulces y frituras'),
  ('Panadería',      'Pan de caja, galletas y tortillas'),
  ('Carnes frías',   'Jamón, salchichas y embutidos');

INSERT INTO unidad_medida (nombre, abreviatura) VALUES
  ('Pieza',      'PZA'),
  ('Kilogramo',  'KG'),
  ('Litro',      'LT'),
  ('Gramo',      'GR'),
  ('Caja',       'CJA'),
  ('Paquete',    'PKT'),
  ('Mililitro',  'ML');

INSERT INTO puesto (nombre, descripcion) VALUES
  ('Gerente',      'Responsable general del negocio'),
  ('Cajero',       'Atención a clientes y cobro en caja'),
  ('Almacenista',  'Control y surtido de inventario'),
  ('Repartidor',   'Entrega de pedidos a domicilio');

INSERT INTO forma_pago (nombre) VALUES
  ('Efectivo'),
  ('Tarjeta de débito'),
  ('Tarjeta de crédito'),
  ('Transferencia'),
  ('Vales de despensa');

INSERT INTO almacen (nombre, ubicacion) VALUES
  ('Almacén principal', 'Bodega trasera planta baja'),
  ('Refrigeradores',    'Área de refrigeración pasillo 3'),
  ('Anaquel ventas',    'Piso de ventas');

-- ============================================================
--  FIN DEL SCRIPT
-- ============================================================
