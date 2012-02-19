/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/

// Import de bootstrap
import stdlib.themes.bootstrap
import stdlib.widgets.bootstrap
WB = WBootstrap

cot(login) = if is_cotisant(login) then
               <> Tu es cotisant BDE-UTC. </>
             else
               <> Tu n'es pas cotisant BDE-UTC, tu ne peux pas voter. </>

c() = match myCas.get_status() with
	  | {logged=login} -> <p>Connecté en tant que {login} - {cot(login)}</>
	  | _ -> <p>Non connecté</>

state() = match myCas.get_status() with
	    | {logged=_} -> WB.Button.make({link=<>Se déconnecter</> href=some("{base_url}/CAS/logout") callback=ignore}, [{danger}])
	    | _ -> WB.Button.make({link=<>Se connecter</> href=some("{base_url}/CAS/login") callback=ignore}, [{success}])
	  

/**
Interface
*/
interface(x : xhtml) = 
      Resource.html("BDE-UTC :: Vote en ligne",container_app(x))

container_app(x) =
  WB.Navigation.topbar(
    WB.Layout.fixed(
      WB.Navigation.brand(<>BDE-UTC :: Vote en ligne</>, some("/"), ignore) <+>
      (c() |> WB.pull_right(_))
    )
  ) <+>
  WB.Layout.fixed(
  <br /><br /><br />
  <+>
  WB.Div.content(
    WB.Div.page_header(1, "Instructions de vote", some("")) <+>
    WB.Grid.row([
      {span=4 offset=none content=<img src="res/BDE.jpg" height=150px alt="BDE-UTC" />},
      {span=10 offset=none content=<>Le vote sera ouvert du {Date.to_string(conf_start)} au {Date.to_string(conf_end)}... <br />
Pour voter vous devrez vous connecter avec le CAS et être cotisant BDE. <br />
Dès la fermeture du vote, les resultats seront affichés ici.<br /><br />
		<center>{state()}</center> </>}
    ]) <+>
    x
    )
    )
