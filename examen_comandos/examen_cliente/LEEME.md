# Cliente del examen (guardado aquí hasta el día del examen)

`examen_comandos/` es lo que ejecutan los alumnos en el examen. Vive aquí, en el repo privado,
para que no lo vean antes de tiempo en `som_clientes`, que es público.

**El día del examen**, súbelo a `som_clientes`:

```bash
cp -r examen_comandos ~/som_clientes/
cp README-som_clientes.md ~/som_clientes/README.md   # añade la fila de examen_comandos
cd ~/som_clientes && git add -A && git commit -m "examen_comandos" && git push
```

Los alumnos: `cd ~/som_clientes && git pull && cd examen_comandos && bash instalar.sh`.
El examen usa los niveles de `../prueba_comandos/lib`, así que tiene que estar dentro de `som_clientes`.
