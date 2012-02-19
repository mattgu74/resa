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

wait() = 
  interface(
    WB.Div.page_header(1, "Le vote n'est pas encore ouvert", some("Soyez patient...")) <+>
    WB.Grid.row([
      {span=5 offset=none content=conf_liste1},
      {span=5 offset=none content=conf_liste2},
      {span=5 offset=none content=conf_liste3}
    ]))
