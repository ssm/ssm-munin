class munin::package (
  $package_name = [],
  $package_ensure = present
){
  if $package_name == [] {
    $packages = [ $munin::node::package_name, $munin::master::package_name ].unique.filter |$item| { $item != undef and $item =~ String[1] }
  }
  else {
    $pacakages = $package_name
  }
  package { $packages:
    ensure => $package_ensure,
  }
}
