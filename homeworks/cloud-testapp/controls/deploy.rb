# encoding: utf-8
# copyright: 2018, The Authors

title 'cloud-testapp: deploy'

control 'Check README.md' do

  describe parse_config_file('README.md') do
    its('testapp_IP') { should match /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/ }
  end
  describe parse_config_file('README.md') do
    its('testapp_PORT') { should match /^(?:[0-9]{1,5}\.)$/ }
  end

end

testapphost = parse_config_file('README.md').testapp_IP
testappport = parse_config_file('README.md').testapp_PORT

control 'Configuration' do
  title 'Check testapp installation scenarios'

  %w(ruby-full ruby-bundler build-essential mongodb-org).each do |pkg|
      describe package(pkg) do
        it { should be_installed }
    end
  end

  describe service('mongod') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(27017) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
    its('processes') { should include 'mongod' }
  end

  describe port(testapphost) do
    it { should be_listening }
    its('protocols') { should include 'tcp' }
    its('processes') { should include 'puma' }
  end

end

control 'Reddit-APP' do
  title 'Check testapp web-application'

  describe host(testapphost, port: testappport, protocol: 'tcp') do
    it { should be_reachable }
  end

  describe command("curl http://#{testapphost}:#{testappport}}/signup -F 'username=travis' -F  'password=travis'") do
    its('exit_status') { should eq 0 }
  end

  describe command("curl http://#{testapphost}:#{testappport}/new -F 'title=travis-test' -F  'link=https://travis-ci.org/'") do
    its('exit_status') { should eq 0 }
  end

  describe http('http://#{testapphost}:#{testappport}}/') do
      its('status') { should eq 200 }
      its('body') { should cmp 'https://travis-ci.org' }
  end
end





