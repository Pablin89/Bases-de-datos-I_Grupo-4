Use base_consorcio;



--Insertar un registro en Administrador, luego otro registro en consorcio 
--y por último 3 registros en gasto, correspondiente a ese nuevo consorcio.

BEGIN TRY
	BEGIN TRAN


	--Inserción registro administrador
	INSERT INTO administrador(idadmin,apeynom,viveahi,tel,sexo,fechnac) values (1,'Juan Pablo Duete', 'S', '3794000102', 'M', '19890625')


	--Inserción registro consorcio
	INSERT INTO consorcio(idprovincia,idlocalidad,idconsorcio, Nombre,direccion,idzona,idconserje,idadmin)
	VALUES (7, 7, 1, 'EDIFICIO-24500', '9 de julio Nº 1650', 2, Null, (select top 1 idadmin from administrador order by idadmin desc))
	--Para insertar el id del último administrador se hace un select del ultimo id de administrador insertado.
	
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
	SELECT ERROR_MESSAGE() -- Se captura el error y lo muestra.
	ROLLBACK TRAN
END CATCH
