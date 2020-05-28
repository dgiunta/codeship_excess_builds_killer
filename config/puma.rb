workers 3

require 'barnes'

before_fork do
  Barnes.start
end

