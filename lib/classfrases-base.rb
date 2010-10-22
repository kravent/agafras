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



  def plot(file=nil) # Usando gnuplot hace una gráfica con las estadísticas
    diasn=(1..@dias.size).to_a
    #diasn=@dias.collect{|x|x.split("/").reverse.join("").to_i}
    # diasn contiene el array de dias pero en forma de int
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        #plot.xrange "[-10:10]"
        if file
          plot.terminal 'postscript eps'
          plot.output file
        end
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


