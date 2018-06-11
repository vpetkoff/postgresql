# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: server_install
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include PostgresqlCookbook::Helpers

property :version,           String, default: '9.6'
property :setup_repo,        [true, false], default: true
property :hba_file,          String, default: lazy { "#{conf_dir}/main/pg_hba.conf" }
property :ident_file,        String, default: lazy { "#{conf_dir}/main/pg_ident.conf" }
property :external_pid_file, String, default: lazy { "/var/run/postgresql/#{version}-main.pid" }
property :password,          String, default: 'generate'
property :port,              [String, Integer], default: 5432
property :initdb_locale,     String, default: 'UTF-8'

# Connection prefernces
property :user,               String, default: 'postgres'
property :database,           String
property :host,               String
property :port,               Integer, default: 5432

action :install do
  node.run_state['postgresql'] ||= {}
  node.run_state['postgresql']['version'] = new_resource.version

  postgresql_client_install 'Install PostgreSQL Client' do
    version new_resource.version
    setup_repo new_resource.setup_repo
  end

  package server_pkg_name
end

action :create do
  execute 'init_db' do
    command rhel_init_db_command
    not_if { initialized? }
    only_if { platform_family?('rhel', 'fedora', 'amazon') }
    notifies :write, 'log[Enable and start PostgreSQL service]', :immediately
  end

  find_resource(:service, 'postgresql') do
    service_name lazy { platform_service_name }
    supports restart: true, status: true, reload: true
    action :nothing
  end

  log 'Enable and start PostgreSQL service' do
    notifies :enable, 'service[postgresql]', :immediately
    notifies :start, 'service[postgresql]', :immediately
    action :nothing
  end

  # Generate a random password or set it as per new_resource.password.
  bash 'generate-postgres-password' do
    user 'postgres'
    code alter_role_sql(new_resource)
    not_if { user_has_password?(new_resource) }
    not_if { new_resource.password.nil? }
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
