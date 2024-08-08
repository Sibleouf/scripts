# Demander à l'utilisateur de renseigner les variables
$nom = Read-Host -Prompt "Entrez le nom de la clef"
$utilisateur = Read-Host -Prompt "Entrez le nom d'rasputilisateur pour la connexion SSH"
$adresseIP = Read-Host -Prompt "Entrez l'adresse IP du serveur distant"

# Générer la paire de clés sur l'ordinateur client
ssh-keygen -t ed25519 -a 256 -f "$env:USERPROFILE\.ssh\$nom"

# Lire le contenu de la clé publique
$contenuClePublique = Get-Content "$env:USERPROFILE\.ssh\$nom.pub"

# Préparer la commande à exécuter sur le serveur distant
$commandeSetup = @"
mkdir -p ~/.ssh && \
touch ~/.ssh/authorized_keys && \
chmod 700 ~/.ssh && \
chmod 600 ~/.ssh/authorized_keys && \
echo '$contenuClePublique' >> ~/.ssh/authorized_keys
"@ -replace "`r", ""

# Exécuter la commande sur le serveur distant en une seule connexion SSH
ssh $utilisateur@$adresseIP $commandeSetup

# Rajouter la nouvelle configuration au fichier de configuration SSH
$cheminConfig = "$env:USERPROFILE\.ssh\config"
@"
Host $nom
    HostName $adresseIP
    User $utilisateur
    IdentityFile "$env:USERPROFILE\.ssh\$nom"
"@ | Out-File -FilePath $cheminConfig -Append -Encoding utf8
