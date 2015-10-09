shared_examples 'postgresql::server' do
  describe package('postgresql94-server-9.4.5-1PGDG.rhel6.x86_64') do
    it { should be_installed }
  end

  describe service('postgresql-9.4') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(5432) do
    it { should be_listening }
  end
end
