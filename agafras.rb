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
      [Gtk::Stock::SAVE,:save]
    ]
  end
  def menu_items
    [
      ['/_Archivo'],
      ['/Archivo/_Abrir archivo de datos',
        '<Item>',nil,nil,lambda{cargadat}],
      ['/Archivo/_Guardar','<Item>',nil,nil,lambda{save}],
      ['/Archivo/_Salir','<Item>',nil,nil,lambda{cerrar}],
      ['/_Datos'],
      ['/Datos/_Nombre de los datos','<Item>',nil,nil,lambda{renombrar_datos}],
      ['/Datos/_Añadir frase','<Item>',nil,nil,lambda{add}],
      ['/Datos/_Eliminar frase','<Item>',nil,nil,lambda{del}],
      ['/Datos/_Cambiar frase','<Item>',nil,nil,lambda{cambia}],
      ['/_Gráfica'],
      ['/Gráfica/_Mostrar gráfica','<Item>',nil,nil,lambda{plot}], 
      ['/Gráfica/_Guardardar gráfica de áreas',
        '<Item>',nil,nil,lambda{plotsave 0}],
      ['/Gráfica/_Guardardar gráfica de barras',
        '<Item>',nil,nil,lambda{plotsave 1}],
      ['/_Ayuda'],
      ['/Ayuda/_Acerca de...','<Item>',nil,nil,lambda{acerca}]
    ]
  end

  def initialize
    $changed=false
    @combo_activado=false
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
    @treeview_frases=Gtk::TreeView.new
    renderer=Gtk::CellRendererText.new
    column=Gtk::TreeViewColumn.new('Nº',renderer,:text=>0)
    @treeview_frases.append_column(column)
    column=Gtk::TreeViewColumn.new('Frase',renderer,:text=>1)
    @treeview_frases.append_column(column)
    column=Gtk::TreeViewColumn.new('Contador',renderer,:text=>2)
    @treeview_frases.append_column(column)
    @column_incrementa=Gtk::TreeViewColumn.new('Pulsa para incrementar',
                                               renderer,:text=>3)
    @treeview_frases.append_column(@column_incrementa)
    @lista_frases=Gtk::ListStore.new(String,String,String,String)

    @treeview_frases.signal_connect('cursor-changed'){|widget|
      if widget.cursor[1]==@column_incrementa
        if widget.cursor[0].to_s.to_i>=0 and
            widget.cursor[0].to_s.to_i<$lista.keys.size #NUMERO
          num=(widget.cursor[0].to_s.to_i+1).to_s
          @input.text=@input.text+num+(@combo_activado?'-':' ')
        elsif widget.cursor[0].to_s.to_i==$lista.keys.size+1 #COMBO
          @combo_activado=!@combo_activado
          if @combo_activado and not (/ $/.match @input.text)
            @input.text=@input.text+' '
          elsif !@combo_activado and (/-$/.match @input.text)
            @input.text=@input.text.gsub(/-$/,' ')
          end
          actualiza_lista
        end
      end
    }
    scroll_frases=Gtk::ScrolledWindow.new
    scroll_frases.add @treeview_frases
    scroll_frases.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
    scroll_frases.border_width=10
    @frame_frases=Gtk::Frame.new $lista.nombre
    @frame_frases.add scroll_frases

    actualiza_lista

    #NOTE fin empaquetado frases
    vbox_opciones=Gtk::VBox.new(false,5)
    buttons_opciones=Array.new
    opciones.each do |strop|
      buttons_opciones.push Gtk::Button.new strop[0]
      buttons_opciones.last.signal_connect('clicked'){self.send(strop[1])}
      vbox_opciones.pack_start buttons_opciones.last,false
    end
    label_input=Gtk::Label.new 'Introduce el número de las frases que deseas' <<
    " incrementar en el siguiente recuadro,\nseparadas por espacios " <<
    "(o por guiones para hacer combo breaker):"
    @input=Gtk::Entry.new
    @input.set_flags Gtk::Widget::CAN_DEFAULT
    @input.signal_connect('activate'){
      self.send(@button_input_ok_action)
    }
    button_input_ok=Gtk::Button.new Gtk::Stock::OK
    @button_input_ok_action=:incrementa_from_str
    button_input_ok.signal_connect('clicked'){
      self.send(@button_input_ok_action)
    }
    button_input_cancel=Gtk::Button.new Gtk::Stock::CANCEL
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
    hbox_label_input=Gtk::HBox.new
    hbox_label_input.pack_start label_input,false
    vbox_input.pack_start hbox_label_input,false
    vbox_input.pack_start hbox_input


    hbox.pack_start @frame_frases 
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

