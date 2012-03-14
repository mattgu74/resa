import mattgu74.cas

base_url = Option.`default`("", Resource.base_url)

cas_conf =
    (Cas.config) {url : "https://cas.utc.fr/cas/", service : "{base_url}"}

myCas = Cas(cas_conf)

Parser.general_parser(((http_request -> resource))) urls_caller = {
    parser{
    result = {myCas.resource} :
    function(_req) {
    result
    }
    case .* : function(_req) {
              resa()
      }}
    }
    
    `server` =
        Server.make(Resource.add_auto_server(@static_resource_directory("res"),
                      urls_caller))