postgresql_repository 'install'

postgresql_server_install 'package' do
  password '12345'
  port 5432
  setup_repo true
  action [:install, :create]
end

postgresql_database 'test_1'

package 'postgresql-contrib'

postgresql_extension 'adminpack' do
  source_directory '/usr/share/pgsql/extension/'
  database 'test_1'
end
