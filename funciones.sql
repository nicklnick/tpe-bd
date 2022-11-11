CREATE TABLE IF NOT EXISTS clientes_banco
(
    codigo  INT,
    dni     INT NOT NULL CHECK (dni > 0),
    telefono    VARCHAR(16), --CHECK (VALUE ~'^([0-9]+[\- ]?)+$'),
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
);


CREATE FUNCTION backup_cliente()
    RETURNS TRIGGER AS $$

    DECLARE
        dni INT;
        nombre  VARCHAR(32);
        telefono    VARCHAR(16);
        cant_prestamos  INT := 0;
        monto_prestamos INT  := 0;
        monto_pago_cuotas   INT  := 0;
--         ind_pagos_pendiente BOOLEAN  := 0;

        prestamos RECORD;
        pagos RECORD;

        cursorPrestamos CURSOR FOR
            SELECT p.importe, p.codigo
            FROM prestamos_banco p
            WHERE p.codigo_cliente = OLD.codigo;

        cursorPagos CURSOR FOR
            SELECT p2.importe
            FROM pagos_cuotas p2
            WHERE p2.codigo_prestamo = prestamos.codigo;

    BEGIN
        dni = OLD.dni;
        nombre = OLD.nombre;
        telefono = OLD.telefono;


        open cursorPrestamos;
        loop
            fetch cursorPrestamos into prestamos;
            exit when not found;

            cant_prestamos = cant_prestamos + 1;
            monto_prestamos = monto_prestamos + prestamos.importe;


            open cursorPagos;
            loop
                fetch cursorPagos into pagos;
                exit when not found;

                monto_pago_cuotas =  monto_pago_cuotas + pagos.importe;

            end loop;

            close cursorPagos;

        end loop;
        close cursorPrestamos;

        INSERT INTO backup values (dni, nombre, telefono, cant_prestamos, monto_prestamos, monto_pago_cuotas, monto_prestamos > monto_pago_cuotas);

        RETURN null;
    END;

$$ LANGUAGE plpgsql;



CREATE TRIGGER borrado_cliente
    BEFORE DELETE ON clientes_banco
    FOR EACH ROW
    EXECUTE PROCEDURE backup_cliente();







