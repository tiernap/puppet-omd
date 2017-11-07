class omd::repos::debian {  

include '::apt'

 apt::source { 'omd':
    location => 'http://labs.consol.de/repo/stable/debian',
    release => "$::lsbdistcodename",
    repos => 'main',
    key      => {
      'id'     => 'F2F97737B59ACCC92C23F8C7F8C1CA08A57B9ED7',
      'server' => 'keys.gnupg.net',
    },
    include  => {
      'src' => false,
    },
    before => Package['omd'],
  }

}
