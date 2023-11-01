--Insertar un registro en Administrador, luego otro registro en consorcio 
--y por último 3 registros en gasto, correspondiente a ese nuevo consorcio.

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
------------------------------------------------------------------------------------------------------------------

---Sin error en la transacción---
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
	VALUES (7, 7, 1,1,'20231005',2,5000.00)

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
------------------------------------------------------------------------------------------------------------------





-------TRANSACCIONES ANIDADAS-------

---Con error en la transacción---
SET LANGUAGE Spanish; 

BEGIN TRY
	BEGIN TRAN TS_Anidadas
	SELECT CONCAT('El nivel de anidamiento es ', @@TRANCOUNT) As 'Numero de anidamientos' --Esta sentencia cuenta el número de transacciones anidadas
		BEGIN TRAN TS_InsertarAdmin
			--Inserción registro administrador
			SELECT CONCAT('El nivel de anidamiento es ', @@TRANCOUNT) As 'Numero de anidamientos'
			INSERT INTO administrador(apeynom,viveahi,tel,sexo,fechnac) values ('Juan José Paso', 'S', '3794000102', 'M', '19890625')
		COMMIT TRAN TS_InsertarAdmin	
		BEGIN TRAN TS_InsertarConsorcio
			--Inserción registro consorcio
			SELECT CONCAT('El nivel de anidamiento es ', @@TRANCOUNT) As 'Numero de anidamientos'
			INSERT INTO consorcio(idprovincia,idlocalidad,idconsorcio, Nombre,direccion,idzona,idconserje,idadmin)
			VALUES (7, 7, 2, 'EDIFICIO-24500', '9 de julio Nº 1650', 2, Null, (select top 1 idadmin from administrador order by idadmin desc))
			--Para insertar el id del último administrador se hace un select del ultimo id de administrador insertado.
			
			BEGIN TRAN TS_InsertarGastos
				SELECT CONCAT('El nivel de anidamiento es ', @@TRANCOUNT) As 'Numero de anidamientos'
				--Inserción 3 registros de gastos
				INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
				VALUES (7, 7, 2,1,'20231005',2,5000.00)

				INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
				VALUES (7, 7, 2,1,'20231015',2,20000.00)

				INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
				VALUES (7, 7, 10,1,'20231028',2,10000.00)
			COMMIT TRAN TS_InsertarGastos
		COMMIT TRAN TS_InsertarConsorcio


	COMMIT TRAN TS_Anidadas
END TRY

BEGIN CATCH
	SELECT ERROR_MESSAGE() As Error -- Se captura el error y lo muestra.
	ROLLBACK TRAN TS_Anidadas
END CATCH


 ---Controlar la realizacion de las inserciones----------------------------------------------------------------------------------
select * from administrador where apeynom = 'Juan José Paso'
select * from consorcio where idprovincia = 7  and idconsorcio = 10 --No existe el consorcio n° 10 en la provincia de Corrientes
select * from gasto where idprovincia = 7 and idconsorcio = 10
---------------------------------------------------------------------------------------------------------------------------------

---Sin error en la transacción---
SET LANGUAGE Spanish; 

BEGIN TRY
	BEGIN TRAN TS_Anidadas
	SELECT CONCAT('El nivel de anidamiento es ', @@TRANCOUNT) As 'Numero de anidamientos' --Esta sentencia cuenta el número de transacciones anidadas
		BEGIN TRAN TS_InsertarAdmin
			--Inserción registro administrador
			SELECT CONCAT('El nivel de anidamiento es ', @@TRANCOUNT) As 'Numero de anidamientos'
			INSERT INTO administrador(apeynom,viveahi,tel,sexo,fechnac) values ('Juan José Paso', 'S', '3794000102', 'M', '19890625')
		COMMIT TRAN TS_InsertarAdmin	
		BEGIN TRAN TS_InsertarConsorcio
			--Inserción registro consorcio
			SELECT CONCAT('El nivel de anidamiento es ', @@TRANCOUNT) As 'Numero de anidamientos'
			INSERT INTO consorcio(idprovincia,idlocalidad,idconsorcio, Nombre,direccion,idzona,idconserje,idadmin)
			VALUES (7, 7, 2, 'EDIFICIO-24500', '9 de julio Nº 1650', 2, Null, (select top 1 idadmin from administrador order by idadmin desc))
			--Para insertar el id del último administrador se hace un select del ultimo id de administrador insertado.
			
			BEGIN TRAN TS_InsertarGastos
				SELECT CONCAT('El nivel de anidamiento es ', @@TRANCOUNT) As 'Numero de anidamientos'
				--Inserción 3 registros de gastos
				INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
				VALUES (7, 7, 2,1,'20231005',2,5000.00)

				INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
				VALUES (7, 7, 2,1,'20231015',2,20000.00)

				INSERT INTO gasto (idprovincia,idlocalidad,idconsorcio,periodo,fechapago,idtipogasto,importe) 
				VALUES (7, 7, 2,1,'20231028',2,10000.00)
			COMMIT TRAN TS_InsertarGastos
		COMMIT TRAN TS_InsertarConsorcio


	COMMIT TRAN TS_Anidadas
END TRY

BEGIN CATCH
	SELECT ERROR_MESSAGE() As Error -- Se captura el error y lo muestra.
	ROLLBACK TRAN TS_Anidadas
END CATCH


 ---Controlar la realizacion de las inserciones------------------------------------------------------------------------------------------------
select * from administrador where apeynom = 'Juan José Paso'
select * from consorcio where idprovincia = 7  and idconsorcio = 2 --No existe el consorcio n° 2 hasta el momento en la provincia de Corrientes
select * from gasto where idprovincia = 7 and idconsorcio = 2
----------------------------------------------------
