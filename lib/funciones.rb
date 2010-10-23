# author: Adrián García
# program under the license GPL v3

def clear
  # Función que limpia la pantalla
  printf "\e[H\e[2J"
end



def time
# Función que devuelve la fecha actual en formato string
  return Time.new.strftime "%d/%m/%y"
end



def printall(lista)
  col_negrita="\e[1m"
  col_magenta="\e[35m"
  col_green="\e[32m"
  col_red="\e[31m"
  col_normal="\e[0m"
  #Imprime la pantalla básica con la cuenta de frases y el menú
  clear
  printf col_negrita
  puts "#{$title} #{$version}"
  "#{$title} #{$version}".size.times{printf "-"} #imprime una linea de guiones
  puts "\n\n#{col_normal}"
  i=1
  lista.keys.each do |key|
    printf "#{col_negrita+col_magenta}#{i}#{col_normal} #{key} ->"
    puts "#{col_negrita+col_green}#{lista.getval(key)}#{col_normal}"
    i+=1
  end
  if lista.getcombob
    printf "\nC-C-C-COMBO BREAKER!!! >> "
    puts "#{col_negrita+col_red}#{lista.getcombob}#{col_normal}"
  end
  puts "TOTAL: #{col_negrita+col_red}#{lista.gettotal}#{col_normal}"
  printf "\nq=salir / a=añadir / d=eliminar / c=cambiar_frase /"
  printf " p=gráfica_de_estadísticas / ps=guardar_gráfica_.svg /"
  printf " pe=guardar_gráfica_.eps / 1..n=incrementar_frase_n\n>> "
end



def marshalload(filename)
  f=File.open(filename,"r")
  objeto=Marshal.load f.read
  f.close
  return objeto
end



def marshalsave(filename,objeto)
  f=File.open(filename,"w")
  f.write Marshal.dump objeto
  f.close
end


