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
    KernelImage:: 'registry.cn-zhangjiakou.aliyuncs.com/gromacs-2022/notebook:latest',
    SecurityGroupId: error 'Must override "SecurityGroupId"',
    VSwitchId: error 'Must override "VSwitchId"',
    InstanceType: 'ecs.gn6i-c4g1.xlarge',
    SpotStrategy: 'SpotAsPriceGo',
    ActiveDeadlineSeconds: 3600 * 3,

    Cpu: 4,
    Memory: 15,
    GpuAllowedInNotebook:: 1,
    // Not charged by bandwidth. Default to 200 MB.
    AutoCreateEip: false,
    EipBandwidth: if self.AutoCreateEip then 200,

    ContainerGroupName: 'molecular-dynamics-notebook',

    local group = self,
    local NotebookVolumeName = 'notebook',
    Container: [
      $.Container {
        ports:: [8888],
        Image: group.KernelImage,
        Name: 'molecular-dynamics-notebook',
        //VolumeMount: [
	//  {
	//    MountPath: '/root',
	//    Name: NotebookVolumeName,
	//    ReadOnly: false,
	//  },
	//],
	Gpu: group.GpuAllowedInNotebook,
      },
    ],
    // Default to the smallest allocation.
    // Containers inside the pod will make full use of the specified resources.
    //Volume: [
    //  $.Volume {
    //    Name: NotebookVolumeName,
    //    Type: 'NFSVolume',
    //    NFSVolume: {
    //      Path: '/',
    //      ReadOnly: false,
    //      Server: group.NFSServer,
    //    },
    //  },
    //],
  },
}
