path = File.expand_path(File.dirname(__FILE__))
$:.unshift(path) unless $:.include?(path)

module DeltaAttack
  VERSION = "0.1.3"

  autoload :Client, 'delta_attack/client'
  autoload :FiletypeAssumption, 'delta_attack/filetype_assumption'
end

