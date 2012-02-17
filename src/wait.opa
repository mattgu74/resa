/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/

/**
Page d'attente d'ouverture du vote

Doit présenter :
 * Période d'ouverture du vote
 * Les listes
 * Test du CAS + Cotisant bde oui/non
 
*/

state() = match myCas.get_status() with
	    | {logged=_} -> WB.Button.make({link=<>Se déconnecter</> href=some("{base_url}/CAS/logout") callback=ignore}, [{danger}])
	    | _ -> WB.Button.make({link=<>Se connecter</> href=some("{base_url}/CAS/login") callback=ignore}, [{success}])
	  
	  

wait() = 
  interface(
  WB.Div.content(
    WB.Div.page_header(1, "Instructions de vote", some("")) <+>
    WB.Grid.row([
      {span=4 offset=none content=<img src="res/BDE.jpg" height=150px alt="BDE-UTC" />},
      {span=10 offset=none content=<>Le vote sera ouvert du {Date.to_string(conf_start)} au {Date.to_string(conf_end)}... <br />
Pour voter vous devrez vous connecter avec le CAS et être cotisant BDE. <br /><br />
		<center>{state()}</center> </>}
    ]) <+>
    WB.Div.page_header(1, "Le vote n'est pas encore ouvert", some("Soyez patient...")) <+>
    WB.Grid.row([
      {span=5 offset=none content=conf_liste1},
      {span=5 offset=none content=conf_liste2},
      {span=5 offset=none content=conf_liste3}
    ]))
  )
