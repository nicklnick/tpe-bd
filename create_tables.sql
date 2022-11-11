CREATE TABLE IF NOT EXISTS clientes_banco
(
    codigo  INT,
    dni     INT NOT NULL CHECK (dni > 0),
    telefono    VARCHAR(16) CHECK (VALUE ~'^([0-9]+[\- ]?)+$'),
    nombre  VARCHAR(32) NOT NULL,
    direccion   VARCHAR(64),

    PRIMARY KEY (codigo)
);

CREATE TABLE IF NOT EXISTS prestamos_banco
(
    codigo  INT,
    fecha   DATE NOT NULL,
    codigo_cliente INT NOT NULL,
    importe INT CHECK (importe > 0),

    PRIMARY KEY (codigo),
    FOREIGN KEY (codigo_cliente) REFERENCES clientes_banco ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pagos_cuotas
(
    nro_cuota   INT,
    codigo_prestamo INT,
    importe INT CHECK (importe > 0),
    fecha   DATE NOT NULL,

    PRIMARY KEY (nro_cuota, codigo_prestamo),
    FOREIGN KEY (codigo_prestamo) REFERENCES prestamos_banco ON DELETE CASCADE
);

-- TODO: agregar chequeos?
CREATE TABLE IF NOT EXISTS backup
(
    dni INT,
    nombre  VARCHAR(32),
    telefono    VARCHAR(16),
    cant_prestamos  INT,
    monto_prestamos INT,
    monto_pago_cuotas   INT,
    ind_pagos_pendiente BOOLEAN,

    PRIMARY KEY (dni)
)