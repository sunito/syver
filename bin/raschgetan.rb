#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'time'

MAX_SEKUNDEN_MAIL_NOCH_ALS_NEU_GEWERTET = 120
TIMEOUT_SEKUNDEN = 10 # auch 8sek hat nicht gereicht f GLS
#TIMEOUT_SEKUNDEN = 8 # 6 wäre für GLS zu wenig

class String
  define_method "/" do |rest|
    if empty?
      rest
    else
      File.join( self, rest)
    end
  end
end

def dont
  # dont do anything
end


class TanMails
  def initialize dir
    @dir = dir
  end
  
  def neueste
    alle_dateinamen = Dir[@dir/"*/*"]  # Dir[@dir/"cur/*"] + 
    neueste_datei = alle_dateinamen.sort_by{|dn| dont { print File.mtime(dn); puts " <-- "+dn};   File.mtime(dn)}.last
    #p File.mtime(neueste_datei)    
    #p neueste_datei
    neueste_datei
  end
  
  def extrahiere_tan text
    [
      / lautet: ([\w\d]{6})/, # Postb
      / lautet ([\d]{6}),/,   # GLS standard
      / TAN ([\w\d]{6})\./     # 3dsecure-cardprocess.de (Mastercard Securcode)
    ].find do |re|
      if re =~ text
        return $1
      end
    end
    nil
  end
  
  def status
    neu_text = File.read neueste
    tan = extrahiere_tan neu_text
    # ToDo: Erkennung leerer SMS-Mails
    if tan
      zeit_str = neu_text.scan(/^Date: (.+)$/).first.first
      zeit = Time.parse(zeit_str) if zeit_str
      if zeit.nil?
        [false, "keine Zeit in der Mail gefunden!! (Tan: #{tan}"]
      else
        erfolg =  (Time.now - zeit < MAX_SEKUNDEN_MAIL_NOCH_ALS_NEU_GEWERTET)
        [ erfolg, (erfolg ? '' : "Keine neue Tan-Mail \n  Alte ") +
          "Tan: #{tan}      Zeit: #{zeit.strftime('%b-%d. %T')}"
        ]
      end
    else
      [false, "Keine aktuelle Tan-Mail gefunden"]
    end
  end
  
  def warte wartedauer=TIMEOUT_SEKUNDEN
    anf_zeit = Time.now
    text = nil
    while Time.now - anf_zeit <= wartedauer do
      `kmail-check`
      erfolg, text = status
      break text if erfolg
      sleep 1.4
    end
    text
  end
end




tm = TanMails.new "/111/ye-sys/kmail-neu/local-mail/.e-EingangPrio.directory/e-Anrufe/"

puts tm.warte
