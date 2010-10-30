#!/usr/bin/env ruby1.8
# author: Adrián García
# program under the license GPL v3
require 'lib/classfrases-base'
require 'lib/classfrases-modificadores'
require 'lib/funciones'
require 'gtk2'
require 'lib/interface-functions'


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
    @window.window_position=Gtk::Window::POS_CENTER
    @window.focus=@input
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

