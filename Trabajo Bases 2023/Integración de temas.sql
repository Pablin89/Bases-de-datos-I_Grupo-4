
Use base_consorcio;

----------------------------TRANSACCIONES----------------------------------

---Con error en la transacción---
SET LANGUAGE Spanish;

BEGIN TRY
	BEGIN TRAN
	
	--Inserción registro administrador
	INSERT INTO administrador(apeynom,viveahi,tel,sexo,fechnac) values ('Juan Pablo Duete', 'S', '3794000102', 'M', '19890625')
	
	--Inserción registro consorcio
	INSERT INTO consorcio(idprovincia,idlocalidad,idconsorcio, Nombre,direccion,idzona,idconserje,idadmin)
	VALUES (7, 7, 1, 'EDIFICIO-24500', '9 de julio Nº 1650', 2, Null, (select top 1 idadmin from administrador order by idadmin desc))--id del último administrador
	
	--Inserción 3 registros gasto
	INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
	VALUES (30, 7, 1,1,'20231005',2,5000.00)

	INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
	VALUES (7, 7, 1,1,'20231015',2,20000.00)

	INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
	VALUES (7, 7, 1,1,'20231028',2,10000.00)

	COMMIT TRAN
END TRY

BEGIN CATCH
	SELECT ERROR_MESSAGE() As Error-- Se captura el error y lo muestra.
	ROLLBACK TRAN
END CATCH
 
 ---Controlar la realizacion de las inserciones------------------------------------------------------------------
select * from administrador where apeynom = 'Juan Pablo Duete'
select * from consorcio where idprovincia = 7 --No existen en principio consorcios en la provincia de Corrientes
select * from gasto where idprovincia = 7






----------------------------PROCEDIMIENTOS ALMACENADOS----------------------------------


--*OBSERVACIÓN: las variables de error y exito planteados por los compañeros fueron borradas y se utiliza el manejo de erroes
--utilizado en las transacciones.



---Utilizar procedimiento insetar administrador

DROP PROCEDURE IF EXISTS [InsertarAdministrador]
GO

CREATE PROCEDURE [InsertarAdministrador] (
	@apeynom varchar(50) = null,
	@viveahi varchar(1) = null,
	@tel varchar(20) = null,
	@sexo varchar(1) = null,
	@fechnac datetime  = null
)
AS 
BEGIN
	
	INSERT INTO administrador (apeynom, viveahi, tel, sexo, fechnac) 
	VALUES (@apeynom, @viveahi, @tel, @sexo, @fechnac)
	
END


---Utilizar procedimiento insetar consorcio

DROP PROCEDURE IF EXISTS [InsertarConsorcio]
GO

CREATE PROCEDURE [InsertarConsorcio] (
	@idprovincia int = null,
	@idlocalidad int = null,
	@idconsorcio int = null,
	@nombre varchar(50) = null,
	@direccion varchar(250)  = null,
	@idzona int = null,
	@idconserje int = null

)
AS 
BEGIN
	INSERT INTO consorcio (idprovincia, idlocalidad, idconsorcio, nombre, direccion, idzona, idconserje, idadmin)
	VALUES (@idprovincia, @idlocalidad, @idconsorcio, @nombre, @direccion, @idzona, @idconserje,(SELECT IDENT_CURRENT('administrador')))
	--------------------------------------------------- El "IDENT_CURRENT" obtiene el ultimo valor identity utilizado. 
END

select * from administrador where idadmin = 200

---Utilizar procedimiento insetar gasto

DROP PROCEDURE IF EXISTS [InsertarGasto]
GO

CREATE PROCEDURE [InsertarGasto] (
	@idprovincia int = null,
	@idlocalidad int = null,
	@idconsorcio int = null,
	@periodo int = null,
	@fechapago datetime  = null,
	@idtipogasto int = null,
	@importe decimal(8,2) = null

)
AS 
BEGIN


	INSERT INTO gasto (idprovincia, idlocalidad, idconsorcio, periodo, fechapago, idtipogasto, importe)
	VALUES (@idprovincia, @idlocalidad, @idconsorcio, @periodo, @fechapago, @idtipogasto, @importe)
	
END





-------------------------TRIGGERS DE AUDITORIA---------------------------
--CREACIÓN DE TABLA AUXILIAR DE AUDITORÍA Y CREACIÓN DE TRIGGERS



--Creación de la tabla auditoriaGasto
CREATE TABLE auditoriaGasto
(idgasto                INT, 
 idprovincia			INT, 
 idlocalidad			int, 
 idconsorcio			int, 
 periodo				int, 
 fechapago				DATE, 
 idtipogasto			int,
 importe				decimal(8,2),
 fechayhora				date,
 usuario				varchar(50),
 tipoOperacion			varchar(50)
);
GO


---*Agregué un trigger de inserción para la tabla gasto



--Trigger para la operación de INSERT en la tabla gasto
CREATE TRIGGER tr_auditGasto_insert
ON gasto
AFTER INSERT
AS
BEGIN
        -- Registrar los valores antes de la modificación en una tabla auxiliar
        INSERT INTO auditoriaGasto
        SELECT  * , GETDATE(), SUSER_NAME(), 'Insert'
        FROM inserted;
END;
GO


