{
  Container:: {
    ports:: null,
    local make_port(ports) = std.map(function(port) {
      Port: port,
      Protocol: 'TCP',
    }, ports),

    local default_liveness_probe = {
      TcpSocket: {
        Port: 22,
      },
      HttpGet: {
        Scheme: 'https',
      },
      Exec: {
        Command: ['ls'],
      },
    },
    local default_readiness_probe = default_liveness_probe,
    local default_security_context = {
      Capability: {
        Add: ['NET_ADMIN'],
      },
    },
    // Default to the smallest allocation
    Image: error 'Must override "Image"',
    Name: error 'Must override "Name"',
    Port: make_port(self.ports),
    LivenessProbe: default_liveness_probe,
    ReadinessProbe: default_readiness_probe,
    SecurityContext: default_security_context,
  },

  Volume:: {
    Name: error 'Must override "Name"',
    Type: error 'Must override "Type"',
    NFSVolume: {},
    ConfigFileVolume: {},
    DiskVolume: {},
    EmptyDirVolume: {},
    FlexVolume: {},
    HostPathVolume: {},
  },

  ContainerGroup: {
    NFSServer:: error 'Must override "NFSServer"',
    SecurityGroupId: error 'Must override "SecurityGroupId"',
    VSwitchId: error 'Must override "VSwitchId"',
    // Not charged by bandwidth. Default to 200 MB.
    EipBandwidth: if self.AutoCreateEip then 200,

    local group = self,
    local OrthancDbVolumeName = 'orthanc-db',
    local OrthancConfigVolumeName = 'orthanc-config',
    local OhifViewerConfigVolumeName = 'ohif-viewer-config',
    local NginxConfigVolumeName = 'nginx-for-orthanc-config',

    AutoCreateEip: false,
    ContainerGroupName: 'medical-image-viewer',
    Container: [
      $.Container {
        ports:: [8042],
        Image: 'registry.cn-zhangjiakou.aliyuncs.com/socks/orthanc-plugins:latest',
        Name: 'orthanc',
        VolumeMount: [
          {
            MountPath: '/var/lib/orthanc/db/',
            Name: OrthancDbVolumeName,
            ReadOnly: false,
          },
          {
            MountPath: '/etc/orthanc/',
            Name: OrthancConfigVolumeName,
            ReadOnly: true,
          },
        ],
      },
      $.Container {
        ports:: [80],
        Image: 'registry.cn-zhangjiakou.aliyuncs.com/socks/ohif-viewer:latest',
        Name: 'ohif-viewer',
        VolumeMount: [
          {
            MountPath: '/usr/share/nginx/html/config/',
            Name: OhifViewerConfigVolumeName,
            ReadOnly: true,
          },
        ],
      },
      $.Container {
        ports:: [8041],
        Image: 'registry.cn-zhangjiakou.aliyuncs.com/eci_open/nginx:alpine',
        Name: 'nginx-for-orthanc',
        VolumeMount: [
          {
            MountPath: '/etc/nginx/',
            Name: NginxConfigVolumeName,
            ReadOnly: true,
          },
        ],
      },
    ],
    // Default to the smallest allocation.
    // Containers inside the pod will make full use of the specified resources.
    Cpu: 0.25,
    Memory: 0.5,

    local make_config_file_to_path(config_file) = {
      Path: config_file,
      Content: 'config/' + config_file,
    },
    Volume: [
      $.Volume {
        Name: OrthancDbVolumeName,
        Type: 'NFSVolume',
        NFSVolume: {
          Path: '/',
          ReadOnly: false,
          Server: group.NFSServer,
        },
      },
      $.Volume {
        Name: OrthancConfigVolumeName,
        Type: 'ConfigFileVolume',
        ConfigFileVolume: {
          ConfigFileToPath: [
            make_config_file_to_path('orthanc.json'),
          ],
        },
      },
      $.Volume {
        Name: OhifViewerConfigVolumeName,
        Type: 'ConfigFileVolume',
        ConfigFileVolume: {
          ConfigFileToPath: [
            make_config_file_to_path('app-config.js'),
          ],
        },
      },
      $.Volume {
        Name: NginxConfigVolumeName,
        Type: 'ConfigFileVolume',
        ConfigFileVolume: {
          ConfigFileToPath: [
            make_config_file_to_path('nginx.conf'),
          ],
        },
      },
    ],
  },
}
