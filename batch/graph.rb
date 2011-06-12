require 'yaml'
require 'googlecharts'

Dir::mkdir "charts"


Dir["data/*.yaml"].each do |file|
  Gchart.line YAML::load File.open file
end