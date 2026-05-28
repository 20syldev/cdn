#!/bin/bash
# =========================================================
# MN - French translations
# =========================================================

LANG_DISPLAY_NAME="Français"

# -------------------- GENERIC -------------------- #

T_OR="ou"
T_YES="Oui"
T_NO="Non"
T_CONFIRM="Confirmer"
T_CANCEL="Annuler"
T_CURRENT="actuel"
T_PRESS_KEY="[Appuyez sur une touche]"
T_PRESS_KEY_CONTINUE="[Appuyez sur une touche pour continuer]"
T_CHOICE="Choix"
T_REQUIRED="est requis"

# -------------------- CRUD -------------------- #

T_EDIT_PREFIX="MODIFIER"
T_DEL_PREFIX="SUPPRIMER"
T_ADDED="ajouté(e)"
T_UPDATED="mis(e) à jour"
T_DELETED="supprimé(e)"
T_KEEP_HINT="vide = garder"
T_PASS_CURRENT="Mot de passe actuel"
T_PASS_KEEP_DEL="vide = garder, '-' = supprimer"

# -------------------- UI -------------------- #

T_FOOTER_BASE="[↑/↓] Navigation  [R] Retour"
T_FOOTER_QUIT="[↑/↓] Navigation  [Q] Quitter"
T_FOOTER_CRUD="[E] Éditer  [D] Supprimer  [V] Voir"
T_FOOTER_ADD="[Enter] Ajouter"
T_FOOTER_SELECT="[Enter] Sélectionner"
T_PAGE_INFO="Page"
T_PAGE_CHANGE="[←/→] Changer de page"

# -------------------- MENUS -------------------- #

T_MENU_TITLE="MN - MANUEL PERSONNEL"
T_MENU_CONNEXIONS="CONNEXIONS - Connexions SSH / Custom"
T_MENU_REPOS="REPOS - Repositories GitHub"
T_MENU_ALIAS="ALIAS - Gestion des alias"
T_MENU_FUNCS="FUNCS - Gestion des fonctions"
T_MENU_DOCS="DOCS - Documentation"
T_MENU_CONFIG="CONFIG - Configuration"
T_MENU_HELP="HELP - Aide"
T_MENU_TITLE_CONFIG="CONFIGURATION"
T_MENU_TITLE_DOCS="DOCUMENTATION"

# -------------------- HELP -------------------- #

T_HELP_TITLE="AIDE - MN"
T_HELP_USAGE="UTILISATION"
T_HELP_NAV="NAVIGATION"
T_HELP_FILES="FICHIERS"
T_HELP_CMD_MAIN="Ouvre le menu principal"
T_HELP_CMD_CONN="Ouvre le menu des connexions"
T_HELP_CMD_REPOS="Ouvre le menu des repositories"
T_HELP_CMD_ALIAS="Ouvre le menu des alias"
T_HELP_CMD_FUNCS="Ouvre le menu des fonctions"
T_HELP_CMD_DOCS="Ouvre la documentation"
T_HELP_CMD_UPDATE="Met à jour mn"
T_HELP_CMD_UNINSTALL="Désinstalle mn"
T_HELP_CMD_HELP="Affiche cette aide"
T_HELP_NAV_ARROWS="Naviguer dans le menu"
T_HELP_NAV_ENTER="Sélectionner l'option"
T_HELP_NAV_BACK="Retour au menu principal"
T_HELP_NAV_QUIT="Quitter"
T_HELP_NAV_ACTIONS="Éditer / Supprimer / Voir"

# -------------------- ERRORS -------------------- #

T_ERR_UNKNOWN="Option inconnue"
T_ERR_HELP_HINT="Utilisez mn help pour voir l'aide"

# -------------------- MODULE CONNEXIONS -------------------- #

T_CONN_TITLE="CONNEXIONS - SSH / Custom"
T_CONN_TITLE_ADD="AJOUTER UNE CONNEXION"
T_CONN_NOUN="connexion"
T_CONN_ADD_LABEL="Ajouter une connexion"
T_CONN_F_LABEL="Label"
T_CONN_F_IP="IP ou hostname"
T_CONN_F_DESC="Description"
T_CONN_F_TYPE="Type de connexion"
T_CONN_F_PASS="Mot de passe"
T_CONN_TYPE_SSH="ssh (standard)"
T_CONN_TYPE_CUSTOM="custom"
T_CONN_F_CMD="Commande personnalisée"
T_CONN_CONNECTING="Connexion à"

