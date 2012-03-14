import stdlib.themes.bootstrap

import stdlib.widgets.bootstrap

WB = WBootstrap

function c() {
    match (myCas.get_status()) {
    case { logged : login }:
      <><a href="#">Connecté en tant que {login}</a> - 
       <a onclick={function(_) {
                   myCas.logout_void()
       }}>Se déconnecter</a></>
    default: <a href="#">Non connecté</a>
    }
    
}

function state() {
    match (myCas.get_status()) {
    case { logged : _ }:
      WB.Button.make({
                      link : <>Se déconnecter</>,
                      href : some("{base_url}/CAS/logout"),
                      callback : ignore
                      },
        [{danger}])
    default:
      WB.Button.make({
                      link : <>Se connecter</>,
                      href : some("{base_url}/CAS/login"),
                      callback : ignore
                      },
        [{success}])
    }
    
}

function interface(xhtml x) {
    Resource.html("BDE-UTC :: Reservation de salle", container_app(x))
}

function container_app(x) {
    WB.Navigation.topbar(WB.Layout.fixed(WB.Navigation.brand(<>BDE-UTC :: Reservation de salle</>,
                                           some("/"), ignore) <+>
                                           (c() |> WB.pull_right(_)))) <+>
      WB.Layout.fixed(<><br/><br/><br/></> <+> if (myCas.is_logged()) x
                        else
                          WB.Div.content(WB.Div.page_header(1,
                                           "Reservation de salle", some("")) <+>
                                           WB.Grid.row([{
                                                         span : 4,
                                                         offset : none,
                                                         content :
                                                           <img src="res/BDE.jpg" height="150px" alt="BDE-UTC"/>
                                                         },
                                                         {
                                                          span : 10,
                                                          offset : none,
                                                          content :
                                                            <>
                                                             Merci de vous connecter pour accèder à l'outil de réservation de salle !
                                                             <br/><br/>

                                                             <center>{
                                                             state()}</center>
                                                              </>
                                                          }])))
}