-- @description Tutoriels et Démos
-- @version 1.8
-- @author Lee JULIEN For ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log
--   # 2024-09-18 - Ajout de 3 kits DrumAccess


-- Fonction pour ouvrir une page web
local function openURL(url)
 local OS = reaper.GetOS()
 if OS == "OSX32" or OS == "OSX64" then
  os.execute('open "" "' .. url .. '"')
 else
  os.execute('start "" "' .. url .. '"')
 end
end

-- Liste des noms de sous-menus
local subMenus = {
 {
  name = "01 - L'Installation et la Configuration",
  actions = {
   {name = "01.01 Présentation", url = "https://reaperaccessible.fr/tutoriels/01.1%20Pr%C3%A9sentation.mp3"},
   {name = "01.02 Les réglages de Windows", url = "https://reaperaccessible.fr/tutoriels/01.2%20Installation%20et%20Configuration%20-%20Les%20r%C3%A9glages%20de%20Windows.mp3"},
   {name = "01.03 L'installation et les réglages de NVDA", url = "https://reaperaccessible.fr/tutoriels/01.3%20Installation%20et%20Configuration%20-%20Installation%20et%20r%C3%A9glage%20de%20NVDA.mp3"},
   {name = "01.04 L'installation de l'extension LBL pour NVDA", url = "https://reaperaccessible.fr/tutoriels/01.4%20Installation%20et%20Configuration%20-%20Installation%20de%20LBL.mp3"},
   {name = "01.05 L'installation de Reaper et Osara", url = "https://reaperaccessible.fr/tutoriels/01.5%20Installation%20et%20Configuration%20-%20Installation%20de%20Reaper%20et%20Osara.mp3"},
   {name = "01.06 Les réglages de l'interface audio", url = "https://reaperaccessible.fr/tutoriels/01.6%20Installation%20et%20Configuration%20-%20Les%20r%C3%A9glages%20de%20l'interface%20audio.mp3"},
   {name = "01.07 Installation du LangPack, de S W S et les scripts ReaperAccessible avec ReaPack", url = "https://reaperaccessible.fr/tutoriels/01.7%20Installation%20et%20Configuration%20-%20Installation%20de%20S%20W%20S%20et%20les%20scripts%20ReaperAccessible%20avec%20ReaPack.mp3"},
   {name = "01.08 L'installation du Keymap ReaperAccessible", url = "https://reaperaccessible.fr/tutoriels/01.8%20Installation%20et%20Configuration%20-%20Installation%20du%20keymap%20Reaper%20Accessible.mp3"},
   {name = "01.09 Configuration d'Osara", url = "https://reaperaccessible.fr/tutoriels/01.9%20Installation%20et%20Configuration%20-%20Configuration%20d'Osara.mp3"},
   {name = "01.10 La gestion des fichiers dans Reaper", url = "https://reaperaccessible.fr/tutoriels/01.10%20Installation%20et%20Configuration%20-%20La%20gestion%20des%20fichiers%20dans%20Reaper.mp3"},
   {name = "01.11 Les paramètres du projet", url = "https://reaperaccessible.fr/tutoriels/01.11%20Installation%20et%20Configuration%20-%20Les%20param%C3%A8tres%20du%20projet.mp3"},
   {name = "01.12 Comment utiliser votre license de Reaper sur tous vos ordinateurs", url = "https://reaperaccessible.fr/tutoriels/01.12%20Installation%20et%20Configuration%20-%20Comment%20utiliser%20ma%20licence%20Reaper%20sur%20tous%20mes%20PC.mp3"},
   {name = "01.13 Comment accéder rapidement au volume des Applications et des Périphériques", url = "https://reaperaccessible.fr/tutoriels/01.13%20Installation%20et%20Configuration%20-%20Comment%20acc%C3%A9der%20rapidement%20aux%20volumes%20des%20applications%20et%20des%20p%C3%A9riph%C3%A9riques.mp3"}
  }
 },
 {
  name = "02 - Les Préférences de Reaper",
  actions = {
   {name = "02.01 L'onglet général", url = "https://reaperaccessible.fr/tutoriels/02.1%20Onglet%20G%C3%A9n%C3%A9ral.mp3"},
   {name = "02.02 L'onglet projet", url = "https://reaperaccessible.fr/tutoriels/02.2%20Onglet%20Projet.mp3"},
   {name = "02.03 Le sous-onglet Copie de sauvegarde et Valeurs par défaut des pistes et envois", url = "https://reaperaccessible.fr/tutoriels/02.3%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20Le%20sous-onglet%20Copie%20de%20sauvegarde%20et%20Valeurs%20par%20d%C3%A9faut%20des%20pistes%20et%20envois.mp3"},
   {name = "02.04 L'onglet Audio", url = "https://reaperaccessible.fr/tutoriels/02.4%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20L'onglet%20Audio.mp3"},
   {name = "02.05 Le sous-onglet Périphérique", url = "https://reaperaccessible.fr/tutoriels/02.5%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20Le%20sous-onglet%20P%C3%A9riph%C3%A9rique.mp3"},
   {name = "02.06 Le sous-onglet Périphérique Midi", url = "https://reaperaccessible.fr/tutoriels/02.6%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20Le%20sous-onglet%20P%C3%A9riph%C3%A9rique%20MIDI.mp3"},
   {name = "02.07 Le sous-onglet Mutage/Solotage", url = "https://reaperaccessible.fr/tutoriels/02.7%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20Le%20sous-onglet%20Mutage%20et%20solotage.mp3"},
   {name = "02.08 Le sous-onglet Lecture", url = "https://reaperaccessible.fr/tutoriels/02.8%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20Le%20sous-onglet%20Lecture.mp3"},
   {name = "02.09 Le sous-onglet Scrub/Jog", url = "https://reaperaccessible.fr/tutoriels/02.9%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20Scrub%20et%20Jog.mp3"},
   {name = "02.10 Le sous-onglet Enregistrement", url = "https://reaperaccessible.fr/tutoriels/02.10%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20Le%20sous-onglet%20Enregistrement.mp3"},
   {name = "02.11 L'onglet Comportement d'édition", url = "https://reaperaccessible.fr/tutoriels/02.11%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20L'onglet%20Comportement%20d'%C3%A9dition.mp3"},
   {name = "02.12 Le sous-onglet VST de l'onglet Plug-ins", url = "https://reaperaccessible.fr/tutoriels/02.12%20Les%20pr%C3%A9f%C3%A9rences%20de%20Reaper%20-%20Le%20sous-onglet%20VST.mp3"}
  }
 },
 {
  name = "03 - Le Panneau de Contrôle des Pistes",
  actions = {
   {name = "03.01 Présentation du Panneau de Contrôle des Pistes, et des Menus", url = "https://reaperaccessible.fr/tutoriels/03.1%20-%20Le%20PCP%20-%20Pr%C3%A9sentation%20du%20panneau%20de%20contr%C3%B4le%20de%20pistes%20et%20des%20menus.mp3"},
   {name = "03.02 Les fonctions de base", url = "https://reaperaccessible.fr/tutoriels/03.2%20Le%20PCP%20-%20Les%20fonctions%20de%20base.mp3"}
  }
 },
 {
  name = "04 - Le Transport",
  actions = {
   {name = "04.01 Les Raccourcis Claviers", url = "https://reaperaccessible.fr/tutoriels/04.1%20Le%20transport%20-%20Les%20raccourcis%20claviers.mp3"},
   {name = "04.02 Le Scrubing et le Zoom", url = "https://reaperaccessible.fr/tutoriels/04.2%20Le%20transport%20-%20Le%20scrubing%20et%20le%20zoom.mp3"}
  }
 },
 {
  name = "05 - Les Pistes",
  actions = {
   {name = "05.01 Les bases", url = "https://reaperaccessible.fr/tutoriels/05.1%20Les%20pistes%20-%20Les%20bases.mp3"},
   {name = "05.02 Le Monitoring et l'armement", url = "https://reaperaccessible.fr/tutoriels/05.2%20Les%20pistes%20-%20Le%20monitoring%20et%20l'armement%20des%20pistes%20pour%20l'enregistrement.mp3"},
   {name = "05.03 Les Entrée et les Sorties", url = "https://reaperaccessible.fr/tutoriels/05.3%20Les%20pistes%20-%20Les%20entr%C3%A9es%20et%20les%20sorties.mp3"},
   {name = "05.04 La sélection Non Contigu des Pistes", url = "https://reaperaccessible.fr/tutoriels/05.4%20Les%20pistes%20-%20La%20s%C3%A9lection%20non%20contigu%20des%20pistes.mp3"},
   {name = "05.05 La Piste Master", url = "https://reaperaccessible.fr/tutoriels/05.5%20Les%20pistes%20-%20La%20piste%20master.mp3"},
   {name = "05.06 Comment sauvegarder une Piste Modèle", url = "https://reaperaccessible.fr/tutoriels/05.6%20Les%20pistes%20-%20Comment%20sauvegarder%20une%20piste%20mod%C3%A8le.mp3"},
   {name = "05.07 Les Dossier de Pistes", url = "https://reaperaccessible.fr/tutoriels/05.7%20Les%20pistes%20-%20Les%20dossiers%20de%20pistes.mp3"},
   {name = "05.08 Comment Router le Signal Audio d'une Piste vers une autre", url = "https://reaperaccessible.fr/tutoriels/05.8%20Les%20pistes%20-%20Comment%20router%20le%20Signal%20Audio%20d'une%20Piste%20vers%20une%20autre.mp3"},
   {name = "05.09 Envois et Retours de Piste", url = "https://reaperaccessible.fr/tutoriels/05.9%20Les%20pistes%20-%20Les%20envois%20et%20les%20retours%20de%20piste.mp3"},
   {name = "05.10 Comment faire un rendu ou un gel de piste", url = "https://reaperaccessible.fr/tutoriels/05.10%20Les%20pistes%20-%20Comment%20faire%20un%20rendu%20ou%20un%20gel%20de%20piste.mp3"}
  }
 },
 {
  name = "06 - Le Métronome, la Signature Rythmique et la Grille de Division",
  actions = {
   {name = "06.01 Le Métronome", url = "https://reaperaccessible.fr/tutoriels/06.1%20M%C3%A9tronome,%20signature%20rythmique%20et%20grille%20de%20division%20-%20Le%20m%C3%A9tronome.mp3"},
   {name = "06.02 Le BPM et la Signature Rythmique", url = "https://reaperaccessible.fr/tutoriels/06.2%20M%C3%A9tronome,%20signature%20rythmique%20et%20grille%20de%20division%20-%20BPM%20et%20signature%20rythmique.mp3"},
   {name = "06.03 La Grille de Division", url = "https://reaperaccessible.fr/tutoriels/06.3%20M%C3%A9tronome,%20signature%20rythmique%20et%20grille%20de%20division%20-%20Les%20grille%20de%20division.mp3"}
  }
 },
 {
  name = "07 - L'Enregistrement",
  actions = {
   {name = "07.01 Les Bases de l'Enregistrement", url = "https://reaperaccessible.fr/tutoriels/07.1%20Enregistrement%20-%20Les%20bases.mp3"},
   {name = "07.02 Le Pré-roll", url = "https://reaperaccessible.fr/tutoriels/07.2%20Enregistrement%20-%20Pr%C3%A9-roll%20activ%C3%A9.mp3"},
   {name = "07.03 Le mode Punch Automatique sur la Sélection Temporelle", url = "https://reaperaccessible.fr/tutoriels/07.3%20Enregistrement%20-%20Mode%20punch%20automatique%20sur%20la%20s%C3%A9lection%20temporelle.mp3"},
   {name = "07.04 Le mode Punch Automatique sur l'Objet sélectionné", url = "https://reaperaccessible.fr/tutoriels/07.4%20Enregistrement%20-%20Mode%20punch%20automatique%20sur%20les%20Objets.mp3"},
   {name = "07.05 L'Enregistrement en Boucle", url = "https://reaperaccessible.fr/tutoriels/07.5%20Enregistrement%20-%20L'enregistrement%20en%20boucle.mp3"},
   {name = "07.06 Lancer un Enregistrement en fonction du mode Ripple", url = "https://reaperaccessible.fr/tutoriels/07.6%20Enregistrement%20-%20Lancer%20un%20enregistrement%20en%20fonction%20du%20mode%20Ripple.mp3"}
  }
 },
 {
  name = "08 - Les Objets",
  actions = {
   {name = "08.01 Les Bases", url = "https://reaperaccessible.fr/tutoriels/08.1%20Les%20Objets%20-%20Les%20bases.mp3"},
   {name = "08.02 La Sélection non Contigu des Objets", url = "https://reaperaccessible.fr/tutoriels/08.2%20Les%20Objets%20-%20La%20s%C3%A9lection%20non%20contigu%20des%20Objets.mp3"},
   {name = "08.03 L'Édition des Objets", url = "https://reaperaccessible.fr/tutoriels/08.3%20Les%20Objets%20-%20l'%C3%A9dition%20d'Objet.mp3"},
   {name = "08.04 Les bords d'Objet", url = "https://reaperaccessible.fr/tutoriels/08.4%20Les%20Objets%20-%20Les%20bords%20d'Objet.mp3"},
   {name = "08.05 Les mode d'édition Ripple", url = "https://reaperaccessible.fr/tutoriels/08.5%20Les%20Objets%20-%20Les%20modes%20d'%C3%A9dition%20ripple.mp3"},
   {name = "08.06 Le déplacement d'Objet", url = "https://reaperaccessible.fr/tutoriels/08.6%20Les%20Objets%20-%20Le%20d%C3%A9placement%20d'Objet.mp3"},
   {name = "08.07 Normaliser les Objets", url = "https://reaperaccessible.fr/tutoriels/08.7%20Les%20Objets%20-%20Normaliser%20les%20Objets.mp3"},
   {name = "08.08 La Zone Sélectionnée des Objets", url = "https://reaperaccessible.fr/tutoriels/08.8%20Les%20Objets%20-%20La%20zone%20s%C3%A9lectionn%C3%A9e%20de%20l'Objet.mp3"},
   {name = "08.09 Les Fondus", url = "https://reaperaccessible.fr/tutoriels/08.9%20Les%20Objets%20-%20Les%20fondus.mp3"},
   {name = "08.10 La Vitesse et la Hauteur Tonale", url = "https://reaperaccessible.fr/tutoriels/08.10%20Les%20Objets%20-%20La%20vitesse%20et%20la%20hauteur%20tonale.mp3"},
   {name = "08.11 Les Prises d'Objet", url = "https://reaperaccessible.fr/tutoriels/08.11%20Les%20Objets%20-%20Les%20prises%20d'Objet.mp3"},
   {name = "08.12 Le comportement du Mixage des Objets", url = "https://reaperaccessible.fr/tutoriels/08.12%20Les%20Objets%20-%20Le%20comportement%20du%20mixage%20des%20Objets.mp3"},
   {name = "08.13 La Base Temporelle des Objets", url = "https://reaperaccessible.fr/tutoriels/08.13%20Les%20Objets%20-%20La%20base%20temporelle%20des%20Objets.mp3"},
   {name = "08.14 Définir le mode de Canal de la Prise", url = "https://reaperaccessible.fr/tutoriels/08.14%20Les%20Objets%20-%20D%C3%A9finir%20le%20mode%20de%20canal%20de%20la%20prise.mp3"},
   {name = "08.15 Les Propriétés de l'Objet ou de la Prise - Partie 1", url = "https://reaperaccessible.fr/tutoriels/08.15%20Les%20Objets%20-%20Les%20propri%C3%A9t%C3%A9s%20de%20l'Objet%20ou%20de%20la%20prise%20-%20partie%201.mp3"},
   {name = "08.16 Les Propriétés de l'Objet ou de la Prise - Partie 2", url = "https://reaperaccessible.fr/tutoriels/08.16%20Les%20Objets%20-%20Les%20propri%C3%A9t%C3%A9s%20de%20l'Objet%20ou%20de%20la%20prise%20-%20partie%202.mp3"},
   {name = "08.17 Les Propriétés de l'Objet ou de la Prise - Partie 3", url = "https://reaperaccessible.fr/tutoriels/08.17%20Les%20Objets%20-%20Les%20propri%C3%A9t%C3%A9s%20de%20l'Objet%20ou%20de%20la%20prise%20-%20partie%203.mp3"},
   {name = "08.18 Les Propriétés de la Source de l'Objet", url = "https://reaperaccessible.fr/tutoriels/08.18%20Les%20Objets%20-%20Les%20propri%C3%A9t%C3%A9s%20de%20la%20source%20de%20l'Objet.mp3"},
   {name = "08.19 Déplacer le Contenu des Objets", url = "https://reaperaccessible.fr/tutoriels/08.19%20Les%20Objets%20-%20D%C3%A9placer%20le%20contenu%20des%20Objets.mp3"},
   {name = "08.20 Étirer ou réduire les Objets pour les adapter à la sélection temporelle", url = "https://reaperaccessible.fr/tutoriels/08.20%20Les%20Objets%20-%20%C3%89tirer%20ou%20r%C3%A9duire%20les%20Objets%20pour%20les%20adapter%20%C3%A0%20la%20s%C3%A9lection%20temporelle.mp3"},
   {name = "08.21 La Scission Dynamique des Objets - Partie 1", url = "https://reaperaccessible.fr/tutoriels/08.21%20Les%20Objets%20-%20La%20scission%20dynamique%20des%20Objets%20-%20Partie%201.mp3"},
   {name = "08.22 La scission dynamique des Objets - Partie 2", url = "https://reaperaccessible.fr/tutoriels/08.22%20Les%20Objets%20-%20La%20scission%20dynamique%20des%20Objets%20-%20Partie%202.mp3"}
  }
 },
 {
  name = "09 - La Sélection Temporelle",
  actions = {
   {name = "09.01 Les Bases", url = "https://reaperaccessible.fr/tutoriels/09.1%20La%20s%C3%A9lection%20temporelle%20-%20Les%20bases.mp3"},
   {name = "09.02 La Sélection et l'Edition d'Objet", url = "https://reaperaccessible.fr/tutoriels/09.2%20La%20s%C3%A9lection%20temporelle%20-%20La%20s%C3%A9lection%20et%20l'%C3%A9dition%20d'Objet.mp3"},
   {name = "09.03 Les mode Ripple", url = "https://reaperaccessible.fr/tutoriels/09.3%20La%20s%C3%A9lection%20temporelle%20-%20Les%20modes%20Ripple.mp3"}
  }
 },
 {
  name = "10 - Les Marqueurs",
  actions = {
   {name = "10.01 Les Marqueurs de Projet", url = "https://reaperaccessible.fr/tutoriels/10.1%20Les%20marqueurs%20-%20Les%20marqueurs%20de%20projet.mp3"},
   {name = "10.02 Les Marqueurs de Tempo - Partie 1", url = "https://reaperaccessible.fr/tutoriels/10.2%20Les%20marqueurs%20-%20Les%20marqueurs%20de%20tempo%20partie1.mp3"},
   {name = "10.03 Les Marqueurs de Tempo - Partie 2", url = "https://reaperaccessible.fr/tutoriels/10.3%20Les%20marqueurs%20-%20Les%20marqueurs%20de%20tempo%20Partie%202.mp3"},
   {name = "10.04 Les Marqueurs d'Étirement", url = "https://reaperaccessible.fr/tutoriels/10.4%20Les%20marqueurs%20-%20Les%20marqueurs%20d'%C3%A9tirement.mp3"}
  }
 },
 {
  name = "11 - Les Projets",
  actions = {
   {name = "11.01 Ouvrir, Sauvegarder et Fermer un Projet", url = "https://reaperaccessible.fr/tutoriels/11.1%20Les%20projets%20-%20Ouvrir,%20sauvegarder%20et%20fermer%20un%20projet.mp3"},
   {name = "11.02 Créer et Sauvegarder un Modèle de Projet", url = "https://reaperaccessible.fr/tutoriels/11.2%20Les%20projets%20-%20Comment%20cr%C3%A9er%20et%20sauvegarder%20un%20mod%C3%A8le%20de%20projet.mp3"},
   {name = "11.03 Nettoyer un Projet", url = "https://reaperaccessible.fr/tutoriels/11.3%20Les%20projets%20-%20-%20Comment%20nettoyer%20mon%20projet.mp3"},
   {name = "11.04 La Vitesse et la Hauteur Tonale du Projet", url = "https://reaperaccessible.fr/tutoriels/11.4%20Les%20projets%20-%20La%20vitesse%20et%20la%20hauteur%20tonale%20du%20projet.mp3"},
   {name = "11.05 Le comportement du Mixage des Objets", url = "https://reaperaccessible.fr/tutoriels/11.5%20Les%20projets%20-%20Le%20comportement%20du%20mixage%20des%20Objets.mp3"},
   {name = "11.06 La base temporelle des Objets", url = "https://reaperaccessible.fr/tutoriels/11.6%20Les%20projets%20-%20La%20base%20temporelle%20des%20Objets.mp3"},
   {name = "11.07 Les onglets de projet", url = "https://reaperaccessible.fr/tutoriels/11.7%20Les%20projets%20-%20Les%20onglets%20de%20projet.mp3"},
   {name = "11.08 Les sous projets", url = "https://reaperaccessible.fr/tutoriels/11.8%20Les%20projets%20-%20Les%20sous-projets.mp3"},
  }
 },
 {
  name = "12 - L'observateur de Crête",
  actions = {
   {name = "12.01 Les Bases", url = "https://reaperaccessible.fr/tutoriels/12.1%20L'observateur%20de%20cr%C3%AAte%20-%20Les%20bases.mp3"},
   {name = "12.02 L'observation de Crête en DB", url = "https://reaperaccessible.fr/tutoriels/12.2%20L'observateur%20de%20cr%C3%AAte%20-%20L'observation%20cr%C3%AAte%20en%20dB.mp3"},
   {name = "12.03 Comment être alerté par un bip lorsque le niveau sonore franchit un seuil", url = "https://reaperaccessible.fr/tutoriels/12.3%20L'observateur%20de%20cr%C3%AAte%20-%20Comment%20%C3%AAtre%20alert%C3%A9%20par%20un%20bip%20lorsque%20le%20volume%20sonore%20franchit%20un%20seuil.mp3"}
  }
 },
 {
  name = "13 - L'Explorateur de Média",
  actions = {
   {name = "13.01 Les Bases", url = "https://reaperaccessible.fr/tutoriels/13.1%20L'explorateur%20de%20m%C3%A9dia%20-%20Les%20bases.mp3"},
   {name = "13.02 La Gestion des Répertoires", url = "https://reaperaccessible.fr/tutoriels/13.2%20L'explorateur%20de%20m%C3%A9dia%20-%20La%20gestion%20des%20r%C3%A9pertoires.mp3"},
   {name = "13.03 Le Transport", url = "https://reaperaccessible.fr/tutoriels/13.3%20L'explorateur%20de%20m%C3%A9dia%20-%20Le%20transport.mp3"},
   {name = "13.04 Les Actions des Fichiers Média", url = "https://reaperaccessible.fr/tutoriels/13.4%20L'explorateur%20de%20m%C3%A9dia%20-%20les%20actions%20des%20fichiers%20m%C3%A9dia.mp3"},
   {name = "13.05 Créer une Base de Données", url = "https://reaperaccessible.fr/tutoriels/13.5%20L'explorateur%20de%20m%C3%A9dia%20-%20Cr%C3%A9er%20une%20base%20de%20donn%C3%A9es.mp3"}
  }
 },
 {
  name = "14 - Les Boucles",
  actions = {
   {name = "14.01 Les Bases", url = "https://reaperaccessible.fr/tutoriels/14.1%20Les%20boucles%20-%20Les%20bases.mp3"}
  }
 },
 {
  name = "15 - Les FX",
  actions = {
   {name = "15.01 Présentation de la fenêtre des FX", url = "https://reaperaccessible.fr/tutoriels/15.1%20Les%20FX%20-%20Pr%C3%A9sentation%20de%20la%20fen%C3%AAtre%20FX.mp3"},
   {name = "15.02 Les FX de Piste", url = "https://reaperaccessible.fr/tutoriels/15.2%20Les%20FX%20-%20Les%20FX%20de%20piste.mp3"},
   {name = "15.03 les FX de la Piste Master", url = "https://reaperaccessible.fr/tutoriels/15.3%20Les%20FX%20-%20Les%20FX%20de%20la%20piste%20master.mp3"},
   {name = "15.04 Les Chaines d'FX", url = "https://reaperaccessible.fr/tutoriels/15.4%20Les%20FX%20-%20Les%20cha%C3%AEnes%20d'FX.mp3"},
   {name = "15.05 Les Préréglages", url = "https://reaperaccessible.fr/tutoriels/15.5%20Les%20FX%20-%20Les%20pr%C3%A9r%C3%A9glages.mp3"},
   {name = "15.06 Comment changer le Préréglage d'un FX à partir du PCP", url = "https://reaperaccessible.fr/tutoriels/15.6%20Les%20FX%20-%20Comment%20changer%20de%20pr%C3%A9r%C3%A9glage%20dans%20le%20PCP%20sans%20ouvrir%20la%20fen%C3%AAtre%20FX.mp3"},
   {name = "15.07 Les FX d'Objet ou de Prise", url = "https://reaperaccessible.fr/tutoriels/15.7%20Les%20FX%20-%20Les%20FX%20d'Objet%20ou%20de%20prise.mp3"},
   {name = "15.08 Assigner un Paramètre d'FX à un contrôleur MIDI", url = "https://reaperaccessible.fr/tutoriels/15.8%20Les%20FX%20-%20Assigner%20un%20param%C3%A8tre%20d'FX%20sur%20un%20controlleur%20MIDI.mp3"},
   {name = "15.09 Les dossiers de la fenêtre FX", url = "https://reaperaccessible.fr/tutoriels/15.9%20Les%20FX%20-%20Les%20dossiers%20de%20la%20fen%C3%AAtre%20FX.mp3"},
   {name = "15.10 Ajouter un FX avec un raccourcis clavier", url = "https://reaperaccessible.fr/tutoriels/15.10%20Les%20FX%20-%20Ajouter%20un%20FX%20avec%20un%20raccourcis%20clavier.mp3"},
   {name = "15.11 Les fichiers au format .fxp", url = "https://reaperaccessible.fr/tutoriels/15.11%20Les%20FX%20-%20Les%20fichiers%20au%20format%20.fxp.mp3"},
   {name = "15.12 Chaîne d'FX d'entrée de piste", url = "https://reaperaccessible.fr/tutoriels/15.12%20Les%20FX%20-%20Cha%C3%AEne%20d'FX%20d'entr%C3%A9e%20de%20piste.mp3"}
  }
 },
 {
  name = "16 - Le MIDI",
  actions = {
   {name = "16.01 Introduction", url = "https://reaperaccessible.fr/tutoriels/16.1%20Le%20MIDI%20-%20Introduction.mp3"},
   {name = "16.02 L'Enregistrement", url = "https://reaperaccessible.fr/tutoriels/16.2%20Le%20MIDI%20-%20L'enregistrement.mp3"},
   {name = "16.03 La Sélection", url = "https://reaperaccessible.fr/tutoriels/16.3%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20-%20La%20s%C3%A9lection.mp3"},
   {name = "16.04 Le Transport dans l'Editeur MIDI", url = "https://reaperaccessible.fr/tutoriels/16.4%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20-%20Le%20transport.mp3"},
   {name = "16.05 L'édition (partie 1)", url = "https://reaperaccessible.fr/tutoriels/16.5%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20-%20L'%C3%A9dition%20partie%201.mp3"},
   {name = "16.06 L'édition (Partie 2)", url = "https://reaperaccessible.fr/tutoriels/16.6%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20-%20L'%C3%A9dition%20partie%202.mp3"},
   {name = "16.07 L'édition (Partie 3)", url = "https://reaperaccessible.fr/tutoriels/16.7%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20-%20L'%C3%A9dition%20partie%203.mp3"},
   {name = "16.08 La Quantification MIDI", url = "https://reaperaccessible.fr/tutoriels/16.8%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20-%20La%20quantification.mp3"},
   {name = "16.09 Comment Humaniser les Notes", url = "https://reaperaccessible.fr/tutoriels/16.9%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20-%20Comment%20humaniser%20les%20notes.mp3"},
   {name = "16.10 La Sélection Temporelle dans l'Editeur MIDI", url = "https://reaperaccessible.fr/tutoriels/16.10%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20-%20La%20s%C3%A9lection%20temporelle.mp3"},
   {name = "16.11 Le MIDI - La base temporelle des Objets", url = "https://reaperaccessible.fr/tutoriels/16.11%20Le%20MIDI%20-%20La%20base%20temporelle%20des%20Objets.mp3"},
   {name = "16.12 Le MIDI - L'éditeur MIDI en liste d'événements - Introduction", url = "https://reaperaccessible.fr/tutoriels/16.12%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20en%20liste%20d'%C3%A9v%C3%A9nements%20-%20Introduction.mp3"},
   {name = "16.13 Le MIDI - L'éditeur MIDI en liste d'événements - Comment utiliser le filtre d'événement MIDI", url = "https://reaperaccessible.fr/tutoriels/16.13%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20en%20liste%20d'%C3%A9v%C3%A9nements%20-%20Comment%20utiliser%20le%20filtre%20d'%C3%A9v%C3%A9nement%20MIDI.mp3"},
   {name = "16.14 Le MIDI - L'éditeur MIDI en liste d'événements - L'édition des événements MIDI", url = "https://reaperaccessible.fr/tutoriels/16.14%20Le%20MIDI%20-%20L'%C3%A9diteur%20MIDI%20en%20liste%20d'%C3%A9v%C3%A9nements%20-%20L'%C3%A9dition%20des%20%C3%A9v%C3%A9nements%20MIDI.mp3"},
  }
 },
 {
  name = "17 - Les Rendus",
  actions = {
   {name = "17.01 Rendu de fichier Stéréo", url = "https://reaperaccessible.fr/tutoriels/17.1%20Les%20rendus%20-%20Rendu%20de%20fichier%20st%C3%A9r%C3%A9o.mp3"},
   {name = "17.02 Rendu en Pistes Séparées (stems)", url = "https://reaperaccessible.fr/tutoriels/17.2%20Les%20rendus%20-%20Rendu%20en%20pistes%20s%C3%A9par%C3%A9s%20(stems).mp3"},
   {name = "17.03 Rendu des Pistes Sélectionnées via le Master", url = "https://reaperaccessible.fr/tutoriels/17.3%20Les%20rendus%20-%20Rendu%20des%20pistes%20s%C3%A9lectionn%C3%A9es%20via%20le%20master.mp3"},
   {name = "17.04 Rendu des Objets Média sélectionnés", url = "https://reaperaccessible.fr/tutoriels/17.4%20Les%20rendus%20-%20Rendu%20des%20Objets%20m%C3%A9dia%20s%C3%A9lectionn%C3%A9s.mp3"},
   {name = "17.05 Rendu des Objets Média sélectionnés via le Master", url = "https://reaperaccessible.fr/tutoriels/17.5%20Les%20rendus%20-%20Rendu%20des%20Objets%20m%C3%A9dia%20s%C3%A9lectionn%C3%A9s%20via%20le%20master.mp3"},
   {name = "17.06 Rendu de la Sélection Temporelle", url = "https://reaperaccessible.fr/tutoriels/17.6%20Les%20rendus%20-%20Le%20rendu%20de%20la%20s%C3%A9lection%20temporelle.mp3"},
   {name = "17.07 Le Rendu d'une prise Audio ou MIDI", url = "https://reaperaccessible.fr/tutoriels/17.7%20Les%20rendus%20-%20Le%20rendu%20d'une%20prise%20audio%20ou%20MIDI.mp3"},
  }
 },
 {
  name = "18 - Le Sampler de Reaper (Le ReaSamplomatic 5000)",
  actions = {
   {name = "18.01 Présentation du menu du ReaSamplomatic 5000", url = "https://reaperaccessible.fr/tutoriels/18.1%20RS5k%20-%20Pr%C3%A9sentation%20du%20menu%20du%20sampler%20de%20Reaper%20ReaSamplOmatic5000%20(Cockos).mp3"},
   {name = "18.02 Exporter chaque objet sélectionné vers une instance du RS5K en Mode Batterie", url = "https://reaperaccessible.fr/tutoriels/18.2%20RS5K%20-%20Exporter%20chaque%20objet%20s%C3%A9lectionn%C3%A9%20vers%20une%20instance%20du%20RS5K%20(Mode%20batterie).mp3"},
   {name = "18.03 Exporter chaque objet sélectionné vers une instance du RS5K en Mode boucle", url = "https://reaperaccessible.fr/tutoriels/18.3%20RS5K%20-%20Exporter%20chaque%20objet%20s%C3%A9lectionn%C3%A9%20vers%20une%20instance%20du%20RS5K%20(Mode%20boucle).mp3"}
  }
 },
 {
  name = "19 - Les Enveloppes",
  actions = {
   {name = "19.01 Les Enveloppes de Piste", url = "https://reaperaccessible.fr/tutoriels/19.1%20Les%20enveloppes%20-%20Les%20enveloppes%20de%20pistes.mp3"},
   {name = "19.02 Les enveloppes d'Objet ou de prises", url = "https://reaperaccessible.fr/tutoriels/19.2%20Les%20enveloppes%20-%20Les%20enveloppes%20d'Objet%20ou%20de%20prises.mp3"},
   {name = "19.03 Le Déplacement des Points d'Enveloppe", url = "https://reaperaccessible.fr/tutoriels/19.3%20Les%20enveloppes%20-%20Le%20d%C3%A9placement%20des%20points%20d'enveloppes.mp3"},
   {name = "19.04 L'enveloppe de tempo du master", url = "https://reaperaccessible.fr/tutoriels/19.4%20Les%20enveloppes%20-%20L'enveloppe%20de%20tempo%20du%20master.mp3"},
   {name = "19.05 Créer une enveloppe de paramètre d'FX", url = "https://reaperaccessible.fr/tutoriels/19.5%20Les%20enveloppes%20-%20Cr%C3%A9er%20une%20enveloppe%20de%20param%C3%A8tre%20d'FX.mp3"}
  }
 },
 {
  name = "20 - Les Éléments Transitoires",
  actions = {
   {name = "20.01 Les Bases", url = "https://reaperaccessible.fr/tutoriels/20.1%20Les%20%C3%A9l%C3%A9ments%20transitoires%20-%20Les%20bases.mp3"},
  }
 },
 {
  name = "21 - Les Actions",
  actions = {
   {name = "21.01 Les Bases", url = "https://reaperaccessible.fr/tutoriels/21.1%20Les%20actions%20-%20Les%20bases.mp3"},
   {name = "21.02 Les Actions Personnalisées", url = "https://reaperaccessible.fr/tutoriels/21.2%20Les%20actions%20-%20Les%20actions%20personnalis%C3%A9es.mp3"}
  }
 },
 {
  name = "22 - L'automatisation",
  actions = {
   {name = "22.01 Les Objets d'automatisation, les bases", url = "https://reaperaccessible.fr/tutoriels/22.1%20-%20Les%20Objets%20d'automatisation,%20les%20bases.mp3"},
   {name = "22.02 Les réglages des préférences pour les automatisations", url = "https://reaperaccessible.fr/tutoriels/22.2%20-%20Les%20r%C3%A9glages%20des%20pr%C3%A9f%C3%A9rences%20pour%20les%20automatisations.mp3"},
   {name = "22.03 Les actions dédiés aux Objets d'automatisation", url = "https://reaperaccessible.fr/tutoriels/22.3%20-%20Les%20actions%20d%C3%A9di%C3%A9s%20aux%20Objets%20d'automatisation.mp3"},
   {name = "22.04 Comment utiliser les Objet d'automatisation - Partie 1", url = "https://reaperaccessible.fr/tutoriels/22.4%20-%20Comment%20utiliser%20les%20Objet%20d'automatisation%20-%20Partie%201.mp3"},
   {name = "22.05 Comment utiliser les Objet d'automatisation - Partie 2", url = "https://reaperaccessible.fr/tutoriels/22.5%20-%20Comment%20utiliser%20les%20Objet%20d'automatisation%20-%20Partie%202.mp3"},
  }
 },
 {
  name = "23 - Cette Série n'a pas de tuto pour le moment.",
  actions = {
   {name = "23.01 Suggérer une idée de tutoriel ici.", url = "https://reaperaccessible.fr/index.php/fr/nous-joindre"},
  }
 },
 {
  name = "25 - Comment Faire Pour",
  actions = {
   {name = "25.01 Comment transformer une Source Mono en Stéréo", url = "https://reaperaccessible.fr/tutoriels/25.1%20Comment%20faire%20pour%20-%20Transformer%20une%20source%20mono%20en%20stereo.mp3"},
   {name = "25.02 Comment Détecter le Tempo d'une Chanson - Partie 1", url = "https://reaperaccessible.fr/tutoriels/25.2%20-%20Comment%20faire%20pour%20-%20D%C3%A9tecter%20le%20tempo%20d'une%20chanson%20partie1.mp3"},
   {name = "25.03 Comment Détecter le Tempo d'une Chanson - Partie 2", url = "https://reaperaccessible.fr/tutoriels/25.3%20-%20Comment%20faire%20pour%20-%20D%C3%A9tecter%20le%20tempo%20d'une%20chanson%20partie2.mp3"},
   {name = "25.04 Comment contrôler plusieurs instruments avec mon clavier maître", url = "https://reaperaccessible.fr/tutoriels/25.4%20Comment%20faire%20pour%20-%20Contr%C3%B4ler%20plusieurs%20instruments%20avec%20mon%20clavier%20ma%C3%AEtre.mp3"},
   {name = "25.05 Insérer un Silence sur Une ou Toutes les Pistes", url = "https://reaperaccessible.fr/tutoriels/25.5%20Comment%20faire%20pour%20-%20Ins%C3%A9rer%20un%20silence%20sur%20une%20ou%20toutes%20les%20pistes.mp3"},
   {name = "25.06 Supprimer une Partie d'Objet sur Une ou Toutes les Pistes", url = "https://reaperaccessible.fr/tutoriels/25.6%20Comment%20faire%20pour%20-%20Supprimer%20une%20partie%20d'Objet%20sur%20une%20ou%20toutes%20les%20pistes.mp3"},
   {name = "25.07 Comment créer une vélocité MIDI croissante ou décroissante", url = "https://reaperaccessible.fr/tutoriels/25.7%20Comment%20faire%20pour%20-%20Cr%C3%A9er%20une%20v%C3%A9locit%C3%A9%20MIDI%20croissante%20ou%20d%C3%A9croissante%20rapidement.mp3"},
   {name = "25.08 Extraire les instruments en pistes séparées d'un morceau original avec SpleeterGui", url = "https://reaperaccessible.fr/tutoriels/25.8%20Comment%20faire%20pour%20-%20Extraire%20les%20instruments%20en%20pistes%20s%C3%A9par%C3%A9es%20d'un%20morceau%20original%20avec%20SpleeterGui.mp3"},
   {name = "25.09 Créer une piste audio de métronome", url = "25.09 Créer une piste audio de métronome"},
   {name = "25.10 Créer un sidechain avec un compresseur ou un NoiseGate", url = "https://reaperaccessible.fr/tutoriels/25.10%20Comment%20faire%20pour%20-%20Cr%C3%A9er%20un%20sidechain%20avec%20un%20compresseur%20ou%20un%20NoiseGate.mp3"},
   {name = "25.11 Empêcher l'ouverture de la fenêtre pontée d'un plug-in 32 bit", url = "https://reaperaccessible.fr/tutoriels/25.11%20Comment%20faire%20pour%20-%20Emp%C3%AAcher%20l'ouverture%20de%20la%20fen%C3%AAtre%20pont%C3%A9e%20d'un%20plug-in%2032%20bit.mp3"},
   {name = "25.12 Augmenter ou diminuer les transitoires rapidement avec le plugin JS Transient Controller", url = "https://reaperaccessible.fr/tutoriels/25.12%20-%20Comment%20faire%20pour%20-%20Augmenter%20ou%20diminuer%20les%20transitoires%20rapidement%20avec%20le%20plugin%20JS%20Transient%20Controller.mp3"},
   {name = "25.13 - Comment faire pour installer un plugin, celui-ci est Sennheiser - AMBEO Orbit", url = "https://reaperaccessible.fr/tutoriels/25.13%20-%20Comment%20faire%20pour%20installer%20un%20plugin,%20celui-ci%20est%20Sennheiser%20-%20AMBEO%20Orbit.mp3"},
   {name = "25.14 - Comment faire pour enregistrer la sortie de Windows avec Reaper", url = "https://reaperaccessible.fr/tutoriels/25.14%20-%20Comment%20faire%20pour%20enregistrer%20la%20sortie%20de%20Windows%20avec%20Reaper.mp3"},
   {name = "25.15 - Comment attribuer une fonction Windows à une touche du clavier avec le logiciel SharpKeys", url = "https://reaperaccessible.fr/tutoriels/25.15%20-%20Comment%20attribuer%20une%20fonction%20Windows%20native%20%C3%A0%20une%20touche%20du%20clavier%20avec%20le%20logiciel%20SharpKeys.mp3"},
   {name = "25.16 - Comment créer une jonction avec le logiciel HardLink Software", url = "https://reaperaccessible.fr/tutoriels/25.16%20-%20Comment%20cr%C3%A9er%20une%20jonction%20avec%20le%20logiciel%20HardLink%20Software.mp3"},
   {name = "25.17 - Le plugin MIDI Note Repeater pour les beatmakers", url = "https://reaperaccessible.fr/tutoriels/25.17%20-%20Le%20plugin%20MIDI%20Note%20Repeater%20pour%20les%20beatmakers.mp3"},
  }
 },
 {
  name = "26 - Les Instruments Virtuels",
  actions = {
   {name = "26.01 IK Multimedia - Hammond B-3X", url = "https://reaperaccessible.fr/tutoriels/26.1%20IK%20Multimedia%20-%20Hammond%20B-3X.mp3"},
  }
 },
 {
  name = "27 - Les Surfaces de Contrôle (CSI)",
  actions = {
   {name = "27.01 - Présentation et installation de CSI", url = "https://reaperaccessible.fr/tutoriels/27.1%20-%20Pr%C3%A9sentation%20et%20installation%20de%20CSI.mp3"},
   {name = "27.02 - Le transport avec CSI", url = "https://reaperaccessible.fr/tutoriels/27.2%20-%20Le%20transport%20avec%20CSI.mp3"},
   {name = "27.03 - Le menu FX avec CSI", url = "https://reaperaccessible.fr/tutoriels/27.3%20-%20Le%20menu%20FX%20avec%20CSI.mp3"},
   {name = "27.04 - Qu'est-ce qu'un fichier .zon et comment en créer un avec CSI", url = "https://reaperaccessible.fr/tutoriels/27.4%20-%20Qu'est-ce%20qu'un%20fichier%20.zon%20et%20comment%20en%20cr%C3%A9er%20un%20avec%20CSI.mp3"},
   {name = "27.05 - Le template CSI - Partie 1", url = "https://reaperaccessible.fr/tutoriels/27.5%20-%20Le%20template%20CSI%20-%20Partie%201.mp3"},
   {name = "27.06 - Le template CSI - Partie 2", url = "https://reaperaccessible.fr/tutoriels/27.6%20-%20Le%20template%20CSI%20-%20Partie%202.mp3"},
   {name = "27.07 - Le generateur pour CSI", url = "https://reaperaccessible.fr/tutoriels/27.7%20-%20Le%20generateur%20pour%20CSI.mp3"},
   {name = "27.08 - Comment installer les scripts CSI", url = "https://reaperaccessible.fr/tutoriels/27.8%20-%20Comment%20installer%20les%20scripts%20CSI.mp3"},
   {name = "27.09 - Comment mettre à jour CSI", url = "https://reaperaccessible.fr/tutoriels/27.9%20-%20Comment%20mettre%20%C3%A0%20jour%20CSI.mp3"},
   {name = "27.10 - Comment fonctionne le script Dernier paramètre touché avec CSI", url = "https://reaperaccessible.fr/tutoriels/27.10%20-%20Comment%20fonctionne%20le%20script%20Dernier%20param%C3%A8tre%20touch%C3%A9%20avec%20CSI.mp3"}
  }
 },
 {
  name = "28 - DrumAccess",
  actions = {
   {name = "28.01 Présentation", url = "https://reaperaccessible.fr/drumaccess/tutoriels/francais/DrumAccess%20-%20Free%20Kit%20Demo%20-%20Fran%C3%A7ais.mp3"},
   {name = "28.02 Créer un compte", url = "https://reaperaccessible.fr/index.php/fr/inscription"},
   {name = "28.03 M'inscrire à la lettre d'information de DrumAccess", url = "https://reaperaccessible.fr/index.php/fr/lettre-dinformation"},
   {name = "28.04 Comment installer une librairie DrumAccess", url = "https://reaperaccessible.fr/drumaccess/tutoriels/francais/DrumAccess%20-%20Comment%20installer%20DrumAccess.mp3"},
   {name = "28.05 Comment installer et utiliser les scripts DrumAccess", url = "https://reaperaccessible.fr/drumaccess/tutoriels/francais/DrumAccess%20-%20Comment%20installer%20et%20utiliser%20les%20scripts%20pour%20DrumAccess.mp3"},
   {name = "28.06 Comment installer et utiliser le logiciel Hard Link", url = "https://reaperaccessible.fr/drumaccess/tutoriels/francais/DrumAccess%20-%20Comment%20cr%C3%A9er%20une%20jonction%20avec%20le%20logiciel%20HardLink%20Software.mp3"},
   {name = "28.07 DrumAccess - Free Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess-free-kit-fr"},
   {name = "28.08 DrumAccess - C&C - Player Date II Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumacces-candc-player-date-ii-kit-fr"},
   {name = "28.09 DrumAccess - Camco - Oaklawn Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/da-camco-oaklawn-kit-fr"},
   {name = "28.10 DrumAccess - Canopus - Maple Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumacces-canopus-maple-kit-fr"},
   {name = "28.11 DrumAccess - Craviotto - Solid Shell Walnut Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-craviotto-solid-shell-walnut-kit-fr"},
   {name = "28.12 DrumAccess - DW - Collectors Maple Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-dw-collectorsmaplekit-fr"},
   {name = "28.13 DrumAccess - Fibes - Maple Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-fibes-maple-kit-fr"},
   {name = "28.14 DrumAccess - Gretsch - Broadkaster Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/da-gretsch-broadkaster-kit-fr"},
   {name = "28.15 DrumAccess - Ludwig - Calfskin 1930s Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-ludwig-calfskin-1930s-kit-fr"},
   {name = "28.16 DrumAccess - Ludwig - Stainless Steel Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-ludwig-stainlesssteelkit-fr"},
   {name = "28.17 DrumAccess - Ludwig - Superclassic 70s Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-ludwig-superclassic-70s-kit-fr"},
   {name = "28.18 DrumAccess - Mayer - Bros Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-mayer-bros-kit-fr"},
   {name = "28.19 DrumAccess - Pearl - Masters Extra Maple Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumacces-pearl-masters-extra-maple-kit-fr"},
   {name = "28.20 DrumAccess - Percussions Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-percussions-kit-fr"},
   {name = "28.21 DrumAccess - Q Drum Co. - Copper Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-q-drum-co-copper-kit-fr"},
   {name = "28.22 DrumAccess - Slingerland - Radio King 1940s Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-slingerland-radio-king-1940s-kit-fr"},
   {name = "28.23 DrumAccess - Tama - Starclassic Performer Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess-tama-starclassic-performer-kit-fr"},
   {name = "28.24 DrumAccess - Gretsch - Broadkaster Kit Damped", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/da-gretsch-broadkaster-kit-damped-fr"},
   {name = "28.25 DrumAccess - Yamaha - Recording Custom Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-yamaha-recording-custom-kit-fr"},
   {name = "28.26 DrumAccess - Gretsch - 60s Round Badge Kit Damped", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-gretsch-60s-round-badge-kit-damped-fr"},
   {name = "28.27 DrumAccess - DW - Deep Blue Oyster Kit", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-dw-deep-blue-oyster-kit-fr"},
   {name = "28.28 DrumAccess - Gretsch - USA Custom Kit - Damped", url = "https://reaperaccessible.fr/index.php/fr/drumaccess-librairies-de-batterie/drumaccess/drumaccess-gretsch-usa-custom-kit-damped-fr"},
   {name = "28.29 DrumAccess - Mapex - Velvetone Kit", url = "https://reaperaccessible.fr/index.php?option=com_content&view=article&id=438:drumaccess-mapex-velvetone-kit-fr&catid=58&lang=fr&Itemid=213"},
   {name = "28.30 DrumAccess - Mapex - Mars Birtch Shell Kit", url = "https://reaperaccessible.fr/index.php?option=com_content&view=article&id=443:drumaccess-mapex-mars-birch-shell-kit&catid=58&lang=fr&Itemid=213"},
   {name = "28.31 DrumAccess - Ludwig - 1950s Kit", url = "https://reaperaccessible.fr/index.php?option=com_content&view=article&id=521:drumaccess-ludwig-1950s-kit&catid=58&lang=fr&Itemid=213"},
  }
 },


}

-- Fonction pour afficher le menu principal
local function showMainMenu()
 local menu_str = ""
 for i, subMenu in ipairs(subMenus) do
  menu_str = menu_str .. subMenu.name .. "|"
 end
 local selection = gfx.showmenu(menu_str)
 if selection > 0 then
  local selectedSubMenu = subMenus[selection]
  local actions = selectedSubMenu.actions
  local actions_str = ""
  for i, action in ipairs(actions) do
   actions_str = actions_str .. action.name .. "|"
  end
  local actionSelection = gfx.showmenu(actions_str)
  if actionSelection > 0 then
   openURL(actions[actionSelection].url)
  end
 end
end

-- Appel de la fonction pour afficher le menu principal
showMainMenu()
