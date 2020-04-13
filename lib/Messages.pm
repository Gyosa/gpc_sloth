package Messages;
use strict;
use warnings;
use Dancer2 appname => 'sloth';

# messages::developpement("un message de debug"); # gris
# messages::information("un message info");       # bleu
# messages::succes("un message success");         # vert
# messages::avertissement("un message warning");  # jaune
# messages::danger("un message danger");          # rouge

hook before => sub {
    var messages => [] if not defined var 'messages';
};

sub developpement {
    my $message = join("\n",@_);
    var messages => [] if not defined var 'messages';
    push @{var 'messages'}, { classe => 'debug', texte => $message };
}

sub information {
    my $message = join("\n",@_);
    var messages => [] if not defined var 'messages';
    push @{var 'messages'}, { classe => 'info', texte => $message };
}

sub succes {
    my $message = join("\n",@_);
    var messages => [] if not defined var 'messages';
    push @{var 'messages'}, { classe => 'success', texte => $message };
}

sub avertissement {
    my $message = join("\n",@_);
    var messages => [] if not defined var 'messages';
    push @{var 'messages'}, { classe => 'warning', texte => $message };
}

sub danger {
    my $message = join("\n",@_);
    var messages => [] if not defined var 'messages';
    push @{var 'messages'}, { classe => 'danger', texte => $message };
}

hook before_template => sub {
    my $tokens = shift;
    var messages => [] if not defined var 'messages';
    $tokens->{messages} = var 'messages';
};

true;

__END__
