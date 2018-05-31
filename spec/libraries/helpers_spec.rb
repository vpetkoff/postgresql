require 'spec_helper'
require_relative '../../libraries/helpers.rb'

RSpec.describe PostgresqlCookbook::Helpers do
  class DummyClass < Chef::Node
    include PostgresqlCookbook::Helpers
  end
  subject { DummyClass.new }

  describe '#data_dir(version)' do
    before do
      allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
    end

    let(:pg_version) { '9.6' }

    context 'with rhel family and Postgres 9.6' do
      let(:platform_family) { 'rhel' }

      it 'returns the correct path' do
        expect(subject.data_dir(pg_version)).to eq '/var/lib/pgsql/9.6/data'
      end
    end

    context 'with debian family and Postgres 9.6' do
      let(:platform_family) { 'debian' }

      it 'returns the correct path' do
        expect(subject.data_dir(pg_version)).to eq '/var/lib/postgresql/9.6/main'
      end
    end
  end

  describe '#conf_dir(version)' do
    before do
      allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
    end

    let(:pg_version) { '9.6' }

    context 'with rhel family and Postgres 9.6' do
      let(:platform_family) { 'rhel' }

      it 'returns the correct path' do
        expect(subject.conf_dir(pg_version)).to eq '/var/lib/pgsql/9.6/data'
      end
    end

    context 'with debian family and Postgres 9.6' do
      let(:platform_family) { 'debian' }

      it 'returns the correct path' do
        expect(subject.conf_dir(pg_version)).to eq '/etc/postgresql/9.6/main'
      end
    end
  end

  describe '#platform_service_name(version)' do
    before do
      allow(subject).to receive(:[]).with('platform_family').and_return(platform_family)
    end

    let(:pg_version) { '9.6' }

    context 'with rhel family and Postgres 9.6' do
      let(:platform_family) { 'rhel' }

      it 'returns the correct service name' do
        expect(subject.platform_service_name(pg_version)).to eq 'postgresql-9.6'
      end
    end

    context 'with debian family and Postgres 9.6' do
      let(:platform_family) { 'debian' }

      it 'returns the correct service name' do
        expect(subject.platform_service_name(pg_version)).to eq 'postgresql'
      end
    end
  end

  describe '#psql_command_string' do
    # before do
    #
    # end

    it 'returns a full command string' do
      new_resource = double(database: 'db_foo',
                             user: 'postgres',
                             host: 'localhost',
                             port: '5432'
                            )
      query = 'THIS IS A COMMAND STRING'
      grep_for = 'FOO'
      # database = 'db_foo'

      result = 'psql -tc THIS IS A COMMAND STRING -d db_foo -U postgres --host localhost --port 5432 | grep FOO'

      expect(subject.psql_command_string(new_resource, query, grep_for, 'db_foo')).to eq(result)
    end
  end

  # describe '#database_exists(new_resource)' do
  #   before do
  #
  #   end
  # end
end
