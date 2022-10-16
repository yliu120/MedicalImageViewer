local base = import 'aliyun/base/client.libsonnet';
local tmpl = import 'aliyun/eci/template.libsonnet';

{
  Client: base.Client {
    AccessKeyId: 'Your-Access-Key-Id',
    AccessKeySecret: 'Your-Access-Key-Secret',
    RegionId: 'cn-zhangjiakou',
  },
  ContainerGroup: tmpl.ContainerGroup {
    NFSServer:: 'your-nfs-server.cn-zhangjiakou.nas.aliyuncs.com',
    SecurityGroupId: 'sg-your-security-group',
    VSwitchId: 'vsw-your-switch',
  },
}
