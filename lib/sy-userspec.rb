#!/usr/bin/env ruby
#encoding: UTF-8


class String
  define_method "/" do |rest|    
    File.join( self, rest)
  end
end


def puts_and_execute command
  puts   "exec> " + command
  system command
end  

require 'rubygems'
begin 
  require 'nokogiri'
rescue LoadError
  # "sourceW" und "apt_install" funktionieren so leider nicht:
  # puts_and_execute "source #{File.expand_path('../sy-common.bash',__FILE__)} ;apt_install zlib-devel patch"
  puts_and_execute "sudo apt-get install zlib-devel patch"
  puts_and_execute "sudo apt-get install zlib1g-dev"
  #puts_and_execute "sudo zypper -n install zlib-devel"
  puts_and_execute "sudo gem install nokogiri"
  require 'nokogiri'
end

snippets_doc = Nokogiri::XML(open(ENV['HOME'] / '.kde/share/apps/plasma_applet_paste/snippets.xml'))

p snippets_doc 

snippets = snippets_doc.search("snippets")

p snippets


passw_node = snippets.search('snippet[@name = "Fecha actual"]')
passw_node = snippets.search('snippet[@name = "Contraseña aleatoria"]')

p passw_node
                             
def add_if_not_exists name, value
  
end
  