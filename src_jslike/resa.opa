import stdlib.widgets.datepicker

import stdlib.web.client

salles = ["FC225 - PVDC", "FC224 - PSEC", "Salle Jaune"]

type resa =
  {string login, string assos, string salle, Date.date date, string deb,
   string fin, or {en_attente}
               or {string refuse}
               or {string accepte} etat,
   string comment}

database list(resa) /resas

function list(resa) my_resas() {
    List.filter((function(a) {
                 a.login == myCas.get_login()
      }), /resas)
}

function xhtml show_resa(r) {
    status =
        match (r.etat) {
        case { en_attente }: WBootstrap.Label.make("En attente", {`default`})
        case { refuse : _ }:
          WBootstrap.Label.make("Refus\195\169", {important})
        case { accepte : _ }:
          WBootstrap.Label.make("Accept\195\169", {success})
        };
    <li>{status}{WDatepicker.show_default(Random.string(4), r.date)} {r.deb} - {r.fin} : {r.salle} ({r.assos}) {
    buttons(r)}</li>
}

function delete(r) {
    /resas <- List.filter((function(a) {
                           a != r
                }), /resas);
    Client.reload()
}

function refuse(r) {
    /resas <- List.map((function(a) {
                        if (a == r) {r with etat : {refuse : ""}} else a
                }), /resas);
    Client.reload()
}

function autorise(r) {
    /resas <- List.map((function(a) {
                        if (a == r) {r with etat : {accepte : ""}} else a
                }), /resas);
    Client.reload()
}

function buttons(r) {
    if ((myCas.get_login() == "deliasni") ||
          (myCas.get_login() == "mguffroy"))
      <>

       <a onclick={function(_) {
                   refuse(r)
       }}><span class="icon icon-color icon-close"/></a>

       <a onclick={function(_) {
                   autorise(r)
       }}><span class="icon icon-color icon-check"/></a>

       <a onclick={function(_) {
                   delete(r)
       }}><span class="icon icon-color icon-trash"/></a></>
    else
      if (myCas.get_login() == r.login)
        <>

         <a onclick={function(_) {
                     delete(r)
         }}><span class="icon icon-color icon-trash"/></a></>
      else <></>
}

function form() {
    function save() {
        assos = Dom.get_value(#f_assos);
        salle = Dom.get_value(#f_salle);
        date =
            Option.`default`(Date.now(), WDatepicker.parse_default("f_date"));
        deb = Dom.get_value(#f_deb);
        fin = Dom.get_value(#f_fin);
        comment = Dom.get_value(#f_comment);
        r =
            {
             login : myCas.get_login(),
             ~assos,
             ~salle,
             ~date,
             ~deb,
             ~fin,
             ~comment,
             etat : {en_attente}
             };
        /resas <- List.add(r, /resas);
        Client.reload();
        void
    }
     creneau = {
        (a, _) =
            for(([], (8, 0)),
              (function((l, (h, m))) {
               (if (m == 0) List.add("{h}:00", l)
                else List.add("{h}:{m}", l), if (m == 45) (h + 1, 0)
                else (h, m + 15))
              }), (function((_, (h, m))) {
                   h < 23
              }))
        a
    }
    <><h3>Faire une réservation</h3>
       <div id="f_info"/>
       
     <table>
<tr><td>Login : </td><td>{myCas.get_login()}</td></tr>
<tr><td>Assos : </td><td><input type="text" id="f_assos"/></td></tr>
<tr><td>Salle : </td><td><select id="f_salle">
{
     List.fold((function(s, a) {
                a <+> <option value="{s}">{s}</option>
       }), salles, <></>)}
</select></td></tr>
<tr><td>Date : </td><td>{
     WDatepicker.edit_default((function(_) {
                               void
       }), "f_date", Date.now())}</td></tr>
<tr><td>Début : </td><td><select id="f_deb">
{
     List.fold((function(s, a) {
                a <+> <option value="{s}">{s}</option>
       }), creneau, <></>)}
</select></td></tr>
<tr><td>Fin : </td><td><select id="f_fin">
{
     List.fold((function(s, a) {
                a <+> <option value="{s}">{s}</option>
       }), creneau, <></>)}
</select></td></tr>
<tr><td>Commentaire : </td><td><textarea id="f_comment"/></td></tr>
<tr><td/><td>{
     WB.Button.make({
                     link : <>Valider</>,
                     href : none,
                     function callback(_) {
                       save()
                     }
       },
     [{success}])}</td></tr>
</table>
    
       
    <br/>
    <br/></>
}

function xhtml my_resa() {
    <><h3>Mes réservations</h3>
        
     <ul id="my_resa">
{List.fold((function(r, a) {
                                   a <+> show_resa(r)
                          }), my_resas(), <></>)}
</ul>
     
        <br/><br/></>
}

function make_resa() {
    WB.Div.page_header(1, "Faire une r\195\169servation", none) <+>
      WB.Grid.row([{span : 10, offset : none, content : form()},
                    {span : 5, offset : none, content : my_resa()}])
}

function xhtml resa_wait(s) {
    <><h3>Demande de réservations</h3>
        
     <ul>
{List.fold((function(r, a) {
                      a <+> show_resa(r)
             }),
             List.filter((function(a) {
                          (a.etat == {en_attente}) && (a.salle == s)
               }), /resas),
             <></>)}
</ul>
     
        <br/><br/></>
}

function xhtml resa_ok(s) {
    <><h3>Réservations validées</h3>
        
     <ul>
{List.fold((function(r, a) {
                      a <+> show_resa(r)
             }),
             List.filter((function(a) {
                          match (a.etat) {
                          case { accepte : _ }: a.salle == s
                          default: false
                          }
               }), /resas),
             <></>)}
</ul>
     
        <br/><br/></>
}

function show_salle(s) {
    WB.Div.page_header(1, s, none) <+>
      WB.Grid.row([{span : 10, offset : none, content : resa_ok(s)},
                    {span : 5, offset : none, content : resa_wait(s)}])
}

function resa() {
    interface(make_resa() <+>
                List.fold((function(s, a) {
                           a <+> show_salle(s)
                  }), salles, <></>))
}