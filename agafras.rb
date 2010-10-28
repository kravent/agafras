#!/usr/bin/env ruby1.8
# author: Adrián García
# program under the license GPL v3
require 'lib/classfrases-base'
require 'lib/classfrases-modificadores'
require 'lib/funciones'
require 'gtk2'


class AgaInterfaz
  def opciones
    [
      ['Añadir frase',:add],
      ['Eliminar frase',:del],
      ['Cambiar frase',:cambia],
      ['Mostrar gráfica',:plot],
      ['Guardar',:save]
    ]
  end
  def menu_items
    [
      ['/_Archivo'],
      ['/Archivo/_Abrir archivo de datos',
        '<Item>',nil,nil,lambda{cargadat}],
      ['/Archivo/_Guardar','<Item>',nil,nil,lambda{save}],
      ['/Archivo/_Salir','<Item>',nil,nil,lambda{cerrar}],
      ['/_Frases'],
      ['/Frases/_Añadir frase','<Item>',nil,nil,lambda{add}],
      ['/Frases/_Eliminar frase','<Item>',nil,nil,lambda{del}],
      ['/Frases/_Cambiar frase','<Item>',nil,nil,lambda{cambia}],
      ['/_Gráfica'],
      ['/Gráfica/_Mostrar gráfica','<Item>',nil,nil,lambda{plot}], 
      ['/Gráfica/_Guardardar gráfica como svg',
        '<Item>',nil,nil,lambda{plotsave '*.svg'}],
      ['/Gráfica/_Guardardar gráfica como eps',
        '<Item>',nil,nil,lambda{plotsave '*.eps'}],
      ['/_Ayuda'],
      ['/Ayuda/_Acerca de...','<Item>',nil,nil,lambda{acerca}]
    ]
  end

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
      image=Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
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

  def plotsave filter_pattern
    dialog=Gtk::FileChooserDialog.new('Abrir archivo',$window,
                                      Gtk::FileChooser::ACTION_SAVE,nil,
                                      [Gtk::Stock::CANCEL,
                                        Gtk::Dialog::RESPONSE_CANCEL],
                                      [Gtk::Stock::OK,
                                        Gtk::Dialog::RESPONSE_ACCEPT]
                                     )
    filter=Gtk::FileFilter.new
    filter.name="Archivo de imagen (#{filter_pattern})"
    filter.add_pattern filter_pattern
    dialog.add_filter filter
    dialog.run do |response|
      if response==Gtk::Dialog::RESPONSE_ACCEPT
        file=/#{filter_pattern.gsub('*','')}$/.match dialog.filename ?
             dialog.filename : dialog.filename+filter_pattern.gsub('*','')
        name=$filedat ? $filedat.gsub(/\..{2,3}$/,"")+"-"+time : nil
        $lista.plot(name,file)
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
    if $filedat
      $lista.plot $filedat.gsub(/\..{2,3}$/,"")+"-"+time
    else
      $lista.plot
    end
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
    @input.text=""
  end
  

  #NOTE función inusable debido a un bug de libgnome2-ruby
  #def actualiza_lista
  #  @lista_frases.clear
  #  $lista.keys.each_with_index do |frase,i|
  #    fila=@lista_frases.append
  #    @lista_frases.set_value(fila,0,i+1)
  #    @lista_frases.set_value(fila,1,frase)
  #    @lista_frases.set_value(fila,2,$lista.getval(frase))
  #  end
  #  fila=@lista_frases.append
  #  @lista_frases.set_value(fila,1,'C-C-C-COMBO BREAKER!!!')
  #  @lista_frases.set_value(fila,2,$lista.getcombob)
  #  fila=@lista_frases.append
  #  @lista_frases.set_value(fila,1,'TOTAL')
  #  @lista_frases.set_value(fila,2,$lista.gettotal)
  #  @treeview_frases.model=@lista_frases
  #end
  def actualiza_lista
    marshalsave($filedat+'.backup',$lista) if $filedat
    texto=""
    $lista.keys.each_with_index do |frase,i|
      texto << "#{i+1} #{frase} -> #{$lista.getval(frase)}\n"
    end
    texto << "\nC-C-C-COMBO BREAKER!!! >> #{$lista.getcombob}\n"
    texto << "TOTAL >> #{$lista.gettotal}"
    @treeview_frases.buffer.text=texto
  end






  def initialize
    $changed=false
    @window=Gtk::Window.new "#{$title} #{$version}"
    @window.destroy_with_parent=false
    @window.signal_connect('delete_event'){
      cerrar
      true
    }
    @window.border_width=0
    vbox=Gtk::VBox.new(false,5)
    hbox=Gtk::HBox.new(false,5)
    hbox.border_width=10
    menu_factory=Gtk::ItemFactory.new(Gtk::ItemFactory::TYPE_MENU_BAR,
                                      '<main>',nil)
    menu_factory.create_items(menu_items)
    menu=menu_factory.get_widget('<main>')
    #NOTE inicio empaquetado frases
    #NOTE el siguiente codigo es inusable debido a un bug de libgnome2-ruby
    #@treeview_frases=Gtk::TreeView.new
    #renderer=Gtk::CellRendererText.new
    #column=Gtk::TreeViewColumn.new('Nº',renderer,0)
    #@treeview_frases.append(column)
    #renderer=Gtk::CellRendererText.new
    #column=Gtk::TreeViewColumn.new('Frase',renderer,1)
    #@treeview_frases.append(column)
    #renderer=Gtk::CellRendererText.new
    #column=Gtk::TreeViewColumn.new('Contador',renderer,2)
    #@treeview_frases.append(column)
    #@lista_frases=Gtk::ListStore.new(Interger,String,Interger)
    @treeview_frases=Gtk::TextView.new
    @treeview_frases.editable=false
    @treeview_frases.modify_font Pango::FontDescription.new 'Monospace Bold 11'
    actualiza_lista  
    scroll_frases=Gtk::ScrolledWindow.new
    scroll_frases.add @treeview_frases
    scroll_frases.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
    #NOTE fin empaquetado frases
    vbox_opciones=Gtk::VBox.new(false,5)
    buttons_opciones=Array.new
    opciones.each do |strop|
      buttons_opciones.push Gtk::Button.new strop[0]
      buttons_opciones.last.signal_connect('clicked'){self.send(strop[1])}
      vbox_opciones.pack_start buttons_opciones.last,false
    end
    label_input=Gtk::Label.new 'Introduce el número de las frases a inc' <<
    'rementar separadas por espacios (o por guiones para hacer combo breaker):'
    @input=Gtk::Entry.new
    @input.set_flags Gtk::Widget::CAN_DEFAULT
    @input.signal_connect('activate'){
      self.send(@button_input_ok_action)
    }
    button_input_ok=Gtk::Button.new 'OK'
    @button_input_ok_action=:incrementa_from_str
    button_input_ok.signal_connect('clicked'){
      self.send(@button_input_ok_action)
    }
    button_input_cancel=Gtk::Button.new 'Cancelar'
    @button_input_cancel_action=:limpiainput
    button_input_cancel.signal_connect('clicked'){
      self.send(@button_input_cancel_action)
    }
    vbox_input=Gtk::VBox.new(false,5)
    vbox_input.border_width=10
    hbox_input=Gtk::HBox.new(false,5)
    hbox_input.pack_start @input
    hbox_input.pack_start button_input_ok,false
    hbox_input.pack_start button_input_cancel,false
    vbox_input.pack_start label_input
    vbox_input.pack_start hbox_input


    hbox.pack_start scroll_frases
    hbox.pack_start vbox_opciones,false
    vbox.pack_start menu,false
    vbox.pack_start hbox
    vbox.pack_start Gtk::HSeparator.new,false
    vbox.pack_start vbox_input,false
    @window.add vbox
    @window.default=@input
    @window.show_all
    Gtk.main
  end
end


if __FILE__ == $0
  if ARGV.size>=1
    $filedat=ARGV[0]
    unless /\.dat$/.match $filedat
      raise ArgumentError,'El archivo de datos debe ser .dat'
    end
  else
    $filedat=nil
  end
  if $filedat and File.exists? $filedat
    # Extrae datos del archivo si existe
    File.exists? $filedat
    $lista=marshalload($filedat)
    # Actualizamos los datos si eran de una versión anterior del programa
    $lista.retrocompatiblidad
  else
    # Si no se especifica archivo crea una lista nueva
    $lista=Frases.new
  end

  
  # NOTE bucle de la interfaz gráfica dentro de esta clase
  AgaInterfaz.new

end

