SELECT * FROM alumnos;
SELECT * FROM asignaturas;
SELECT * FROM curso;
SELECT * FROM periodo;
SELECT * FROM profesores;
SELECT * FROM detallecurso;

/*ALFONSO SERRANO
Consultar las materias que dicta cada profesor*/
SELECT asig.NombreMateria AS Materia, CONCAT(pr.nombre, pr.apellido) AS "Nombre de Profesor"
FROM asignaturas asig
INNER JOIN profesores pr
ON asig.Profesores_idProfesores = pr.idProfesores;

/*ALFONSO SERRANO
Consulta INNER JOIN para saber a que curso pertenece cada alumno*/
SELECT DISTINCT al.IdAlumnos, concat(al.Nombres, " ", al. Apellidos), c.idAcurso AS "Numero de Curso "
FROM curso c
INNER JOIN detallecurso dc
ON dc.curso_idAcurso = c.idAcurso
INNER JOIN alumnos al
ON dc.Alumnos_IdAlumnos = al.IdAlumnos;

/*CRISTIAN HENAO
Consulta para sacar un listado de los alumnos con base a la calificacion de cada uno, ordenado por el nombre, periodo y calificacion*/
select alm.nombres as Nombre, alm.apellidos as Apedillo, asg.nombremateria as Materia, periodo_idperiodo as Periodo, dc.calificacion as Calificación
from detallecurso dc
inner join asignaturas asg
on (dc.Asignaturas_idAsignaturas = asg.idAsignaturas)
inner join alumnos alm
on (dc.Alumnos_IdAlumnos = alm.idalumnos)
where calificacion = 5
order by nombres, nombremateria, periodo_idperiodo;

/*MARCO DONCEL
CONSULTA PARA SACAR LAS MATERIAS  QUE CURSA  UN ESTUDIANTE*/
SELECT DISTINCT  CONCAT(al.Nombres, ' ', al.Apellidos)AS " Nombre" ,c.numeroCurso AS "Curso", 
ass.NombreMateria AS "MATERIAS DE "  
FROM asignaturas ass  
INNER JOIN detallecurso dc 
ON dc.Asignaturas_idAsignaturas = ass.idAsignaturas 
INNER JOIN alumnos al 
ON al.IdAlumnos=dc.Alumnos_IdAlumnos 
INNER JOIN curso c 
ON dc.curso_idAcurso = c.idAcurso 
INNER JOIN periodo p 
ON dc.periodo_idperiodo = p.idperiodo  
WHERE dc.Alumnos_IdAlumnos = 200002;    

/*LUIS PATIÑO
CONSULTA PARA SACAR LOS ESTUDIANTES EXTRANJEROS y cantidad de los mismos según documento*/
SELECT DISTINCT a.IdAlumnos,c.numeroCurso as Curso,CONCAT(a.Nombres, ' ', a.Apellidos) AS Estudiante,a.NDocumento AS NumeroDocumento,   
tp.nombreDocumento as TipoDocumento   
FROM  detallecurso dc 
INNER JOIN curso c 
ON dc.curso_idAcurso= c.idAcurso 
INNER JOIN alumnos a   
ON dc.Alumnos_IdAlumnos = a.IdAlumnos 
INNER JOIN tipodocumento tp 
ON tp.IdTipoDocumento = a.tipoDocumento_IdTipoDocumento   
WHERE tp.IdTipoDocumento BETWEEN 3 AND 5 
UNION ALL   
SELECT '','','',tp.nombreDocumento as TipoDocumento, count(tp.IdTipoDocumento) as Cantidad   
FROM tipodocumento tp   
INNER JOIN alumnos a   
ON tp.IdTipoDocumento = a.tipoDocumento_IdTipoDocumento   
WHERE tp.IdTipoDocumento =3 OR tp.IdTipoDocumento =4 OR tp.IdTipoDocumento =5   
GROUP BY tp.IdTipoDocumento   
UNION ALL   
SELECT '','','','TOTAL',count(a.Nombres)  
FROM tipodocumento tp  
INNER JOIN alumnos a  
ON tp.IdTipoDocumento = a.tipoDocumento_IdTipoDocumento  
WHERE tp.IdTipoDocumento BETWEEN 3 AND 5; 

