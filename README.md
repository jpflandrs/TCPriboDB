# TCP riboDB
You have **An english version of the installation explanations in [riboDB](https://github.com/jpflandrs/riboDB)**
Ce serveur TCP est le moteur de réponses pour le site web **[riboDB](https://github.com/jpflandrs/riboDB)**. Il peut cependant être employé seul:

- 1 pour avoir ses fonctionnalités sur une machine locale ;
- 2 pour construire des groupes d'intérêt lors de la construction de Bases de Connaissances (BdC) pour un projet (et dans ce cas il est simple d'étendre les familles au _core_ génome).

## Préparation de la BNF

La BNF est le système de représentation des séquences sous forme de dictionnaire. Une autre solution aurait été l'utilisation d'un SGBD classique. Il y a des raisons multiples à ne pas avoir pris l'option SGBD mais l'idée principale est que le serveur TCP est une solution qui peut être employée chaque fois que l'on crée une BdC (Banque de Connaissance, la nouvelle représentation des génomes) pour permettre des interrogations locales et n'est pas limitée à riboDB.

On part de riboDB dernière version (riboDB est accessible sur demande et par téléchargement via le site du labo et en interne dans le serveur bibi-lab). RiboDB est un ensemble de fichiers fasta classés par familles et (sauf pour les dRNA) présente 4 fichiers par famille.

```famille_prot_uniques.fasta; famille_prot_multiples.fasta; famille_nuc_multiples.fasta; famille_nuc_uniques.fasta``` 

Archaea et Bacteria sont séparés.

Les familles sont :

```["16SrDNA", "23SrDNA", "5SrDNA", "bTHX", "bl12", "bl17", "bl19", "bl20", "bl21", "bl25", "bl27", "bl28", "bl31", "bl32", "bl33", "bl34", "bl35", "bl36", "bl9", "bs16", "bs18", "bs20", "bs21", "bs6", "cs23", "ul1", "ul10", "ul11", "ul13", "ul14", "ul15", "ul16", "ul18", "ul2", "ul22", "ul23", "ul24", "ul29", "ul3", "ul30", "ul4", "ul5", "ul6", "us10", "us11", "us12", "us13", "us14", "us15", "us17", "us19", "us2", "us3", "us4", "us5", "us7", "us8", "us9", "al45", "al46", "al47", "el13", "el14", "el15", "el18", "el19", "el20", "el21", "el24", "el30", "el31", "el32", "el33", "el34", "el37", "el38", "el39", "el40", "el41", "el42", "el43", "el8", "es1", "es17", "es19", "es24", "es25", "es26", "es27", "es28", "es30", "es31", "es4", "es6", "es8", "p1p2"]```

et les familles suivantes sont partagées par Bacteria et Archaea:

```communs=["16SrDNA", "23SrDNA", "5SrDNA", "ul1", "ul10", "ul11", "ul13", "ul14", "ul15", "ul16", "ul18", "ul2", "ul22", "ul23", "ul24", "ul29", "ul3", "ul30", "ul4", "ul5", "ul6", "us10", "us11", "us12", "us13", "us14", "us15", "us17", "us19", "us2", "us3", "us4", "us5", "us7", "us8", "us9"]```

et il y a les familles spécifiques à Bacteria :

```bacteriapropres=["bTHX", "bl12", "bl17", "bl19", "bl20", "bl21", "bl25", "bl27", "bl28", "bl31", "bl32", "bl33", "bl34", "bl35", "bl36", "bl9", "bs16", "bs18", "bs20", "bs21", "bs6", "cs23"]```

et Archaea

 ```archaeapropres=["al45", "al46", "al47", "el13", "el14", "el15", "el18", "el19", "el20", "el21", "el24", "el30", "el31", "el32", "el33", "el34", "el37", "el38", "el39", "el40", "el41", "el42", "el43", "el8", "es1", "es17", "es19", "es24", "es25", "es26", "es27", "es28", "es30", "es31", "es4", "es6", "es8", "p1p2"]```

Le principe de la préparation est d'associer les séquences de Bacteria et Archaea des familles partagées dans un même fichier tout en créant pour chaque famille et chaque type de protéines, un dictionnaire ```Dict{String,String}``` reliant le commentaire fasta à sa séquence.
Le tout est _sérialisé_ et prêt à être utilisé. Une option future serait d'utiliser une compression supplémentaire par ```zip``` pour favoriser les échanges (car ceci permet une compression 77%).
You have **An english version of the following explanations in [riboDB](https://github.com/jpflandrs/riboDB)**
C'est **prepareBNF.jl** qui fait le job. Comme dans toutes mes phases de mise au point les adresses sont _fixées_ dans le fichier.jl dans __Main__

```D1="/Users/jean-pierreflandrois/Documents/ProtéinesBacteria1612/RIBODB/BACTERIA"```
```D2="/Users/jean-pierreflandrois/Documents/ProtéinesBacteria1612/RIBODB/ARCHAEA"```

Ceci est à changer dans le contexte réel. Ainsi `julia prepareBNF.jl` fait le travail.

Prendre les sorties (oui tout n'est pas automatique...):

- 1) dans un classeur dont le nom est aussi en dur (~l 92): ```ENSEMBLEdes_serRP_V2```
- 2) dans les fichiers `ENCYCLOPRIBODB.ser` et `TITRESENCYCLOP.ser` 

puis

- 3) créer ``/SOURCE/`` un classeur en dehors du classeur TCPriboDB 
- 4) dans ``/SOURCE/`` créer un classeur `BNKriboDB_SER` et y placer le contenu de `ENSEMBLEdes_serRP_V2`
- 5) dans ``/SOURCE/`` créer un classeur `STATSRIBODB` et y placer les fichiers `ENCYCLOPRIBODB.ser` and `TITRESENCYCLOP.ser`
- 6) dans ``/SOURCE/`` créer les classeurs `public` et `public/utilisateurs`, `TCPriboDB` et `TCPriboDB/log`
- 7) créer le conteneur `docker build -t tcpribodb .` 
- 8) créer le réseau `docker network create ribonetwork`
- 9) `docker run --name tcpribo  --network ribonetwork -it -p 8080:8080 --mount type=bind,src=/pathto/SOURCE/BNKriboDB_SER,target=/home/ribo_tcp/app/BNKriboDB_SER --mount type=bind,src=/pathto/SOURCE/public,target=/home/ribo_tcp/app/public --mount type=bind,src=/apthto/SOURCE/TCPriboDB/log/,target=/home/ribo_tcp/app/log tcpribo`

