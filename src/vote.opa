/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/

import stdlib.web.client

/**
La base de données
*/

db /votant : stringmap(bool)
db /votant[_] = false

db /result : intmap(int)
db /result[_] = 0

/**
Le vote en ligne.
*/

has_voted(login) = Db.exists(@/votant[login])

vote_for(id_liste) : xhtml =
   execute(login) =
      actions =
        WB.Button.make({link=<>Oui je vote pour la liste {id_liste}</> href=none callback=(_ -> do /votant[login] <- true
              do /result[id_liste] <- /result[id_liste] + 1
              Client.reload())}, [{small}]) <+>
        <>{" "}</> <+>
        WB.Button.make({link=<>Annuler</> href=none callback=(_ -> Dom.transform([#validation <- <></>]))}, [{small}])
      msg = WB.Message.make(
            {block={title="Validation !"
              description=<>Tu t'apprétes à voter pour la liste {id_liste}. Attention, tu ne peux voter qu'une fois et tu ne pourras modifier ton choix.</>}
              actions=some(actions)
              closable=true},
              {success}
            )
      Dom.transform([#validation <- msg])

   match myCas.get_status() with
    | {logged=login} -> 
        if is_cotisant(login) then
           if has_voted(login) then
             WBootstrap.Label.make("Tu as déjà voté", {warning})
           else
             WB.Button.make({link=<>Voter</> href=none callback=(_ -> execute(login))}, [{info}])
        else
           WBootstrap.Label.make("Tu n'est pas cotisant", {warning})
    | _ -> WB.Button.make({link=<>Se connecter</> href=some("{base_url}/CAS/login") callback=ignore}, [{success}])

vote() = 
  interface(
    WB.Div.page_header(1, "Vote ouvert !", some("")) <+>
    <div id=#validation></>
    <+>
    WB.Grid.row([
      {span=5 offset=none content=conf_liste1 <+> vote_for(1)},
      {span=5 offset=none content=conf_liste2 <+> vote_for(2)},
      {span=5 offset=none content=conf_liste3 <+> vote_for(3)}
    ])
  )
