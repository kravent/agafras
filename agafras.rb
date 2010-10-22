#!/usr/bin/env ruby1.8
# author: Adrián García
# program under the license GPL v3
$title="AGAFRAS cuenta-frases"
$version="2.0.4"
require 'lib/classfrases'
require 'lib/funciones'

def main
  if ARGV.size>=1 and File.exists? ARGV[0]
    # Extrae datos del archivo si existe
    f=File.open(ARGV[0],"r")
    lista=Marshal.load f.read
    f.close
    # Actualizamos los datos si eran de una versión anterior del programa
    lista.retrocompatiblidad
  else
    # Si no se especifica archivo crea una lista nueva
    lista=Frases.new
  end

  begin # BUCLE PRINCIPAL DEL PROGRAMA
    printall lista
    op=$stdin.gets.chomp.downcase
    if op=="a" # Añade una nueva frase
      printf "Frase a añadir: "
      lista.add $stdin.gets.chomp
    elsif op=="d" # Borra una frase
      printf "Número de frase a borrar: "
      lista.deln $stdin.gets.chomp.to_i
    elsif op=="c" # Cambia una frase manteniendo el contador
      printf "Número de frase a cambiar: "
      n=$stdin.gets.chomp.to_i
      if n>=1 and n<=lista.size
        printf "Nueva frase: "
        lista.changefn n,$stdin.gets.chomp
      end
    elsif op=="p"
      lista.plot
    else # Busca números separados por espacios
      op.split(" ").each do |ns|
        if /(^||\s||-)\d+-\d+($||\s||-)/.match ns
          lista.inccombob
          ns.split("-").each do |nc|
            lista.incn(ns.to_i) if ns.to_i>=1 and ns.to_i<=lista.size
          end
        else
          lista.incn(ns.to_i) if ns.to_i>=1 and ns.to_i<=lista.size
        end
      end
    end
  end while op!="q" # FIN DEL BUCLE PRINCIPAL DEL PROGRAMA

  if ARGV.size>=1
    # Guarda datos en el archivo antes de salir
    f=File.open(ARGV[0],"w")
    f.write Marshal.dump lista
    f.close
  end
end


# Comprueba que no esté cargado como librería y si no lo está ejecuta main
if __FILE__ == $0
  main
end