En dehors d'un docker il suffit de lancer:

```julia --project=. ribodb_server.jl``` mais dans ce cas les classeurs ``BNKriboDB_SER`` et son contenu, `STATSRIBODB` et son contenu, `public` et son contenu et `log` doivent être dans le classeur `TCPriboDB`

__Note importante__ : Les banques de données indispensable sont disponibles sur demande en attendant d'avoir un site ftp.


## le serveur TCP

Après le lancement direct ou via le conteneur et une attente de 1minute au moins, il retourne une phrase disant que _gallica_ est prête et qu'il écoute.
```gallica fait```
```à l'écoute .../TCPriboDB```

C'est __ribodb_server.jl__ qui orchestre tout  après avoir fabriqué _gallica_ via __Module_bnf.jl__ en se mettant à l'écoute du client.
Dans _gallica_ le format du commentaire fasta est inversé pour mettre la hiérarchie taxonomique en tête ce qui accélère les recherches dans la majorité des cas, de l'ordre de 10%. 
```Legionella_pneumophila_subsp._pneumophila-Legionella-Legionellaceae-Legionellales-Gammaproteobacteria-Pseudomonadota-Bacteria#S~GCF_000586135.1~NZ_JFID01000033.1~[1666..2361]~9189190```
```NZ_JFID01000033.1~[1666..2361]```est conservé pour avoir un identifiant unique en cas de protéines présentes plusieurs fois.

Quand le serveur reçoit une requête il utilise les fonctions des modules en passant primitivement par __Module_moteur_server.jl__.
La sélection des modalités de recherche est le fait de __Module_fonctions_recherche.jl__ et _ancilla_ fait le service.

