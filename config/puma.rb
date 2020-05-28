workers 3
preload_app!

require 'barnes'

before_fork do
  Barnes.start
end

