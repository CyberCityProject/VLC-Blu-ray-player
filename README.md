# VLC-Blu-ray-player
# VLC Blu-ray (Windows)

Script PowerShell pour lire un Blu-ray physique dans VLC sur Windows.

Les disques du commerce sont chiffrés (AACS). VLC ne peut pas embarquer la base de clés. Ce script installe VLC s'il manque, télécharge les bibliothèques ouvertes `libaacs` et `libbdplus`, puis la base publique FindVUK. Aucune clé n'est stockée dans ce dépôt.

Prévu pour lire ses propres disques. Un Blu-ray Ultra HD (4K) reste en général illisible dans VLC.

## Prérequis

- Windows 10 ou plus récent
- PowerShell 5.1
- Connexion Internet
- Droits administrateur (copie dans `Program Files`)
- VLC installé sur le PC

## Utilisation

Dans le dossier du script :

```powershell
powershell -ExecutionPolicy Bypass -File .\vlc-bluray-setup.ps1
```

Le script se relance tout seul en administrateur. Il choisit `winx64` ou `winx86` selon l'emplacement de `vlc.exe`.

## Fichiers posés

| Fichier | Emplacement |
| --- | --- |
| `libaacs.dll`, `libbdplus.dll` et leurs dépendances | à côté de `vlc.exe` |
| `KEYDB.cfg` | `%APPDATA%\aacs\` |
| `KEYDB.cfg` | `%ProgramData%\aacs\` |

## Lecture

1. Insérer le disque.
2. VLC : **Média > Ouvrir un disque > Blu-ray**, puis choisir le lecteur.
3. Si le menu bloque la lecture, ouvrir le disque comme un dossier et lancer le plus gros fichier `BDMV\STREAM\*.m2ts`.

Les menus Java (BD-J) ne sont pas activés. Ils cassent souvent la lecture.

## Sources

Le script ne redistribue pas ces fichiers. Il les télécharge au moment de l'exécution.

- Bibliothèques : [KnugiHK/libaacs-libbdplus-windows](https://github.com/KnugiHK/libaacs-libbdplus-windows) (dernière release, archive `libaacs_libbdplus.zip`)
- Base de clés : [FindVUK](https://fvonline-db.bplaced.net/fv_download.php?lang=fra)

## Limites

- Blu-ray Ultra HD (4K) : non pris en charge par VLC dans le cas général.
- Disque récent absent de la base : la lecture peut échouer tant que la clé n'est pas publiée. Relancer le script met la base à jour.
- L'ancienne page `vlc-bluray.whoknowsmy.name` n'est plus utilisée.

---

# VLC Blu-ray (Windows)

PowerShell script to play a physical Blu-ray disc in VLC on Windows.

Retail discs are encrypted (AACS). VLC cannot ship the key database. This script installs VLC if it is missing, downloads the open libraries `libaacs` and `libbdplus`, then the public FindVUK database. No keys are stored in this repository.

Meant for playing discs you own. An Ultra HD (4K) Blu-ray generally still will not play in VLC.

## Requirements

- Windows 10 or later
- PowerShell 5.1
- Internet access
- Administrator rights (files are copied into `Program Files`)
- VLC installed

## Usage

From the script folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\vlc-bluray-setup.ps1
```

The script restarts itself as administrator. It picks `winx64` or `winx86` from the location of `vlc.exe`.

## Files written

| File | Location |
| --- | --- |
| `libaacs.dll`, `libbdplus.dll` and their dependencies | next to `vlc.exe` |
| `KEYDB.cfg` | `%APPDATA%\aacs\` |
| `KEYDB.cfg` | `%ProgramData%\aacs\` |

## Playback

1. Insert the disc.
2. In VLC: **Media > Open Disc > Blu-ray**, then select the drive.
3. If the menu blocks playback, open the disc as a folder and play the largest `BDMV\STREAM\*.m2ts` file.

Java menus (BD-J) are not enabled. They often break playback.

## Sources

The script does not redistribute these files. It downloads them when it runs.

- Libraries: [KnugiHK/libaacs-libbdplus-windows](https://github.com/KnugiHK/libaacs-libbdplus-windows) (latest release, archive `libaacs_libbdplus.zip`)
- Key database: [FindVUK](https://fvonline-db.bplaced.net/fv_download.php?lang=fra)

## Limits

- Ultra HD (4K) Blu-ray: not supported by VLC in the general case.
- A recent disc missing from the database: playback can fail until the key is published. Running the script again refreshes the database.
- The old page `vlc-bluray.whoknowsmy.name` is no longer used.
