/*
@author Matthieu Guffroy
Reservation de salles du BDE-UTC
*/

import mattgu74.cas

base_url=Option.default("",Resource.base_url)

cas_conf = 
{
  url = "https://cas.utc.fr/cas/" ; // <<-- sample url
  service = "{base_url}"
 } : Cas.config

myCas = Cas(cas_conf)

/*
On appelle les "routes conditionnelles" 
*/
urls_caller : Parser.general_parser(http_request -> resource) =
    parser
      | result={myCas.resource} -> _req -> result
      | .* -> _req -> resa()

/*
Démarrage du serveur
*/
server = Server.make(
             Resource.add_auto_server(@static_resource_directory("res"),
             urls_caller)
         )
