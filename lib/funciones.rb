# author: Adrián García
# program under the license GPL v3

def clear
  # Función que limpia la pantalla
  printf "\e[H\e[2J"
end

# Función que devuelve la fecha actual en formato string
def time
  return Time.new.strftime "%d/%m/%y"
end

def printall(lista)
  col_negrita="\e[1m"
  col_normal="\e[0m"
  #Imprime la pantalla básica con la cuenta de frases y el menú
  clear
  printf col_negrita
  puts "  #{$title} #{$version}"
  "  #{$title} #{$version}".size.times{printf "-"} #imprime una linea de guiones
  puts "\n\n"
  printf col_normal
  i=1
  lista.keys.each do |key|
    puts "#{i} #{key} -> #{col_negrita}#{lista.getval(key)}#{col_normal}"
    i+=1
  end
  if lista.getcombob
    printf "\nC-C-C-COMBO BREAKER!!! >> "
    puts "#{col_negrita}#{lista.getcombob}#{col_normal}"
  end
  puts "TOTAL: #{col_negrita}#{lista.gettotal}#{col_normal}"
  printf "\nq=salir / a=añadir / d=eliminar / c=cambiar_frase /"
  printf " p=gráfica_de_estadísticas / 1..n=incrementar_frase_n\n>> "
end

