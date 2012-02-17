/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/


d(d) = Duration.is_positive(Date.between(Date.now(), d))

/*
Parser d'url
*/
urls_if() : Parser.general_parser(http_request -> resource) =
    if d(conf_start) then
    // Attente de l'ouverture des votes
        parser
         | .* -> _req -> wait()
    else
        if d(conf_end) then
        // Vote ouvert
           parser
            | .* -> _req -> vote()
        else
        // Vote clos
           parser
            | .* -> _req -> result()

/*
On appelle les "routes conditionnelles" 
*/
urls_caller : Parser.general_parser(http_request -> resource) =
    parser
      | get={urls_if()} -> get

/*
Démarrage du serveur
*/
server = Server.make(
             Resource.add_auto_server(@static_resource_directory("res"),
             urls_caller)
         )