--Trigger para la operación de UPDATE en la tabla gasto
CREATE TRIGGER tr_auditGasto_update
ON gasto
AFTER UPDATE
AS
BEGIN
        -- Registrar los valores antes de la modificación en una tabla auxiliar
        INSERT INTO auditoriaGasto
        SELECT  * , GETDATE(), SUSER_NAME(), 'Update'
        FROM deleted;
END;
GO


--Trigger para la operación de DELETE en la tabla gasto
CREATE TRIGGER tr_auditGasto_delete
ON gasto
AFTER DELETE
AS
BEGIN
    -- Registrar los valores antes de la eliminación en una tabla auxiliar
    INSERT INTO auditoriaGasto
    SELECT * , GETDATE(),SUSER_NAME(), 'Delete'
    FROM deleted;
END
GO


--------------------------------------VISTAS--------------------------------------------
--CREATE VIEW vista_adm_gasto_consorcio2 WITH SCHEMABINDING AS
--	SELECT
--		a.apeynom as nombre_admin,
--		c.nombre as nombre_consorcio,
--		g.idgasto as idGasto,
--		g.periodo as periodo,													VISTA PROPUESTA POR LOS COMPAÑEROS
--		g.fechapago as fecha_pago,
--		tp.descripcion as tipo_gasto
--	FROM 
--		dbo.administrador a 
--		JOIN dbo.consorcio c ON a.idadmin = c.idadmin
--		JOIN dbo.gasto g ON c.idadmin = g.idconsorcio
--		JOIN dbo.tipogasto tp ON g.idtipogasto = tp.idtipogasto
--GO




-----Vista propuesta con campos de provinicia, localidad y dirección añadidos

CREATE VIEW vista_adm_gasto_consorcio WITH SCHEMABINDING AS
	SELECT 
		a.apeynom as 'Administrador',
		p.descripcion as 'Provincia',
		l.descripcion as 'Localidad',
		c.direccion as 'Direccion',
		c.nombre as 'Consorcio',
		g.idgasto as 'Gasto_Nro',
		g.periodo as 'Periodo', 
		g.fechapago as 'Fecha de Pago'  
	FROM dbo.gasto g 
		inner join dbo.consorcio c on g.idconsorcio = c.idconsorcio and g.idprovincia = c.idprovincia and  g.idlocalidad = c.idlocalidad
		inner join dbo.localidad l on l.idlocalidad = c.idlocalidad and l.idprovincia = c.idprovincia
		inner join dbo.provincia p on p.idprovincia = l.idprovincia
		inner join dbo.administrador a on a.idadmin = c.idadmin
go



-------------------------TRANSACCIONES CON INTEGRACION DE TEMAS----------------------------------

--*Para los inserts se toma el idprovincia = 7 que corresponde a Corrientes y que no tiene ningun registro asociado.


---Con error en la transacción---
SET LANGUAGE Spanish;

BEGIN TRY
	BEGIN TRAN

	---Inserción registro administrador
	EXEC InsertarAdministrador   

	---Inserción registro consorcio
	EXEC InsertarConsorcio 7, 7, 1, 'EDIFICIO-24500', '9 de julio Nº 1650', 2, Null


	--Inserción 3 registros gasto
	
	EXEC InsertarGasto 30, 7, 1,1,'20231005',2,5000.00
	
	EXEC InsertarGasto 7, 7, 1,1,'20231015',2,20000.00

	EXEC InsertarGasto 7, 7, 1,1,'20231028',2,10000.00

	
	COMMIT TRAN
END TRY

BEGIN CATCH
	SELECT ERROR_MESSAGE() As Error-- Se captura el error y lo muestra.
	ROLLBACK TRAN
END CATCH

--Controlar insercion administrador
select top 1 * from administrador order by idadmin desc

--Controlar insercion administrador
select  * from consorcio where idprovincia = 7

--Controlar insercion 
select top 1 * from gasto order by idgasto desc




---Sin error en la transacción---
SET LANGUAGE Spanish;

BEGIN TRY
	BEGIN TRAN

	---Inserción registro administrador
	EXEC InsertarAdministrador 'Edinson Cavani', 'S', '3794000102', 'M', '19890625'

	---Inserción registro consorcio
	EXEC InsertarConsorcio 7, 7, 1, 'EDIFICIO-24500', '9 de julio Nº 1650', 2, Null


	--Inserción 3 registros gasto
	
	EXEC InsertarGasto 7, 7, 1,1,'20231121',2,5000.00
	
	EXEC InsertarGasto 7, 7, 1,1,'20231122',2,20000.00

	EXEC InsertarGasto 7, 7, 1,1,'20231123',2,14545.00

	
	COMMIT TRAN
END TRY

BEGIN CATCH
	SELECT ERROR_MESSAGE() As Error-- Se captura el error y lo muestra.
	ROLLBACK TRAN
END CATCH



---Verificar el trigger de inserción 
select * from gasto
select * from vista_adm_gasto_consorcio
select * from auditoriaGasto


----Verificar el tigger de update
UPDATE gasto SET importe =305 WHERE  idprovincia = 7;

select * from gasto
select * from vista_adm_gasto_consorcio
select * from auditoriaGasto



---Verificar el trigger de eliminacion
delete from gasto where idprovincia = 7

select * from gasto
select * from vista_adm_gasto_consorcio
select * from auditoriaGasto


