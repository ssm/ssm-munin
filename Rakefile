require 'puppetlabs_spec_helper/rake_tasks'

require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_2sp_soft_tabs')
PuppetLint.configuration.send('disable_documentation')

Rake::Task[:spec].clear
task :spec do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
end

Rake::Task[:spec].clear
task :spec do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
end
