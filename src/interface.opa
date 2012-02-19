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
	  | {logged=login} -> <>Connecté en tant que {login} - {cot(login)}</>
	  | _ -> <>Non connecté</>

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
  <br /><br /><br />
  <+>
  WB.Layout.fixed(x)
