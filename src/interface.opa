/*
@author Matthieu Guffroy
Reservation de salle du BDE-UTC
*/

// Import de bootstrap
import stdlib.themes.bootstrap
import stdlib.widgets.bootstrap
WB = WBootstrap

c() = match myCas.get_status() with
	  | {logged=login} -> <a href="#">Connecté en tant que {login}</>
	  | _ -> <a href="#">Non connecté</>

state() = match myCas.get_status() with
	    | {logged=_} -> WB.Button.make({link=<>Se déconnecter</> href=some("{base_url}/CAS/logout") callback=ignore}, [{danger}])
	    | _ -> WB.Button.make({link=<>Se connecter</> href=some("{base_url}/CAS/login") callback=ignore}, [{success}])
	  

/**
Interface
*/
interface(x : xhtml) = 
      Resource.html("BDE-UTC :: Reservation de salle",container_app(x))

container_app(x) =
  WB.Navigation.topbar(
    WB.Layout.fixed(
      WB.Navigation.brand(<>BDE-UTC :: Reservation de salle</>, some("/"), ignore) <+>
      (c() |> WB.pull_right(_))
    )
  ) <+>
  WB.Layout.fixed(
  <br /><br /><br />
  <+>
  if myCas.is_logged() then 
     x
  else
  WB.Div.content(
    WB.Div.page_header(1, "Reservation de salle", some("")) <+>
    WB.Grid.row([
      {span=4 offset=none content=<img src="res/BDE.jpg" height=150px alt="BDE-UTC" />},
      {span=10 offset=none content=<>Merci de vous connecter pour accèder à l'outil de réservation de salle !<br /><br />
		<center>{state()}</center> </>}
    ])
    )
    )
