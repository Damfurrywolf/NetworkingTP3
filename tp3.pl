#! /usr/bin/env perl

use Getopt::Long;
use IO::Socket;
#Déclaration des variables
my $server=0;
my $destinationIp = "";
my $port = 0;
#Affectation des valeurs correspondant aux options
#inscrites à la suite de l'appel du programme
my $options = GetOptions ("serveur" => \$server,
                          "d=s" => \$destinationIp,
                          "port=i" => \$port);
#fix -d si vide
if (!$server && $destinationIp) {
  die "Utiliser -s ou -d";
}

#On veut verifier que string is not null
if ($serveur && !($destinationIp eq "")) {
  print "allo";
  ErrorManager("L'application ne peut pas utiliser -d et -s simultanément");
}

if ($port == 0) {
  ErrorManager("L'option -p est obligatoire");
}

print "server = $server\n";
print "destination ip = $destinationIp\n";
print "port = $port\n";

if ($server) {
  $serveur = IO::Socket::INET->new( Proto => "tcp",
                                    LocalPort => $port,
                                    Listen => SOMAXCONN,
                                    Reuse => 1)
    or die "Impossible de se connecter sur le port $port en
localhost";

  while (my $connection = $serveur->accept())
  {
    #Affichage du nombre de connection au serveur
    $i++;
    print "Connection $i au serveur\n";
    #On envoie un mot de bienvenue à l'ordinateur distant
    print $connection "Bienvenue mon ami\n";
    #On intercepte l'information envoyé par l'ordinateur
    #distant, tant que celui-ci n'entre pas la chaine de
    #caractère quit suivie de la toucher entrée
    while($input ne "quit\r\n")
    {
      #On attend que l'ordinateur distant nous envoie
      #des caractères
      $input = <$connection>;
      #Affichage de la chaine dans la console du serveur
      print "$input";
      #Le serveur envoie une chaine de caractère à
      #l'ordinateur distant
      print $connection "Merci pour cette chaine\n";
    }

    #On réinitialise la variable input
    $input = "";
    #On ferme la connection
    close($connection);
  }
}

sub ErrorManager {
  open(OUTFILE, ">Error.log") or die "Impossible d’ouvrir
  Error.log en écriture : $!";

  my $errorMessage = @_[0];

  print OUTFILE "Erreur : " .$errorMessage." en date et heure du ".localtime();

  close(OUTFILE);
  die $errorMessage;

}
