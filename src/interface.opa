/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/

// Import de bootstrap
import stdlib.themes.bootstrap
import stdlib.widgets.bootstrap
WB = WBootstrap

c() = match myCas.get_status() with
	  | {logged=login} -> <>Connecté en tant que {login}</>
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
