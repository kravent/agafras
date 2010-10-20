#!/usr/bin/env ruby1.8
# dependences: ruby1.8 libgnuplot-ruby1.8
# author: Adrián García
# version: 2.0
# program under the license GPL v3
require 'gnuplot'
$title="AGAFRAS cuenta-frases"


def clear
  # Función que limpia la pantalla
  printf "\e[H\e[2J"
end

#Variable global que contiene la fecha en la que se ejecuta el programa
$time=Time.new.strftime "%d/%m/%y"

# Clase que gestiona la lista de frases con sus contadores
class Frases
  def initialize
    # Es lla mado al crar un nuevo objeto de la clase
    # Inicializa la lista de frases vacía
    @dias=Array.new
    @frases=Array.new
    @tabla=Array.new
    @combob=nil
  end
  def crearsubarraystr(str)
    if not @frases.include? str
      @frases.push str
      @dias.size.times do |i|
        @tabla[i].push(0)
      end
    end
  end
  def crearsubarraydia(datestr)
    if not @dias.include? datestr
      @dias.push datestr
      @tabla.push Array.new
      @frases.size.times do |i|
        @tabla[posdia(datestr)].push(0)
      end
    end
  end
  def posstr(str)
    return @frases.rindex str
  end
  def posdia(date)
    return @dias.rindex date
  end
  def size
    # Devuelve cantidad de frases
    @frases.size
  end
  def add(str)
    # Añade una nueva frase inicializando el contador a 0
    crearsubarraystr str
    crearsubarraydia $time
  end
  def deln(n)
    # Borra la frase número n
    if n>=1 and n<=@frases.size
      @frases.delete_at(n-1)
      @dias.size.times do |i|
        @tabla[i].delete_at(n-1)
      end
    end
  end
  def incn(n)
    # Incrementa el contador de la frase número n
    crearsubarraydia $time
    @tabla[posdia($time)][n-1]+=1
  end
  def inccombob
    if @combob
      @combob+=1
    else
      @combob=1
    end
  end
  def keys
    # Devuelve un vector con las frases guardadas
    return @frases
  end
  def getval(str)
    # Devuelve el contador de la frase igual a str
    # (la suma del total de todos los dias)
    tot=0
    @dias.size.times do |i|
      tot+=@tabla[i][posstr(str)]
    end
    return tot
  end
  def getcombob
    return @combob
  end
  def changefn(n,str)
    # Cambia la frase número n de nombre manteniendo su contador
    @frases[n-1]=str
  end
  def plot # Usando gnuplot hace una gráfica con las estadísticas
    diasn=(1..@dias.size).to_a
    #diasn=@dias.collect{|x|x.split("/").reverse.join("").to_i}
    # diasn contiene el array de dias pero en forma de int
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        #plot.xrange "[-10:10]"
        plot.title $title
        plot.ylabel "Repeticiones"
        plot.xlabel "Día"
        #plot.xrange "[#{diasn.first}:#{diasn.last}]"
        @frases.size.times do |i|
          segundia=Array.new
          @dias.size.times do |j|
            segundia.push @tabla[j][i]
          end
          plot.data << Gnuplot::DataSet.new([diasn,segundia]) do |ds|
            ds.with="linespoints"
            ds.title=@frases[i]
          end
        end
      end
    end
  end
end



def printall(lista)
  #Imprime la pantalla básica con la cuenta de frases y el menú
  clear
  puts "  " + $title
  printf "  "
  $title.size.times{printf "-"}
  puts "\n"
  i=1
  lista.keys.each do |key|
    puts "#{i} #{key} -> #{lista.getval(key)}"
    i+=1
  end
  puts "C-C-C-COMBO BREAKER!!! (#{lista.getcombob})"if lista.getcombob
  printf "\nq=salir / a=añadir / d=eliminar / c=cambiar_frase /"
  printf " p=gráfica_de_estadísticas / 1..n=incrementar_frase_n\n>> "
end



def main
  if ARGV.size>=1 and File.exists? ARGV[0]
    # Extrae datos del archivo si existe
    f=File.open(ARGV[0],"r")
    lista=Marshal.load f.read
    f.close
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

