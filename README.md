## ECD - Projet - Playlists

Ce projet porte sur la fouille de données. 
Les données sont des playlists de spotify récupérer sous format JSON (cf. Rapport pour le format). 1 million de playliste sont représentées dans des sous dossiers JSON de 100 playlists chaqu’un. Ces playlist ont été utilisé pour effectuer un clustering sur les différentes musiques, ainsi que des possible recommandatio basé sur ce que les écoutes personnels.

Structure du projet: 
``` bash
├── Script.r
├── Script.py
├── utilisation.py
├── Data
│   ├── matrice
│   └── playlistUsyer.json
└── src
    └── objectPipelineSklearn

```
Le projet s'articule en deux temps. 

##### 1.Entrainement
``` bash
                                           Script.r                             Script.py
Entrée : Million de playlists (json)  ──────────────────>  Sparse Matrice ──────────────────>  Sortie : modèle(objectPipelineSklearn)

```
Cette partie à déjà été traité et le fichier de sortie se trouve dans le dossier src du projet. 

##### 2.Utilisation

``` bash
                                      Utilisation.py                           
Entrée : playlistUser.json (json)  ──────────────────>   Sortie : recommandation.json ? 
```

















