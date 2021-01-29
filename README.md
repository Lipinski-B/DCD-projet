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
│   └── playlistUser.json
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

Cette partie permets la mise en place d'une recomandation basé sur le jeux de données d'1 millions de playlist traité au préalable. 
En entrée on attend un fichier Json d'une ou plusieurs playlists utilisateur désireux d'avoir des recommandations musical basé sur ces musiques. 
Un fichier test (playlistUser.json) a été placé dans ce projet, mais il est possible d'utilisé votre propore playlist si celle-ci est sous la forme suivante : 

{
  "items": [
    {
      "track": {
        "album": {
          "name": "",
          "uri": ""
        },
        "artists": [
          {
            "name": "",
            "uri": ""
          }
        ],
        "name": "",
        "uri": ""
      }}]}
      
Les uri référencent respectivement l'album_uri, artists_uri et track_uri de spotify.
 
Si une playlist Spotify est déjà existante il est possible d'extraire celle-ci facilment via l'API Spotify. Un exemple de ce qui peut être fait pour récupérer les données a été inséré dans le projet (todo dire ou quoi ...).

A la sortie du script un fichier indiquant les premieres recommandations basé sur les musiques existantent du dataset de départ seront fournie par le biai d'un fichier de sortie. 
    
