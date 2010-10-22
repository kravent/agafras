
class Frases

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

end


