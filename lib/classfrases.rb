# author: Adrián García
# program under the license GPL v3
require 'gnuplot'

# Clase que gestiona la lista de frases con sus contadores
class Frases
  def initialize
    # Es lla mado al crar un nuevo objeto de la clase
    # Inicializa la lista de frases vacía
    @version=$version
    @dias=Array.new
    @frases=Array.new
    @tabla=Array.new
    @combob=Array.new
  end
  def retrocompatiblidad
    # Actualiza datos cargados de versiones anteriores
    # version <= 2.0
    @version="2.0" if not @version
    if @version<"2.1"
      # Cambia @combob de int a array
      com=@combob
      @combob=Array.new
      @dias.size.times do |i|
        @combob.push com/@dias.size
        @combob[i] += com % @dias.size if i>=@dias.size-1
      end
      @version="2.1"
    end
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
      @combob.push 0
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
    crearsubarraydia time
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
    crearsubarraydia time
    @tabla[posdia(time)][n-1]+=1
  end
  def inccombob
    crearsubarraydia time
    @combob[posdia(time)]+=1
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
    tot=0
    @combob.each{|x|tot+=x}
    return tot
  end
  def gettotal
    tot=0
    @dias.size.times do |i|
      @frases.size.times do |j|
        tot+=@tabla[i][j]
      end
    end
    return tot
  end
  def getarraytotal
    tot=Array.new
    @dias.size.times do |i|
      subtot=0
      @tabla[i].each do |el|
        subtot+=el
      end
      tot.push subtot
    end
    return tot
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
        plot.title "#{$title} #{$version}"
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
        plot.data << Gnuplot::DataSet.new([diasn,@combob]) do |ds|
          ds.with="linespoints"
          ds.title="C-C-C-COMBO BREAKER!!!"
        end
        plot.data << Gnuplot::DataSet.new([diasn,getarraytotal]) do |ds|
          ds.with="linespoints"
          ds.title="TOTAL"
        end

      end
    end
  end
end

