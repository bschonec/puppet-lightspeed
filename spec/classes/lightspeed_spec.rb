# frozen_string_literal: true

require 'spec_helper'

describe 'lightspeed' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          backend_endpoint: 'https://api.example.com',
        }
      end
      let(:config_file) { '/etc/xdg/command-line-assistant/config.toml' }

      it { is_expected.to compile }

      it 'installs the command_line_assistant package' do
        is_expected.to contain_package('command-line-assistant').with(
          'ensure' => 'installed'
        )
      end

      it 'creates the config file with the backend endpoint' do
        is_expected.to contain_file(config_file).
          with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0600'
          ).
          # Check that 'endpoint' parameter is contained within (technically, anywhere AFTER) the [backend] section.
          with_content(%r{^\[backend\](?:.*\n)*endpoint = "https://api\.example\.com"$}m).
          with_content(%r{^verify_ssl = true$}).
          with_content(%r{^level = "INFO"$}).
          that_requires('Package[command-line-assistant]')
      end

      it 'ensures the clad service is running and enabled' do
        is_expected.to contain_service('clad').with(
          'ensure' => 'running',
          'enable' => true
        ).
          that_requires("File[#{config_file}]")
      end
    end
  end
end
