require 'dispel'

Dispel::Screen.open do |screen|
  screen.draw ["hello"].join("\n")
  Dispel::Keyboard.output do |key|
    if ('a'..'z').include?(key)
      guess = key
      break
    end
  end
end