/*LUIS PATIÑO - VISTA
CONSULTA PARA SACAR LOS PROFESORES EXTRANJEROS Y SU RESPECTIVA ASIGNATURA*/
create view ProfesoresExtranjeros as  
SELECT p.idProfesores AS IdProfesor, CONCAT(p.nombre,' ',p.apellido) AS Profesor, p.numeroDocumento AS NumeroDocumeto, 
tp.nombreDocumento as TipoDocumento 
FROM tipodocumento tp 
INNER JOIN profesores p 
ON tp.IdTipoDocumento=p.IdTipoDocumento 
where tp.IdTipoDocumento BETWEEN 3 AND 5; 
SELECT DISTINCT pext.idProfesor, pext.Profesor,asig.NombreMateria 
FROM ProfesoresExtranjeros pext 
INNER JOIN detallecurso dc 
ON pext.IdProfesor=dc.Profesores_idProfesores 
INNER JOIN asignaturas asig 
ON dc.Asignaturas_idAsignaturas=asig.idAsignaturas 
where  pext.TipoDocumento like ('Pasaporte') OR pext.TipoDocumento like ('Cedula de Extranjeria') or
pext.TipoDocumento like ('Permiso Diplomático'); 

/*JULIAN SIERRA
CONSULTA PARA FILTRAR POR PERIODO Y MATERIA ORDENANDO DEL MEJOR DESEMPEÑO AL PEOR USANDO VARIABLES 
CON FILTRO DE VALOR DE NOTA*/
SET @Periodo=4; 
SET @Asignatura='Español'; 
SET @Nota=4; 
SELECT A.Nombres, A.Apellidos, dc.calificacion, p.NumeroPeriodo as "Periodo", asg.NombreMateria as "Nombre Materia", c.numerocurso as "Curso" 
FROM detallecurso dc 
INNER JOIN alumnos A 
ON dc.Alumnos_idAlumnos = A.realizarPromedioIdAlumnos 
INNER JOIN Asignaturas asg 
ON asg.idAsignaturas = dc.Asignaturas_IdAsignaturas 
INNER JOIN curso c 
ON c.idAcurso = dc.curso_idAcurso 
INNER JOIN periodo p 
ON p.idperiodo = dc.periodo_idperiodo 
WHERE asg.NombreMateria=@Asignatura AND p.numeroperiodo = @Periodo AND dc.calificacion>=@Nota 
ORDER BY dc.calificacion DESC; 

/*JUAN HERNANDEZ
PROCEDURE para determinar el promedio de una materia específica de un estudiante en el año*/
CALL realizarPromedio(2000029,80007);

/*SEBASTIAN DÍAZ
Consulta promedio general todos los alumnos---CON CASE*/
SELECT curso.numeroCurso as Curso,concat(alumnos.Nombres," ",alumnos.Apellidos) as Nombre, ROUND(avg(calificacion),2) as Promedio,CASE
WHEN ROUND(avg(calificacion),2)>4 THEN 'Buen estudiante'
WHEN ROUND(avg(calificacion),2)<3 THEN 'MAL Estudiante'
ELSE 'Estudiante promedio'
END AS Descripcion
FROM detallecurso as dc
INNER JOIN curso
ON dc.curso_idAcurso=curso.idAcurso
INNER JOIN alumnos
ON dc.Alumnos_IdAlumnos=alumnos.IdAlumnos
INNER JOIN asignaturas
ON dc.Asignaturas_idAsignaturas=asignaturas.idAsignaturas
group by dc.Alumnos_IdAlumnos order BY promedio DESC; 

/*SEBASTIAN DÍAZ
Procedimiento para Actualizar la nota de un alumno, de una materia y periodo específico - STORE PROCEDURE*/
call colegio.Actualizar_Nota(80004, 100, 2000013, 4.5);

/*ALFONSO SERRANO
Consulta para validar nota de alumno en una materia y periodo específico - VALIDACION STORE PROCEDURE*/
SELECT  
	/*Id Alumno*/		al.IdAlumnos AS "Id Alumno",
	/*Nombre Alumno*/	concat(al.Nombres, " ", al.Apellidos) AS "Nombre Alumno", 
    /*Periodo*/  		pe.NumeroPeriodo AS "Periodo",
    /*Asignatura*/  	mat.NombreMateria AS "Asignatura",
    /*Calificacion*/  	calificacion AS "Calificacion"
FROM detallecurso dc
INNER JOIN alumnos al
ON al.IdAlumnos = dc.Alumnos_IdAlumnos
INNER JOIN periodo pe
ON pe.idperiodo = dc.periodo_idperiodo
INNER JOIN asignaturas mat
ON mat.idAsignaturas = dc.Asignaturas_idAsignaturas
/*Condicion*/ WHERE IdAlumnos = "2000013" AND idperiodo = "100" AND idAsignaturas = "80004"

/*PRESENTACIÓN DE MOCKUP POR PARTE DE JUAN TINOCO*/
