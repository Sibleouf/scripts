# Demander à l'utilisateur de renseigner les variables
$nom = Read-Host -Prompt "Entrez le nom de la clef"
$utilisateur = Read-Host -Prompt "Entrez le nom d'utilisateur pour la connexion SSH"
$adresseIP = Read-Host -Prompt "Entrez l'adresse IP du serveur distant"

# Générer la paire de clés sur l'ordinateur client
ssh-keygen -t ed25519 -a 256 -f "$env:USERPROFILE\.ssh\$nom"

# Copier la clé publique sur le serveur distant
$contenuClePublique = Get-Content "$env:USERPROFILE\.ssh\$nom.pub"
$commande = "echo '$contenuClePublique' >> ~/.ssh/authorized_keys"
ssh $utilisateur@$adresseIP $commande

# Rajouter la nouvelle configuration au fichier de configuration SSH
$cheminConfig = "$env:USERPROFILE\.ssh\config"
@"
Host $nom
    HostName $adresseIP
    User $utilisateur
    IdentityFile "$env:USERPROFILE\.ssh\$nom"
"@ | Out-File -FilePath $cheminConfig -Append -Encoding utf8




