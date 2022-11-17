local base = import 'aliyun/base/client.libsonnet';
local tmpl = import 'aliyun/eci/md_notebook/template.libsonnet';

{
  Client: base.Client {
    AccessKeyId: 'your-secret',
    AccessKeySecret: 'your-secret',
    RegionId: 'your-region',
  },
  ContainerGroup: tmpl.ContainerGroup {
    NFSServer:: 'your-server',
    // Your security group needs to allow port 8888
    SecurityGroupId: 'your-security-group',
    VSwitchId: 'your-switch-id',

    // Select an instance type
    InstanceType: 'ecs.gn6i-c4g1.xlarge',
  },
}
