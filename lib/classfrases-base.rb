# author: Adrián García
# program under the license GPL v3
require 'lib/rdp-gnuplot'

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



  def plot(name=nil,file=nil)
    # Usando gnuplot hace una gráfica con las estadísticas
    return if size<=0
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        #plot.xrange "[-10:10]"
        if file
          if /\.svg$/.match file
            plot.terminal 'svg size 1280 720' # imprime a .svg
          else
            # NOTE ¿eliminar color al .ps?
            plot.terminal 'postscript eps enhanced color' # imprime a .ps
          end
          plot.output file
          plot.set 'object 1 rect from screen 0,0,0 to screen 1,1,0 behind'
          plot.set 'object 1 rect fc rgb "white" fillstyle solid 1.0'
        end
        if name
          plot.title name
        else
          plot.title "#{$title} #{$version}"
        end
        plot.ylabel 'Repeticiones'
        plot.xlabel 'Día'

        
        plot.autoscale
        plot.set 'auto x'
        plot.xdata 'time' # establece que los datos del eje x son fechas
        plot.timefmt '"%d/%m/%y"' # establece como recoger fecha
        plot.format 'x "%d/%m/%y"' # establece como mostrar fecha
        plot.xtics 'nomirror rotate by -60' # gira las fechas del eje x
        #plot.xrange "[\"#{@dias.first}\":\"#{@dias.last}\"]"
        diascom=@dias

        @frases.size.times do |i|
          segundia=Array.new
          @dias.size.times do |j|
            segundia.push @tabla[j][i]
          end
          plot.data << Gnuplot::DataSet.new([diascom,segundia]) do |ds|
            ds.using='1:2'
            ds.with='linespoints'
            ds.title=@frases[i]
          end
        end
        plot.data << Gnuplot::DataSet.new([diascom,@combob]) do |ds|
          ds.using='1:2'
          ds.with='linespoints'
          ds.title='C-C-C-COMBO BREAKER!!!'
        end
        plot.data << Gnuplot::DataSet.new([diascom,getarraytotal]) do |ds|
          ds.using='1:2'
          ds.with='linespoints'
          ds.title='TOTAL'
        end

      end
    end
  end


end


