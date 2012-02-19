/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/

/**
Client API cotisants
*/

    is_cotisant( login : string ) : bool =
        uri = Option.get(Uri.of_string("http://wwwassos.utc.fr/bde/cotisants/api.php?login={login}&key=n5aS6eUfk2x29YPQ636fc9394X79n2"))
        match WebClient.Result.as_xml(WebClient.Get.try_get(uri)) with
         | {failure = _} -> false
         | {~success}    -> 
             match WebClient.Result.get_class(success) with
              | {success} -> 
                  match success.content with
                    | {~args ; ...} -> List.fold(
                                                (v,a -> if v.name == "cotisant" then 
                                                          ( if v.value == "true" then true else false )
                                                        else a),
                                                args, 
                                                false)
                    | _ -> false
                    end
              | _         -> false
              end
        end