Le serveur ne traite qu'une requête à la fois et assure l'extraction, la sauvegarde des fasta dans _public/utilisateurs_ et il retourne la localisation de l'atelier , le nom de la famille et les nombres de séquences recrutées dans _uniques_ et _multiples_.

```["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "ul1", "78894", "178"]```

sous forme d'un vecteur de Strings.

## le client : clientlocal.jl (hors docker) ou clientutile.jl (via docker)

clientutile.jl n'est __pas situé dans le classeur du serveur__, sa place est dans le classeur du site web, ou ailleurs.
Pour l'instant c'est une ergonomie minimale, il sera ultérieurement introduit dans le moteur su site Web.
Attention il ne fonctionne que si l'on a un docker lancé par docker run  -it  -p 8020:8080 tcpribo (sinon changer l'adresse du port)
clientlocal.jl accède au serveur sans docker au port 8080 de la machine.
Tels-quels ce sont des exemples de test et il faut donc écrire des applications sur ces exemples.

### la phrase de requête

Elle peut être envoyée par n'importe quelle fonction de n'importe quel language mais doit satisfaire la structure suivante:
On envoie au serveur TCP _une phrase_ contenant  __Type_de_recherche; Famille_protéique_ou_RNA; *Sequence_recherchées_dans_commentaire_fasta*;*Critères_de_qualité*; Identifiant_utilisateur__
Pour des raisons pratiques __Identifiant_utilisateur__ est envoyé par le client, sinon du fait de multiples clients possibles il y a des conflits.
En fait la phrase sera coupée pour donner les différentes variables sous forme de String (Famille_protéique_ou_RNA) ou de Vector{String} comme ["Esch","Dickey","Staphy"] ou ["#T","#C"] (Cf. supra. italiques)
Exemple :
```F1;us2;Esch,Dickey,Staphy;#T,#C;1735828360516_2oerXaH1```
En Julia l'identifiant __unique__ utilisateur est donné par les fonctions suivantes:

    using Dates
    using Random
    function renvoieepoch()
        dte=datetime2epoch(x::DateTime) = (Dates.value(x) - Dates.UNIXEPOCH)
        return dte(now())
    end
    function uniqueutilisateursimplifié()
        timestamp::String=string(renvoieepoch())
        random_string::String = randstring(8)  # 8-char random
        fichtempo::String =  "$(timestamp)_$(random_string)"
        return fichtempo
    end

__Notes Importantes__ : 
Le "\_" étant signifiant dans le programme du serveur, il ne faut pas nommer le classeur contenant les programmes avec le "\_" comme séparateur.
Le timestamp (dans le complexe timestamp_random_string) est utilisé par le serveur pour la maintenance du site (fonction ``putzen``)et ne peut être changé.

### Emploi
On doit donner (via le site) la familles désirée (Les items sont envoyés un à un par le site), les items du commentaire fasta correspondant à des choses de la taxonomie, des numéroGB et des taxId. Pour le site 5 items peuvent être recherchés parallélement. 
```"Esch,Dickey,Staphy"``` est valable car la recherche se fait sur des fragments. Noter que le ```-``` est signifiant ! ceci peut résoudre des conflits de dénommination.
On doit éventuellement donner les (n<4) critères de qualité (ceux précédés de #) 
```"#T,#R,#E"```
Et fixer le type de recherche : 

 1) __F1__ est la recherche un par un dans la liste (on envoie uniquement une recherche mais on fait la liste par itération). Ceci est indispensable pour le site web qui affiche les résultats en temps réel.
