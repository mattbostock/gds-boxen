class people::jennyd {
  include chrome
  include dropbox
  include gds_development
  include gds_virtualbox::42_latest
  include gds_osx::turn_off_dashboard
  include gds_resolver
  include gds_ssh_config
  include gds_vpn_profiles
  include iterm2::stable
  include openconnect
  include skype
  include sublime_text_3
  include sublime_text_3::package_control

  sublime_text_3::package { 'Awk': source => 'JohnNilsson/awk-sublime' }
  sublime_text_3::package { 'Cucumber': source => 'drewda/cucumber-sublime-bundle' }
  sublime_text_3::package { 'Cucumber Step Finder': source => 'danielfrey/sublime-cucumber-step-finder' }
  sublime_text_3::package { 'GitGutter': source => 'jisaacks/GitGutter' }
  sublime_text_3::package { 'Pretty JSON': source => 'dzhibas/SublimePrettyJson' }
  sublime_text_3::package { 'Puppet': source => 'russCloak/SublimePuppet' }
  sublime_text_3::package { 'SublimeLinter': source => 'SublimeLinter/SublimeLinter3' }
  sublime_text_3::package { 'SublimeLinter-jshint': source => 'SublimeLinter/SublimeLinter-jshint' }
  sublime_text_3::package { 'SublimeLinter-pylint': source => 'SublimeLinter/SublimeLinter-pylint' }
  sublime_text_3::package { 'SublimeLinter-ruby': source => 'SublimeLinter/SublimeLinter-ruby' }

  vagrant::plugin { 'vagrant-cachier': }
  vagrant::plugin { 'vagrant-zz-multiprovider-snap': }

  class { 'teams::infrastructure': manage_gitconfig => false }
  include teams::transition

  include projects::ci-deployment
  include projects::deployment
  include projects::deployment::creds
  include projects::frontend
  include projects::gds-api-adapters
  include projects::gds-sso
  include projects::govuk_content_api
  include projects::govuk_mirror-deployment
  include projects::imminence
  include projects::release
  include projects::rummager
  include projects::signonotron2
  include projects::static
  include projects::whitehall

  Boxen::Osx_defaults {
    user => $::luser,
  }

  include osx::disable_app_quarantine
  include osx::no_network_dsstores

  include osx::dock::autohide
  include osx::dock::dim_hidden_apps

  include osx::finder::show_hidden_files
  include osx::finder::unhide_library

  include osx::global::disable_autocorrect
  include osx::global::enable_keyboard_control_access
  include osx::global::tap_to_click

  class { 'osx::dock::hot_corners':
    bottom_left => "Mission Control"
  }

  class { 'osx::dock::position':
    position => 'left'
  }

  class { 'osx::global::natural_mouse_scrolling':
    enabled => false
  }

  class { 'osx::mouse::button_mode':
    mode => 2
  }

  class { 'osx::sound::interface_sound_effects':
    enable => false
  }

  package {
    [
      'python',
      'tmux',
      'node'
    ]:
    ensure => present,
  }

  package {
    [
      'virtualenv',
      'virtualenvwrapper'
    ]:
    ensure => present,
    provider => pip,
  }

  ssh_config::fragment { 'jennyd':
    source => 'puppet:///modules/people/jennyd/ssh-config',
  }

  file {"${boxen::config::srcdir}/puppet/development/Vagrantfile.localconfig":
    source => 'puppet:///modules/people/jennyd/Vagrantfile.localconfig',
    require => Class['Projects::Development']
  }

  $home     = "/Users/${::luser}"
  $dotfiles = "${home}/dotfiles"

  repository { $dotfiles:
    source  => 'jennyd/dotfiles',
    notify  => Exec['join-the-dots'],
  }

  exec { 'join-the-dots':
    cwd         => $dotfiles,
    command     => "bash join-the-dots.sh",
    logoutput   => true,
  }

  Git::Config::Global <| title == "core.excludesfile" |> {
    value => "~/.gitignore_global"
  }

  # Add this file to dotfiles, and symlink to it only if on mac:
  git::config::global { 'include.path':
    value => "${home}/.gitconfig_gds",
    # Don't need to require join-the-dots - include.path doesn't mind if the file is missing
  }

  # Remove this when .gitconfig_gds includes email:
  git::config::global { 'user.email':
    value => 'jenny.duckett@digital.cabinet-office.gov.uk'
  }

}
