require 'spec_helper'
require 'chef'
require 'excon'

describe 'docker_container' do
  step_into :docker_container
  platform 'ubuntu'

  # Info returned by docker api
  # https://docs.docker.com/engine/api/v1.39/#tag/Container
  let(:container) do
    {
      'Id' => '123456789',
      'IPAddress' => '10.0.0.1',
      'Image' => 'ubuntu:bionic',
      'Names' => ['/hello_world'],
      'Config' => { 'Labels' => {} },
      'HostConfig' => { 'RestartPolicy' => { 'Name' => 'unless-stopped',
                                             'MaximumRetryCount' => 1 },
                        'Binds' => [],
                        'ReadonlyRootfs' => false },
      'State' => 'not running',
      'Warnings' => [],
    }.to_json
  end

  # https://docs.docker.com/engine/api/v1.39/#tag/Image
  let(:image) do
    { 'Id' => 'bf119e2',
      'Repository' => 'ubuntu', 'Tag' => 'bionic',
      'Created' => 1_364_102_658, 'Size' => 24_653,
      'VirtualSize' => 180_116_135,
      'Config' => { 'Labels' => {} } }.to_json
  end
  # https://docs.docker.com/engine/api/v1.39/#operation/SystemInfo
  let(:info) do
    { 'Labels' => {} }.to_json
  end
  # https://docs.docker.com/engine/api/v1.39/#operation/ContainerCreate
  let(:create) do
    {
      'Id' => 'e90e34656806',
      'Warnings' => [],
    }.to_json
  end

  before do
    # Ensure docker api calls are mocked
    # It is low level much easier to do in Excon
    # Plus, the low level mock allows testing this cookbook
    # for multiple docker apis and docker-api gems
    # https://github.com/excon/excon#stubs
    Excon.defaults[:mock] = true
    Excon.stub({ method: :get, path: '/containers/hello_world/json' }, body: container, status: 200)
    Excon.stub({ method: :get, path: '/images/ubuntu:bionic/json' }, body: image, status: 200)
    Excon.stub({ method: :get, path: '/info' }, body: info, status: 200)
    Excon.stub({ method: :delete, path: '/containers/123456789' }, body: '', status: 200)
    Excon.stub({ method: :post, path: '/containers/create' }, body: create, status: 200)
    Excon.stub({ method: :get, path: '/containers/123456789/start' }, body: '', status: 200)
  end

  context 'creates a docker container with default options' do
    recipe do
      docker_container 'hello_world' do
        tag 'ubuntu:latest'
        action :create
      end
    end

    it {
      expect { chef_run }.to_not raise_error
      expect(chef_run).to create_docker_container('hello_world').with(
        tag: 'ubuntu:latest',
        create_options: {
          'name' => 'hello_world',
          'Image' => 'hello_world:ubuntu:latest',
          'Labels' => {},
          'Cmd' => nil,
          'AttachStderr' => false,
          'AttachStdin' => false,
          'AttachStdout' => false,
          'Domainname' => '',
          'Entrypoint' => nil,
          'Env' => [],
          'ExposedPorts' => {},
          'Healthcheck' => nil,
          'Hostname' => nil,
          'MacAddress' => nil,
          'NetworkDisabled' => false,
          'OpenStdin' => false,
          'StdinOnce' => false,
          'Tty' => false,
          'User' => nil,
          'Volumes' => {},
          'WorkingDir' => nil,
          'HostConfig' => {
            'Binds' => nil,
            'CapAdd' => nil,
            'CapDrop' => nil,
            'CgroupParent' => '',
            'CgroupnsMode' => 'private',
            'CpuShares' => 0,
            'CpusetCpus' => '',
            'Devices' => [],
            'Dns' => [],
            'DnsSearch' => [],
            'ExtraHosts' => nil,
            'IpcMode' => 'shareable',
            'Init' => nil,
            'KernelMemory' => 0,
            'Links' => nil,
            'LogConfig' => nil,
            'Memory' => 0,
            'MemorySwap' => nil,
            'MemoryReservation' => 0,
            'NanoCpus' => 0,
            'NetworkMode' => 'bridge',
            'OomKillDisable' => false,
            'OomScoreAdj' => -500,
            'Privileged' => false,
            'PidMode' => '',
            'PortBindings' => {},
            'PublishAllPorts' => false,
            'RestartPolicy' => { 'Name' => nil, 'MaximumRetryCount' => 0 },
            'ReadonlyRootfs' => false,
            'Runtime' => 'runc',
            'SecurityOpt' => nil,
            'ShmSize' => 67_108_864,
            'Sysctls' => {},
            'Tmpfs' => {},
            'Ulimits' => nil,
            'UsernsMode' => '',
            'UTSMode' => '',
            'VolumesFrom' => nil,
            'VolumeDriver' => nil,
          },
          'NetworkingConfig' => {
            'EndpointsConfig' => {
              'bridge' => {
                'IPAMConfig' => { 'IPv4Address' => nil },
                'Aliases' => [],
              },
            },
          },
        }
      )
    }
  end

  context 'creates a docker container with healthcheck options' do
    recipe do
      docker_container 'hello_world' do
        tag 'ubuntu:latest'
        health_check(
          'Test' =>
            [
              'string',
            ],
          'Interval' => 0,
          'Timeout' => 0,
          'Retries' => 0,
          'StartPeriod' => 0
        )
        action :create
      end
    end

    it {
      expect { chef_run }.to_not raise_error
      expect(chef_run).to create_docker_container('hello_world').with(
        tag: 'ubuntu:latest',
        create_options: {
          'name' => 'hello_world',
          'Image' => 'hello_world:ubuntu:latest',
          'Labels' => {},
          'Cmd' => nil,
          'AttachStderr' => false,
          'AttachStdin' => false,
          'AttachStdout' => false,
          'Domainname' => '',
          'Entrypoint' => nil,
          'Env' => [],
          'ExposedPorts' => {},
          'Hostname' => nil,
          'MacAddress' => nil,
          'NetworkDisabled' => false,
          'OpenStdin' => false,
          'StdinOnce' => false,
          'Tty' => false,
          'User' => nil,
          'Volumes' => {},
          'WorkingDir' => nil,
          'HostConfig' => {
            'Binds' => nil,
            'CapAdd' => nil,
            'CapDrop' => nil,
            'CgroupParent' => '',
            'CgroupnsMode' => 'private',
            'CpuShares' => 0,
            'CpusetCpus' => '',
            'Devices' => [],
            'Dns' => [],
            'DnsSearch' => [],
            'ExtraHosts' => nil,
            'IpcMode' => 'shareable',
            'Init' => nil,
            'KernelMemory' => 0,
            'Links' => nil,
            'LogConfig' => nil,
            'Memory' => 0,
            'MemorySwap' => nil,
            'MemoryReservation' => 0,
            'NanoCpus' => 0,
            'NetworkMode' => 'bridge',
            'OomKillDisable' => false,
            'OomScoreAdj' => -500,
            'Privileged' => false,
            'PidMode' => '',
            'PortBindings' => {},
            'PublishAllPorts' => false,
            'RestartPolicy' => { 'Name' => nil, 'MaximumRetryCount' => 0 },
            'ReadonlyRootfs' => false,
            'Runtime' => 'runc',
            'SecurityOpt' => nil,
            'ShmSize' => 67_108_864,
            'Sysctls' => {},
            'Tmpfs' => {},
            'Ulimits' => nil,
            'UsernsMode' => '',
            'UTSMode' => '',
            'VolumesFrom' => nil,
            'VolumeDriver' => nil,
          },
          'NetworkingConfig' => {
            'EndpointsConfig' => {
              'bridge' => {
                'IPAMConfig' => { 'IPv4Address' => nil },
                'Aliases' => [],
              },
            },
          },
          'Healthcheck' => {
            'Test' => ['string'],
            'Interval' => 0,
            'Timeout' => 0,
            'Retries' => 0,
            'StartPeriod' => 0,
          },
        }
      )
    }
  end

  context 'creates a docker container with default options for windows' do
    platform 'windows'
    recipe do
      docker_container 'hello_world' do
        tag 'ubuntu:latest'
        action :create
      end
    end

    it {
      expect { chef_run }.to_not raise_error
      expect(chef_run).to create_docker_container('hello_world').with(
        tag: 'ubuntu:latest',
        # Should be missing 'MemorySwappiness'
        create_options: {
          'name' => 'hello_world',
          'Image' => 'hello_world:ubuntu:latest',
          'Labels' => {},
          'Cmd' => nil,
          'AttachStderr' => false,
          'AttachStdin' => false,
          'AttachStdout' => false,
          'Domainname' => '',
          'Entrypoint' => nil,
          'Env' => [],
          'ExposedPorts' => {},
          'Healthcheck' => nil,
          'Hostname' => nil,
          'MacAddress' => nil,
          'NetworkDisabled' => false,
          'OpenStdin' => false,
          'StdinOnce' => false,
          'Tty' => false,
          'User' => nil,
          'Volumes' => {},
          'WorkingDir' => nil,
          'HostConfig' => {
            'Binds' => nil,
            'CapAdd' => nil,
            'CapDrop' => nil,
            'CgroupParent' => '',
            'CgroupnsMode' => 'host',
            'CpuShares' => 0,
            'CpusetCpus' => '',
            'Devices' => [],
            'Dns' => [],
            'DnsSearch' => [],
            'ExtraHosts' => nil,
            'IpcMode' => 'shareable',
            'Init' => nil,
            'KernelMemory' => 0,
            'Links' => nil,
            'LogConfig' => nil,
            'Memory' => 0,
            'MemorySwap' => nil,
            'MemoryReservation' => 0,
            'NanoCpus' => 0,
            'NetworkMode' => 'bridge',
            'OomKillDisable' => false,
            'OomScoreAdj' => -500,
            'Privileged' => false,
            'PidMode' => '',
            'PortBindings' => {},
            'PublishAllPorts' => false,
            'RestartPolicy' => { 'Name' => nil, 'MaximumRetryCount' => 0 },
            'ReadonlyRootfs' => false,
            'Runtime' => 'runc',
            'SecurityOpt' => nil,
            'ShmSize' => 67_108_864,
            'Sysctls' => {},
            'Tmpfs' => {},
            'Ulimits' => nil,
            'UsernsMode' => '',
            'UTSMode' => '',
            'VolumesFrom' => nil,
            'VolumeDriver' => nil,
          },
          'NetworkingConfig' => {
            'EndpointsConfig' => {
              'bridge' => {
                'IPAMConfig' => { 'IPv4Address' => nil },
                'Aliases' => [],
              },
            },
          },
        }
      )
    }
  end

  context 'creates docker container with cgroupns option' do
    recipe do
      docker_container 'hello_world' do
        tag 'ubuntu:latest'
        cgroup_ns 'host'
        action :create
      end
    end

    it {
      expect { chef_run }.to_not raise_error
      expect(chef_run).to create_docker_container('hello_world').with(
        tag: 'ubuntu:latest',
        create_options: {
          'name' => 'hello_world',
          'Image' => 'hello_world:ubuntu:latest',
          'Labels' => {},
          'Cmd' => nil,
          'AttachStderr' => false,
          'AttachStdin' => false,
          'AttachStdout' => false,
          'Domainname' => '',
          'Entrypoint' => nil,
          'Env' => [],
          'ExposedPorts' => {},
          'Healthcheck' => nil,
          'Hostname' => nil,
          'MacAddress' => nil,
          'NetworkDisabled' => false,
          'OpenStdin' => false,
          'StdinOnce' => false,
          'Tty' => false,
          'User' => nil,
          'Volumes' => {},
          'WorkingDir' => nil,
          'HostConfig' => {
            'Binds' => nil,
            'CapAdd' => nil,
            'CapDrop' => nil,
            'CgroupnsMode' => 'host',
            'CgroupParent' => '',
            'CpuShares' => 0,
            'CpusetCpus' => '',
            'Devices' => [],
            'Dns' => [],
            'DnsSearch' => [],
            'ExtraHosts' => nil,
            'IpcMode' => 'shareable',
            'Init' => nil,
            'KernelMemory' => 0,
            'Links' => nil,
            'LogConfig' => nil,
            'Memory' => 0,
            'MemorySwap' => nil,
            'MemoryReservation' => 0,
            'NanoCpus' => 0,
            'NetworkMode' => 'bridge',
            'OomKillDisable' => false,
            'OomScoreAdj' => -500,
            'Privileged' => false,
            'PidMode' => '',
            'PortBindings' => {},
            'PublishAllPorts' => false,
            'RestartPolicy' => { 'Name' => nil, 'MaximumRetryCount' => 0 },
            'ReadonlyRootfs' => false,
            'Runtime' => 'runc',
            'SecurityOpt' => nil,
            'ShmSize' => 67_108_864,
            'Sysctls' => {},
            'Tmpfs' => {},
            'Ulimits' => nil,
            'UsernsMode' => '',
            'UTSMode' => '',
            'VolumesFrom' => nil,
            'VolumeDriver' => nil,
          },
          'NetworkingConfig' => {
            'EndpointsConfig' => {
              'bridge' => {
                'IPAMConfig' => { 'IPv4Address' => nil },
                'Aliases' => [],
              },
            },
          },
        }
      )
    }
  end

  context 'creates a docker container with GPU support' do
    before do
      # Stub image
      allow_any_instance_of(Docker::Image).to receive(:tag)
      allow_any_instance_of(Docker::Image).to receive(:remove)
      allow(Docker::Image).to receive(:get).and_return(true)
      allow(Docker::Image).to receive(:exist?).and_return(true)
      allow_any_instance_of(Docker::Container).to receive(:start)
      allow_any_instance_of(Docker::Container).to receive(:wait)
      allow_any_instance_of(Docker::Container).to receive(:remove)

      # Stub Docker API calls
      Excon.stub(
        { path: '/containers/gpu_test/json' },
        { status: 404 }
      )

      Excon.stub(
        { method: :post, path: '/containers/create' },
        { status: 201, body: '{ "Id": "123" }' }
      )
    end

    after do
      Excon.stubs.clear
    end

    recipe do
      docker_container 'gpu_test' do
        tag 'ubuntu:latest'
        gpus 'all'
        gpu_driver 'nvidia'
        action :create
      end
    end

    it 'configures nvidia GPU support' do
      expect(chef_run).to create_docker_container('gpu_test').with(
        tag: 'ubuntu:latest',
        create_options: {
          'name' => 'gpu_test',
          'Image' => 'gpu_test:ubuntu:latest',
          'Labels' => {},
          'Cmd' => nil,
          'AttachStderr' => false,
          'AttachStdin' => false,
          'AttachStdout' => false,
          'Domainname' => '',
          'Entrypoint' => nil,
          'Env' => [],
          'ExposedPorts' => {},
          'Healthcheck' => nil,
          'Hostname' => nil,
          'MacAddress' => nil,
          'NetworkDisabled' => false,
          'OpenStdin' => false,
          'StdinOnce' => false,
          'Tty' => false,
          'User' => nil,
          'Volumes' => {},
          'WorkingDir' => nil,
          'HostConfig' => {
            'Binds' => nil,
            'CapAdd' => nil,
            'CapDrop' => nil,
            'CgroupParent' => '',
            'CgroupnsMode' => 'private',
            'CpuShares' => 0,
            'CpusetCpus' => '',
            'Devices' => [],
            'Dns' => [],
            'DnsSearch' => [],
            'ExtraHosts' => nil,
            'IpcMode' => 'shareable',
            'Init' => nil,
            'KernelMemory' => 0,
            'Links' => nil,
            'LogConfig' => nil,
            'Memory' => 0,
            'MemorySwap' => nil,
            'MemoryReservation' => 0,
            'NanoCpus' => 0,
            'NetworkMode' => 'bridge',
            'OomKillDisable' => false,
            'OomScoreAdj' => -500,
            'Privileged' => false,
            'PidMode' => '',
            'PortBindings' => {},
            'PublishAllPorts' => false,
            'RestartPolicy' => { 'Name' => nil, 'MaximumRetryCount' => 0 },
            'ReadonlyRootfs' => false,
            'Runtime' => 'runc',
            'SecurityOpt' => nil,
            'ShmSize' => 67_108_864,
            'Sysctls' => {},
            'Tmpfs' => {},
            'Ulimits' => nil,
            'UsernsMode' => '',
            'UTSMode' => '',
            'VolumesFrom' => nil,
            'VolumeDriver' => nil,
            'DeviceRequests' => [{
              'Driver' => 'nvidia',
              'Count' => -1,
              'Capabilities' => [['gpu']],
            }],
          },
          'NetworkingConfig' => {
            'EndpointsConfig' => {
              'bridge' => {
                'IPAMConfig' => { 'IPv4Address' => nil },
                'Aliases' => [],
              },
            },
          },
        }
      )
    end
  end
end
