"CN"：Common Name，etcd 从证书中提取该字段作为请求的用户名 (User Name)；浏览器使用该字段验证网站是否合法；
"O"：Organization，etcd 从证书中提取该字段作为请求用户所属的组 (Group)；
这两个参数在后面的kubernetes启用RBAC模式中很重要，因为需要设置kubelet、admin等角色权限，那么在配置证书的时候就必须配置对了，具体后面在部署kubernetes的时候会进行讲解。
"在etcd这两个参数没太大的重要意义，跟着配置就好。"

生成etcd.pem etcd-key.pem，三个节点共用此证书。

附：数字证书中主题(Subject)中字段的含义
一般的数字证书产品的主题通常含有如下字段：
公用名称 (Common Name) 简称：CN 字段，对于 SSL 证书，一般为网站域名；而对于代码签名证书则为申请单位名称；而对于客户端证书则为证书申请者的姓名；
组织名称,公司名称(Organization Name) 简称：O 字段，对于 SSL 证书，一般为网站域名；而对于代码签名证书则为申请单位名称；而对于客户端单位证书则为证书申请者所在单位名称；
组织单位名称，公司部门(Organization Unit Name) 简称：OU字段

证书申请单位所在地
所在城市 (Locality) 简称：L 字段
所在省份 (State/Provice) 简称：S 字段，State：州，省
所在国家 (Country) 简称：C 字段，只能是国家字母缩写，如中国：CN