# -------------------- MODULE REPOS -------------------- #

T_REPOS_TITLE="REPOS - GITHUB"
T_REPOS_TITLE_ADD="AJOUTER UN REPO"
T_REPOS_NOUN="repo"
T_REPOS_ADD_LABEL="Ajouter un repo"
T_REPOS_F_NAME="Nom de l'alias"
T_REPOS_F_PATH="Chemin du repo"
T_REPOS_F_DESC="Description"
T_REPOS_OPENING="Ouverture de"

# -------------------- MODULE ALIAS -------------------- #

T_ALIAS_TITLE="ALIAS"
T_ALIAS_TITLE_ADD="AJOUTER UN ALIAS"
T_ALIAS_NOUN="alias"
T_ALIAS_ADD_LABEL="Ajouter un alias"
T_ALIAS_F_NAME="Nom de l'alias"
T_ALIAS_F_CMD="Commande"
T_ALIAS_F_DESC="Description"

# -------------------- MODULE FUNCS -------------------- #

T_FUNCS_TITLE="FONCTIONS"
T_FUNCS_TITLE_ADD="AJOUTER UNE FONCTION"
T_FUNCS_NOUN="fonction"
T_FUNCS_ADD_LABEL="Ajouter une fonction"
T_FUNCS_F_NAME="Nom de la fonction"
T_FUNCS_F_DESC="Description"
T_FUNCS_F_TYPE="Type"
T_FUNCS_TYPE_NORMAL="Script normal (exécuté comme commande)"
T_FUNCS_TYPE_SHELL="Fonction shell (sourcée, permet exit/cd)"
T_FUNCS_FILE_LABEL="Fichier"
T_FUNCS_SOURCED="sourcé dans le terminal"
T_FUNCS_NOT_FOUND="introuvable"
T_FUNCS_OPEN_EDITOR="Ouverture de l'éditeur pour éditer"
T_FUNCS_CONTENT="─── Contenu ───"
T_FUNCS_CONTENT_END="───────────────"
T_FUNCS_DEL_DAT="Supprimer l'entrée de functions.dat ?"
T_FUNCS_DEL_FILE="Supprimer aussi"
T_FUNCS_DEL_BOTH="Entrée et fichier supprimés !"
T_FUNCS_DEL_ENTRY="Entrée supprimée (fichier conservé)"

# -------------------- MODULE CONFIG -------------------- #

T_CONFIG_EDIT_MN="Éditer MN"
T_CONFIG_EDIT_ALIASES="Éditer ~/.bash_aliases"
T_CONFIG_EDIT_FUNCS="Éditer ~/.bash_functions"
T_CONFIG_EDIT_BASHRC="Éditer ~/.bashrc"
T_CONFIG_SOURCE="Source tous les fichiers"
T_CONFIG_LANG="Changer la langue"
T_CONFIG_UNINSTALL="Désinstaller mn"
T_CONFIG_UNINSTALL_TITLE="DÉSINSTALLATION"
T_CONFIG_UNINSTALL_CONFIRM="Supprimer mn et toutes ses données ?"
T_CONFIG_UNINSTALL_DONE="mn a été désinstallé. Rechargez votre shell."
T_CONFIG_REGEN_TITLE="RECHARGEMENT"
T_CONFIG_REGEN_MSG="Régénération des fichiers..."
T_CONFIG_REGEN_DONE="Fichiers régénérés ! Sourcés automatiquement à la fermeture de MN."
T_CONFIG_LANG_TITLE="LANGUE / LANGUAGE"
T_CONFIG_LANG_CURRENT="Langue actuelle"
T_CONFIG_LANG_CHANGED="Langue modifiée. Relancez mn pour appliquer."
T_CONFIG_EDITOR="Changer l'éditeur"
T_CONFIG_EDITOR_TITLE="ÉDITEUR"
T_CONFIG_EDITOR_CURRENT="Éditeur actuel"
T_CONFIG_EDITOR_CUSTOM="Commande personnalisée"
T_CONFIG_EDITOR_CHANGED="Éditeur modifié."