Les fasta sont extraits et placés dans ```public/utilisateur``` et les décomptes sont renvoyés.
Noter que ```public/utilisateur/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG"``est le chemin complet. Le classeur _task..._ contient _atelier..._ mais cette disposition permet de zipper le classeur _atelier..._ qui est alors placé dans le bon classeur utilisateur. Attention l'espace utilisateur est vidé totalement des classeurs plus vieux que 1/2heure. Comme ceci est déclenché par une requête, faire une requête après 35 minutes vide tout, sans rémission.

 2) Le second envoi __COMPTE__ fait la même chose mais de façon simplifée, elle ne fait que renvoyer les décomptes.

 3) Un troisième type d'envoi est possible c'est l'envoi en bloc de tout pour un traitement par lot, sans sorties écran. Il a été abandonné mais est facile à replacer à partir de la boucle dans __clientutile.jl__

__Note importante__ : comme ceci doit être placé derrière le serveur web et totalement intégré à GenieFramework, il n'y a pas actuellement de méthode d'envoi autre. Pour tester il faut remplacer par ce que vous voulez entre les lignes 84 et 88.
Mais vous pouvez écrire une interface plus aisée, y compris dans un autre langage puisque tout part au serveur TCP dans un format String.

### Résultats

#### Sorties écran

Elles ont pour vocation de disparaître dans la version site web.

    Sending message: F1;16SrDNA;Bacillota;;1735725055995_FyIxLgVG
    ["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "16SrDNA", "30674"]

    Sending message: F1;ul1;Bacillota;;1735725055995_FyIxLgVG
    ["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "ul1", "78894", "178"]

    Sending message: F1;ul2;Bacillota;;1735725055995_FyIxLgVG
    ["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "ul2", "78532", "144"]

    Sending message: F1;ul3;Bacillota;;1735725055995_FyIxLgVG
    ["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "ul3", "78750", "200"]

    Sending message: F1;us2;Bacillota;;1735725055995_FyIxLgVG
    ["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "us2", "79006", "101"]

    Sending message: F1;us3;Bacillota;;1735725055995_FyIxLgVG
    ["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "us3", "78547", "139"]

    Sending message: F1;us4;Bacillota;;1735725055995_FyIxLgVG
    ["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "us4", "79013", "262"]

Le serveur ne traite qu'une requête à la fois et assure l'extraction, la sauvegarde des fasta dans _public/utilisateurs_.
Chaque retour du serveur comporte le chemin vers "task/atelier" car les requêtes étant envoyées séquentiellement et potentiellement pas plusieurs utilisateurs, il n'y a pas de moyen de ne recevoir cette information au début ou à la fin de l'interrogation (ou pas de solution garantie).
Outre la retourne la localisation de l'atelier, on récupère le nom de la famille et les nombres de séquences recrutées dans _uniques_ et _multiples_.

```["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG", "ul1", "78894", "178"]```

sous forme d'un vecteur de Strings.

#### Les classeurs de sortie

Noter que le commentaire fasta des sorties est aussi allégé en supprimant les informations de sortie des HMM et des contrôles et les redondances.
```>Parvimonas_micra|EYE_30#S~GCF_023148065.1~NZ_JAHXOH010000001.1~C[414169..414864]~33033~11=Bacteria-Bacillota-Tissierellia-Tissierellales-Peptoniphilaceae-Parvimonas```
Tout est dans les classeur _task_ et _atelier_ et classé par famille.
```["public/utilisateurs/task_1735725055995_FyIxLgVG/atelier_1735725055995_FyIxLgVG/[FAMILLE]/"```
où l'on retrouve les 4 fichiers habituels.

## Performances

Les performances sont acceptables et par exemple rechercher tous les fasta de la banque pour Bacillota sans critère de qualité se fait en 11 secondes.
Le tmeps de réalisation est linéaire en fonction du nombre de recherches (taxonomie et qualité et nombre de familles), rechercher "Escherichia" ou "Esch" prend le même temps.

Le serveur est multi-utilisateur, le temps de réponse dépend linéairement du nombre d'utilisateurs simultanés, mais même pour 10 utilisateurs strictement simultanés il reste acceptable et la plupart des recherches se font en moins d'une minute.

## License

"""
ribodb_server.jl Le serveur TCP de riboDB

Copyright or © or Copr. UCBL Lyon, France;  
contributor : [Jean-Pierre Flandrois] ([2024/12/20])
[JP.flandrois@univ-lyon1.fr]

This software is a computer program whose purpose is to create a TCP server interface to the riboDB sequence database.

This software is governed by the [CeCILL|CeCILL-B|CeCILL-C] license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the [CeCILL|CeCILL-B|CeCILL-C]
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the [CeCILL|CeCILL-B|CeCILL-C] license and that you accept its terms.

"""