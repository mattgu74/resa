/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/

/**
Page de resultat du vote

Doit présenter :
 * nombre de votant
 * pourcentage exprimé pour chaque liste
 * ...
 
*/

p(i) = Float.of_int(/result[i]) / Float.of_int(Map.size(/votant)) * 100.

r() =
    <p>
    <ul>
       <li>Nombre de votant : {Map.size(/votant)}</li>
       <li>Nombre de voix pour la liste 1 : {/result[1]} soit {p(1)}%</li>
       <li>Nombre de voix pour la liste 2 : {/result[2]} soit {p(2)}%</li>
       <li>Nombre de voix pour la liste 3 : {/result[3]} soit {p(3)}%</li>
    </ul>
    </p>

w() = 
  r1 = /result[1]
  r2 = /result[2]
  r3 = /result[3]
  if r1 > r2 then
       if r1 > r3 then
            conf_liste1
       else
            conf_liste3
   else // r2 > r1
       if r2 > r3 then
            conf_liste2
       else
            conf_liste3

result() = 
  interface(
    WB.Div.page_header(1, "Résultat du vote", some("And the winner is...")) <+>
    <br />
    <+>
    WB.Grid.row([
      {span=10 offset=none content=r()},
      {span=5 offset=none content=w()}
    ]))
