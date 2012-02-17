/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/

// Import de bootstrap
import stdlib.themes.bootstrap
import stdlib.widgets.bootstrap
WB = WBootstrap

/**
Interface
*/
interface(x : xhtml) = 
      Resource.html("BDE-UTC :: Vote en ligne",container_app(x))

container_app(x) =
  WB.Navigation.topbar(
    WB.Layout.fixed(
      WB.Navigation.brand(<>BDE-UTC :: Vote en ligne</>, some("/"), ignore) <+>
      (<>Non connecté</> |> WB.pull_right(_))
    )
  ) <+>
  <br /><br /><br />
  <+>
  WB.Layout.fixed(x)
