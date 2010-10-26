#!/usr/bin/env ruby1.8
# author: Adrián García
# program under the license GPL v3
$title="AGAFRAS cuenta-frases"
$version="2.2.1"
require 'lib/classfrases-base'
require 'lib/classfrases-modificadores'
require 'lib/funciones'
require 'readline'

def main
  if ARGV.size>=1
    # Extrae datos del archivo si existe
    raise ArgumentError,'El archivo de datos debe ser .dat' unless /\.dat$/.match ARGV[0]
    if File.exists? ARGV[0]
      lista=marshalload(ARGV[0])
      # Actualizamos los datos si eran de una versión anterior del programa
      lista.retrocompatiblidad
    else
      lista=Frases.new
    end
  else
    # Si no se especifica archivo crea una lista nueva
    lista=Frases.new
  end

  begin # BUCLE PRINCIPAL DEL PROGRAMA
    marshalsave(ARGV[0]+'.backup',lista) if ARGV.size>=1
    printall lista
    op=Readline.readline('',true).downcase

    # Añade una nueva frase
    if op=='a'
      lista.add Readline.readline('Frase a añadir: ',true)

    # Borra una frase
    elsif op=='d'
      lista.deln Readline.readline('Número de frase a borrar: ',true).to_i

    # Cambia una frase manteniendo el contador
    elsif op=='c'
      n=Readline.readline('Número de frase a cambiar: ',true).to_i
      if n>=1 and n<=lista.size
        lista.changefn n,Readline.readline('Nueva frase: ',true)
      end

    # Imprime gráfica en pantalla
    elsif op=='p'
      if ARGV.size>=1
        lista.plot ARGV[0].gsub(/\..{2,3}$/,"")+"-"+time
      else
        lista.plot
      end

    # Imprime gráfica en archivo
    elsif op=='ps' or op=='pe'
      printf 'Intoduce el nombre de la gráfica a guardar'
      printf ' (en blanco para nombre automático)' if ARGV.size>=1
      nameestats=Readline.readline("\nNombre: ",true)
      if nameestats.empty? and ARGV.size>=1
        nameestats=ARGV[0].gsub(/\.dat$/,"")+"."+time.gsub("/","-")
      end
      fileestats=nameestats + (op=='ps'?'.svg':'.eps')
      lista.plot(nameestats,fileestats) if not nameestats.empty?
    # Busca números separados por espacios
    else
      op.split(" ").each do |ns|
        if /(^||\s||-)\d+-\d+($||\s||-)/.match ns
          lista.inccombob
          ns.split("-").each do |nc|
            lista.incn(nc.to_i) if nc.to_i>=1 and nc.to_i<=lista.size
          end
        else
          lista.incn(ns.to_i) if ns.to_i>=1 and ns.to_i<=lista.size
        end
      end
    end
  end while op!='q' # FIN DEL BUCLE PRINCIPAL DEL PROGRAMA

  File.delete ARGV[0]+'.backup' if ARGV.size>=1
  # Guarda datos en el archivo antes de salir
  marshalsave(ARGV[0],lista) if ARGV.size>=1
end


# Comprueba que no esté cargado como librería y si no lo está ejecuta main
if __FILE__ == $0
  main
end

