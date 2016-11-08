#! /usr/bin/env perl

use Getopt::Long;
use IO::Socket;
use Switch;

#Déclaration des variables
my $server=0;
my $destinationIp = "";
my $port = 0;
my $help = 0;
#Affectation des valeurs correspondant aux options
#inscrites à la suite de l'appel du programme
my $options = GetOptions ("serveur" => \$server,
                          "d=s" => \$destinationIp,
                          "port=i" => \$port,
			  "help" => \$help);
#fix -d si vide
if ($server == 0 && $destinationIp == "" && $help == 0) {
  ErrorManager("Utiliser -s ou -d");
}

#On veut verifier que string is not null
if ($server != 0 && $destinationIp ne "") {
  ErrorManager("L'application ne peut pas utiliser -d et -s simultanément");
}

if ($port == 0 && $help == 0) {
  ErrorManager("L'option -p est obligatoire");
}

if ($help != 0 && $port == 0 && $server == 0 && $destinationIp == "") {
  print "==================================================\n";
  print "Voici le menu d'aide pour le TP3.\n";
  print "Le TP3 consiste à reproduire le jeu de Monty Hall.\n";
  print "Pour fonctionner le programme à qu'un serveur soit exécuté.\n";
  print "Par la suite un client pourra ce connecter et choisir une porte\n";
  print "afin de gagner une voiture ou bien une chèvre.\n";
  print "==================================================\n\n";
  print "-p port    : Sert à indiquer le numéro de port (est essentiel)\n";
  print "-s serveur : Sert à indiquer que l'application sera utilisé en mode serveur\n";
  print "-d         : Sert à indiquer l'adresse de destination avec qui le client ce connectera\n";
  print "-h help    : Sert à afficher le menu d'aide\n";
}

print "server = $server\n";
print "destination ip = $destinationIp\n";
print "port = $port\n";

if ($server) {
  $serveur = IO::Socket::INET->new( Proto => "tcp",
                                    LocalPort => $port,
                                    Listen => SOMAXCONN,
                                    Reuse => 1)
    or die ErrorManager("Impossible de se connecter sur le port $port en localhost");

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
        } elsif ($input eq $chevreDeux){
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
  my $filename = "Error.log";
  open(my $fh, ">>", $filename) or die "Impossible d’ouvrir
  Error.log en écriture : $!";

  my $errorMessage = @_[0];

  say $fh "\nErreur : " .$errorMessage." en date et heure du ".localtime();

  close($fh);
  die $errorMessage;
}
