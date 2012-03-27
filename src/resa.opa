/*
@author Matthieu Guffroy
Reservation de salle du BDE-UTC
*/

import stdlib.widgets.datepicker
import stdlib.web.client

salles = ["FC225 - PVDC", "FC224 - PSEC", "Salle Jaune"]

type resa = {
     login : string
     assos : string
     salle : string
     date : Date.date
     deb : string
     fin : string
     etat : {en_attente} / {refuse : string} / {accepte : string}
     comment : string
}

db /resas : list(resa)

my_resas() : list(resa) = List.filter((a -> a.login == myCas.get_login()), /resas)

show_resa(r) : xhtml =
             status = match r.etat with
                       | {en_attente} -> WB.Label.make(<>En attente</>, {default})
                       | {refuse=_} -> WB.Label.make(<>Refusé</>, {important})
                       | {accepte=_} -> WB.Label.make(<>Accepté</>, {success})
                      end
             <li>{status}{WDatepicker.show_default(Random.string(4),r.date)} {r.deb} - {r.fin} : {r.salle} ({r.assos}) {buttons(r)}</li>

delete(r)=
        do /resas <- List.filter((a -> a != r), /resas)
        Client.reload()
refuse(r)=
        do /resas <- List.map((a -> if a == r then {r with etat = {refuse=""}} else a), /resas)
        Client.reload()
autorise(r)=
        do /resas <- List.map((a -> if a == r then {r with etat = {accepte=""}} else a), /resas)
        Client.reload()

buttons(r) = 
           if (myCas.get_login() == "deliasni" || myCas.get_login() == "mguffroy") then
              <>
               <a onclick={_ -> refuse(r)}><span class="icon icon-color icon-close"/></a>
               <a onclick={_ -> autorise(r)}><span class="icon icon-color icon-check"/></a>
               <a onclick={_ -> delete(r)}><span class="icon icon-color icon-trash"/></a></>
           else if myCas.get_login() == r.login then 
               // Supprime
               <>
               <a onclick={_ -> delete(r)}><span class="icon icon-color icon-trash"/></a></>
           else
               <>{myCas.get_login()}</>

form() =
       save()=
           assos=Dom.get_value(#f_assos)
           salle=Dom.get_value(#f_salle)
           date=Option.default(Date.now(),WDatepicker.parse_default("f_date"))
           deb=Dom.get_value(#f_deb)
           fin=Dom.get_value(#f_fin)
           comment=Dom.get_value(#f_comment)
           r = {login=myCas.get_login() ~assos ~salle ~date ~deb ~fin ~comment etat={en_attente}}
           do /resas <- List.add(r,/resas)
           do Client.reload()
           void
       creneau=
           (a,_)=for(([],(8,0)),
                     ((l,(h,m)) -> (if m == 0 then List.add("{h}:00",l) else List.add("{h}:{m}",l), if m == 45 then (h+1,0) else (h,m+15))),
                     ((_,(h,m)) -> h < 23))
           a
       <h3>Faire une réservation</h3>
       <div id=#f_info></>
       <table>
           <tr><td>Login : </td><td>{myCas.get_login()}</td></tr>
           <tr><td>Assos : </td><td><input type="text" id=#f_assos /></td></tr>
           <tr><td>Salle : </td><td><select id=#f_salle>
                       {List.fold((s,a -> a <+> <option value="{s}">{s}</>), salles, <></>)}
                   </select></td></tr>
           <tr><td>Date : </td><td>{WDatepicker.edit_default((_->void),"f_date",Date.now())}</td></tr>
           <tr><td>Début : </td><td><select id=#f_deb>
                       {List.fold((s,a -> a <+> <option value="{s}">{s}</>), creneau, <></>)}
                   </select></td></tr>
           <tr><td>Fin : </td><td><select id=#f_fin>
                       {List.fold((s,a -> a <+> <option value="{s}">{s}</>), creneau, <></>)}
                   </select></td></tr>
           <tr><td>Commentaire : </td><td><textarea id=#f_comment></textarea></td></tr>
           <tr><td></td><td>{WB.Button.make({link=<>Valider</> href=none callback=(_->save())}, [{success}])}</td></tr>
       </table>
       <br /><br />

my_resa()=
        <h3>Mes réservations</>
        <ul id=#my_resa>
            {List.fold((r,a -> a <+> show_resa(r)), my_resas(), <></>)}
        </ul>
        <br /><br />

make_resa()=
    WB.Div.page_header(1, "Faire une réservation", none) <+>
    WB.Grid.row([
        {span=8 offset=none content=form()},
        {span=8 offset=none content=my_resa()}
    ])

resa_wait(s)=
        <h3>Demande de réservations</h3>
        <ul>
            {List.fold((r,a -> a <+> show_resa(r)), List.filter((a -> (a.etat == {en_attente} && a.salle == s)), /resas), <></>)}
        </ul>
        <br /><br />

resa_ok(s)=
        <h3>Réservations validées</h3>
        <ul>
            {List.fold((r,a -> a <+> show_resa(r)), List.filter((a -> (match a.etat with
| {accepte=_} -> a.salle == s
| _ -> false)), /resas), <></>)}
        </ul>
        <br /><br />

show_salle(s) = 
    WB.Div.page_header(1, s, none) <+>
    WB.Grid.row([
       {span=8 offset=none content=resa_ok(s)},
       {span=8 offset=none content=resa_wait(s)}
    ])          

resa() =   
  interface(
      make_resa() <+>
      List.fold((s,a -> a <+> show_salle(s)), salles, <></>)
  )
