notification :off

directories %w(manifests templates spec/classes spec/defines)

guard 'rake', :task => 'test' do
  watch(%r{^manifests\/(.+)\.pp$})
  watch(%r{^templates\/(.+)\.erb$})
  watch(%r{^spec/.*_spec.rb})
end

guard 'rake', :task => 'metadata' do
  watch('metadata.json')
end
