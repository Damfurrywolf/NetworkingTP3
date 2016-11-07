#! /usr/bin/env perl

use Getopt::Long;
use IO::Socket;
use Switch;

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
    print $connection "Bienvenue au jeu de Monty Hall!\n";
    print $connection "Une des trois portes numérotées de 1 à 3 cache\n";
    print $connection "une voiture, les deux autres cachent une chèvres.\n";
    print $connection "Choisissez un nombre entre 1 et 3 : ";
    #On intercepte l'information envoyé par l'ordinateur
    #distant, tant que celui-ci n'entre pas la chaine de
    #caractère quit suivie de la toucher entrée
    while($input ne "quit\r\n")
    {
      my $voiture = rand(3) + 1;
      my $chevreUn = 0;
      my $chevreDeux = 0;

      switch ($voiture) {
	case 1 { $chevreUn = 2; $chevreDeux = 3;}
        case 2 { $chevreUn = 1; $chevreDeux = 3;}
        case 3 { $chevreun = 1; $chevreDeux = 2;}
      }
      
      #On attend que l'ordinateur distant nous envoie
      #des caractères
      $input = <$connection>;

      if ($input eq "3" || $input eq "2" || $input eq "1") {
	print $connection "Vous avez choisi la porte " .$input. ".\n\n";
        
        my $porteAnimateur = 0;
        my $porteAlternative = 0;
        if ($input eq $chevreUn) {
          $porteAnimateur = $chevreDeux;
          $porteAlternative = $voiture;
        } else if ($input = eq $chevreDeux){
          $porteAnimateur = $chevreUn;
          $porteAlternative = $voiture;
        } else {
          $porteAnimateur = $chevreUn;
          $porteAlternative = $chevreDeux;
        }

        print $connection "Le présentateur ouvre la porte " .$porteAnimateur . ", qui cachait une chèvre !\n";
        print $connection "Garderez-vous la porte". $input." ou changerez-vous pour la porte " .$porteAlternative.".\n";
        
        print $connection "Choisissez entre ".$input." (rester) et " .$porteAlternative." (changer) : ";
        my $oldInput = $input;

        while ($oldInput eq $input || $input eq $porteAlternative) {
          $input = <$connection>;
        }           
	
        if ($input eq $voiture) {
	  print $connection "Félicitations! Vous avez gagné la voiture!";
	} else {
	  print $connection "Hélas, vous ne gagnez qu'une chèvre...";
	}
         
      }
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
