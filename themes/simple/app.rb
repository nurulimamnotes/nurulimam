module Nesta
  class App
    use Rack::Static, :urls => ["/simple"], :root => "themes/simple/public"
  end
end
