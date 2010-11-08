# author: Adrián García
# program under the license GPL v3
require 'gtk2'

class AgaInterfaz

  def select_filedat
    dialog=Gtk::FileChooserDialog.new('Abrir archivo',$window,
                                      Gtk::FileChooser::ACTION_OPEN,nil,
                                      [Gtk::Stock::CANCEL,
                                        Gtk::Dialog::RESPONSE_CANCEL],
                                      [Gtk::Stock::OK,
                                        Gtk::Dialog::RESPONSE_ACCEPT]
                                     )
    filter=Gtk::FileFilter.new
    filter.name='Archivo de datos (.dat)'
    filter.add_pattern '*.dat'
    dialog.add_filter filter
    filter=Gtk::FileFilter.new
    filter.name='Todos los archivos'
    filter.add_pattern '*'
    dialog.add_filter filter
    dialog.run do |response|
      if response==Gtk::Dialog::RESPONSE_ACCEPT
        $filedat=dialog.filename
        $lista=marshalload($filedat)
        $lista.retrocompatiblidad
        $changed=false
        actualiza_lista
      end
      dialog.destroy
    end
  end
  def cargadat
    if $changed
      #TODO preguntar: guardar y salir / salir sin guardar / cancelar
      dialog=Gtk::Dialog.new('Abrir archivo',@window,
                             Gtk::Dialog::DESTROY_WITH_PARENT,
                             [Gtk::Stock::OK,Gtk::Dialog::RESPONSE_ACCEPT],
                             [Gtk::Stock::CANCEL,Gtk::Dialog::RESPONSE_REJECT])
      image=Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
      hbox=Gtk::HBox.new false,10
      hbox.border_width=10
      hbox.pack_start image
      hbox.pack_start Gtk::Label.new 'Los datos no han sido guardados en ' <<
        "un archivo.\nSi abres otro archivo perderás estos datos.\n" <<
        '¿Estás seguro de que deseas abrir otro archivo?'
      dialog.vbox.add hbox
      dialog.show_all
      dialog.run do |response|
        if response==Gtk::Dialog::RESPONSE_ACCEPT
          select_filedat
        end
        dialog.destroy
      end
    else
      select_filedat
    end
  end


  def gtk_close
    File.delete $filedat+'.backup' if $filedat and
                                      File.exists? $filedat+'.backup'
    Gtk.main_quit
  end
  def cerrar
    if $changed
      #TODO preguntar: guardar y salir / salir sin guardar / cancelar
      dialog=Gtk::Dialog.new('Cerrar',@window,
                             Gtk::Dialog::DESTROY_WITH_PARENT,
                             [Gtk::Stock::OK,Gtk::Dialog::RESPONSE_ACCEPT],
                             [Gtk::Stock::CANCEL,Gtk::Dialog::RESPONSE_REJECT])
      image=Gtk::Image.new(Gtk::Stock::DIALOG_WARNING, Gtk::IconSize::DIALOG)
      hbox=Gtk::HBox.new false,10
      hbox.border_width=10
      hbox.pack_start image
      hbox.pack_start Gtk::Label.new 'Los datos no han sido guardados en ' <<
        "un archivo.\n¿Estás seguro de que deseas salir?"
      dialog.vbox.add hbox
      dialog.show_all
      dialog.run do |response|
        if response==Gtk::Dialog::RESPONSE_ACCEPT
          gtk_close
        end
        dialog.destroy
      end
    else
      gtk_close
    end
  end

  def save_tofile
    $changed=false
    marshalsave($filedat,$lista)
  end

  def save
    unless $filedat
      dialog=Gtk::FileChooserDialog.new('Abrir archivo',$window,
                                        Gtk::FileChooser::ACTION_SAVE,nil,
                                        [Gtk::Stock::CANCEL,
                                          Gtk::Dialog::RESPONSE_CANCEL],
                                        [Gtk::Stock::OK,
                                          Gtk::Dialog::RESPONSE_ACCEPT]
                                       )
      filter=Gtk::FileFilter.new
      filter.name='Archivo de datos (.dat)'
      filter.add_pattern '*.dat'
      dialog.add_filter filter
      filter=Gtk::FileFilter.new
      filter.name='Todos los archivos'
      filter.add_pattern '*'
      dialog.add_filter filter
      dialog.run do |response|
        if response==Gtk::Dialog::RESPONSE_ACCEPT
          $filedat=dialog.filename
          save_tofile
        end
        dialog.destroy
      end
    else
      save_tofile
    end
  end

  def plotsave tipo_grafica
    filter_pattern='*.png'
    dialog=Gtk::Dialog.new('Guardar gráfica',$window,
                           Gtk::Dialog::DESTROY_WITH_PARENT,
                           [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                           [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT]
                          )

    filechooser=Gtk::FileChooserWidget.new(Gtk::FileChooser::ACTION_SAVE,nil)
    filter=Gtk::FileFilter.new
    filter.name="Archivo de imagen (#{filter_pattern})"
    filter.add_pattern filter_pattern
    filechooser.add_filter filter

    tamx=Gtk::SpinButton.new(400,20000,1)
    tamy=Gtk::SpinButton.new(200,10000,1)
    tamx.value=2000
    tamy.value=1000
    hbox=Gtk::HBox.new false,5
    hbox.pack_start Gtk::Label.new 'Tamaño: ',false
    hbox.pack_start tamx,false
    hbox.pack_start Gtk::Label.new 'X',false
    hbox.pack_start tamy,false
    
    hboxmain=Gtk::HBox.new false,5
    hboxmain.pack_start hbox,false

    vbox=Gtk::VBox.new false,10
    vbox.border_width=10
    vbox.pack_start hboxmain,false
    vbox.pack_start Gtk::HSeparator.new,false
    vbox.pack_start filechooser

    dialog.vbox.pack_start vbox
    dialog.show_all

    dialog.run do |response|
      if response==Gtk::Dialog::RESPONSE_ACCEPT and
        if filechooser.filename.empty?
          puts 'No se puede guardar en archivo vacío'
          #TODO mostrar mensaje de error
        else
          if /#{filter_pattern.gsub('*','')}$/.match filechooser.filename
            file=filechooser.filename
          else
            file=filechooser.filename+filter_pattern.gsub('*','')
          end
          $lista.plot_gruff(file,tipo_grafica,"#{tamx.value}x#{tamy.value}")
        end
      end
      dialog.destroy
    end
  end

  def add
    dialog=Gtk::Dialog.new('Añadir frase',@window,
                           Gtk::Dialog::DESTROY_WITH_PARENT,
                           [Gtk::Stock::OK,Gtk::Dialog::RESPONSE_ACCEPT],
                           [Gtk::Stock::CANCEL,Gtk::Dialog::RESPONSE_REJECT])
    entry=Gtk::Entry.new
    image=Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
    vbox=Gtk::VBox.new false,10
    vbox.pack_start Gtk::Label.new 'Introduzca la nueva frase:'
    vbox.pack_start entry
    hbox=Gtk::HBox.new false,10
    hbox.border_width=10
    hbox.pack_start image
    hbox.pack_start vbox
    dialog.vbox.add hbox
    dialog.show_all
    dialog.run do |response|
      if response==Gtk::Dialog::RESPONSE_ACCEPT
        $lista.add entry.text
        $changed=true
        actualiza_lista
      end
      dialog.destroy
    end
  end
  
  def renombrar_datos
    dialog=Gtk::Dialog.new('Nombre de los datos',@window,
                           Gtk::Dialog::DESTROY_WITH_PARENT,
                           [Gtk::Stock::OK,Gtk::Dialog::RESPONSE_ACCEPT],
                           [Gtk::Stock::CANCEL,Gtk::Dialog::RESPONSE_REJECT])
    entry=Gtk::Entry.new
    entry.text=$lista.nombre
    image=Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
    vbox=Gtk::VBox.new false,10
    vbox.pack_start Gtk::Label.new 'Introduzca el nombre de los datos:'
    vbox.pack_start entry
    hbox=Gtk::HBox.new false,10
    hbox.border_width=10
    hbox.pack_start image
    hbox.pack_start vbox
    dialog.vbox.add hbox
    dialog.show_all
    dialog.run do |response|
      if response==Gtk::Dialog::RESPONSE_ACCEPT
        $lista.nombre=entry.text if !entry.text.empty?
        actualiza_lista
      end
      dialog.destroy
    end
  end


  def del
    dialog=Gtk::Dialog.new('Eliminar frase',@window,
                           Gtk::Dialog::DESTROY_WITH_PARENT,
                           [Gtk::Stock::OK,Gtk::Dialog::RESPONSE_ACCEPT],
                           [Gtk::Stock::CANCEL,Gtk::Dialog::RESPONSE_REJECT])
    image=Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
    vbox=Gtk::VBox.new false,10
    combobox=Gtk::ComboBox.new
    $lista.keys.each_with_index do |frase,i|
      combobox.append_text frase
    end
    vbox.pack_start Gtk::Label.new 'Frase a eliminar:'
    vbox.pack_start combobox
    hbox=Gtk::HBox.new false,10
    hbox.border_width=10
    hbox.pack_start image
    hbox.pack_start vbox
    dialog.vbox.add hbox
    dialog.show_all
    dialog.run do |response|
      if response==Gtk::Dialog::RESPONSE_ACCEPT and combobox.active>=0
        $lista.deln combobox.active+1
        $changed=true
        actualiza_lista
      end
      dialog.destroy
    end
  end

  def cambia
    dialog=Gtk::Dialog.new('Cambiar frase',@window,
                           Gtk::Dialog::DESTROY_WITH_PARENT,
                           [Gtk::Stock::OK,Gtk::Dialog::RESPONSE_ACCEPT],
                           [Gtk::Stock::CANCEL,Gtk::Dialog::RESPONSE_REJECT])
    image=Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
    vbox=Gtk::VBox.new false,10
    combobox=Gtk::ComboBox.new
    $lista.keys.each_with_index do |frase,i|
      combobox.append_text frase
    end
    entry=Gtk::Entry.new
    combobox.signal_connect('changed'){
      entry.text=$lista.keys[combobox.active]
    }
    vbox.pack_start Gtk::Label.new 'Frase a cambiar:'
    vbox.pack_start combobox
    vbox.pack_start Gtk::Label.new 'Nueva frase:'
    vbox.pack_start entry
    hbox=Gtk::HBox.new false,10
    hbox.border_width=10
    hbox.pack_start image
    hbox.pack_start vbox
    dialog.vbox.add hbox
    dialog.show_all
    dialog.run do |response|
      if response==Gtk::Dialog::RESPONSE_ACCEPT and combobox.active>=0
        $lista.changefn combobox.active+1, entry.text
        $changed=true
        actualiza_lista
      end
      dialog.destroy
    end
  end

 


  def plot
    tmpfile="agafras-#{(rand*99999999).to_i}.png"
    $lista.plot_gruff tmpfile
    
    dialog=Gtk::Dialog.new('Gráfica',$widow,
                           Gtk::Dialog::MODAL,
                           [Gtk::Stock::CLOSE,Gtk::Dialog::RESPONSE_ACCEPT]
                          )
    tw=Gtk::TextView.new
    tw.editable=false
    tw.buffer.insert_pixbuf(
      tw.buffer.get_iter_at_line(0),
      Gdk::Pixbuf.new(tmpfile)
    )
    scroll=Gtk::ScrolledWindow.new
    scroll.border_width=5
    scroll.add tw
    scroll.set_policy(
      Gtk::POLICY_AUTOMATIC,Gtk::POLICY_AUTOMATIC
    )
    dialog.vbox.add scroll
    dialog.show_all
    dialog.run
    dialog.destroy
    
    File.delete tmpfile
  end




  def incrementa_from_str
    @input.text.split(" ").each do |ns|
        if /(^||\s||-)\d+-\d+($||\s||-)/.match ns
          $lista.inccombob
          ns.split("-").each do |nc|
            $changed=true
            $lista.incn(nc.to_i) if nc.to_i>=1 and nc.to_i<=$lista.size
          end
        else
          $changed=true
          $lista.incn(ns.to_i) if ns.to_i>=1 and ns.to_i<=$lista.size
        end
      end
    actualiza_lista
    limpiainput
  end

  def limpiainput
    @input.text=''
  end
  

  def actualiza_lista
    @lista_frases.clear
    $lista.keys.each_with_index do |frase,i|
      fila=@lista_frases.append
      @lista_frases.set_value(fila,0,(i+1).to_s)
      @lista_frases.set_value(fila,1,frase)
      @lista_frases.set_value(fila,2,$lista.getval(frase).to_s)
      @lista_frases.set_value(fila,3,'(Incrementa)')
    end
    fila=@lista_frases.append if $lista.keys.size >= 1
    fila=@lista_frases.append
    @lista_frases.set_value(fila,1,'C-C-C-COMBO BREAKER!!!')
    @lista_frases.set_value(fila,2,$lista.getcombob.to_s)
    @lista_frases.set_value(fila,3,@combo_activado?'(Activado)':'(Desactivado)')
    fila=@lista_frases.append
    @lista_frases.set_value(fila,1,'TOTAL')
    @lista_frases.set_value(fila,2,$lista.gettotal.to_s)
    @treeview_frases.model=@lista_frases

    @frame_frases.label=$lista.nombre
  end


end

