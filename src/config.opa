/*
@author Matthieu Guffroy
Vote en ligne du BDE-UTC
*/

/**
Fichier de configuration du vote en ligne
*/

/**
Ouverture du vote
*/
conf_start = Date.build({ year = 2012 ; 
                     month = { february } ; 
                     day = 29
                     h = 8
                     min = 0
                     s = 0})

/**
Fin du vote
*/
conf_end = Date.build({ year = 2012 ; 
                   month = { february } ; 
                   day = 30
                   h = 8
                   min = 0
                   s = 0})

/**
Les listes
*/
conf_liste1 = 
<>
  <h3>Liste 1</h3>
  <ul>
     <li><strong>Prenom Nom</strong>(Prez)</li>
     <li><strong>Prenom Nom</strong>(Vice-Prez)</li>
     <li><strong>Prenom Nom</strong>(Trez)</li>
     <li><strong>Prenom Nom</strong>(Secretaire)</li>
     <li>...</li>
  </ul>
</>


conf_liste2 = 
<>
  <h3>Liste 2</h3>
  <ul>
     <li><strong>Prenom Nom</strong>(Prez)</li>
     <li><strong>Prenom Nom</strong>(Vice-Prez)</li>
     <li><strong>Prenom Nom</strong>(Trez)</li>
     <li><strong>Prenom Nom</strong>(Secretaire)</li>
     <li>...</li>
  </ul>
</>

conf_liste3 = 
<>
  <h3>Liste 3</h3>
  <ul>
     <li><strong>Prenom Nom</strong>(Prez)</li>
     <li><strong>Prenom Nom</strong>(Vice-Prez)</li>
     <li><strong>Prenom Nom</strong>(Trez)</li>
     <li><strong>Prenom Nom</strong>(Secretaire)</li>
     <li>...</li>
  </ul>
</>
