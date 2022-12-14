local base = import 'aliyun/base/client.libsonnet';
local tmpl = import 'aliyun/eci/template.libsonnet';

{
  Client: base.Client {
    AccessKeyId: 'your-secret',
    AccessKeySecret: 'your-secret',
    RegionId: 'your-region',
  },
  ContainerGroup: tmpl.ContainerGroup {
    NFSServer:: 'your-server',
    // Your security group needs to allow port 8042
    SecurityGroupId: 'your-security-group',
    VSwitchId: 'your-switch-id',
  },
}
