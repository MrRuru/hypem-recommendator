# Loading the contents of config.yml (unversionized), and storing it in Rails.application.config
YAML.load_file("#{Rails.root}/config/config.yml").each { |k,v| Rails.application.config.send "#{k}=", v }
