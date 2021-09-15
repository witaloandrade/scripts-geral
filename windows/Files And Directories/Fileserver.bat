cd\
md storage
cd\storage
md financeiro
md administrativo

dsadd ou "ou=laboratorio,dc=treinamento,dc=impacta"
dsadd group "cn=gg_financas,ou=laboratorio,dc=treiamento,dc=impacta" -secgrp yes -scope g
dsadd group "cn=gg_administracao,ou=laboratorio,dc=treiamento,dc=impacta" -secgrp yes -scope g
dsadd group "cn=gg_tecnologia,ou=laboratorio,dc=treiamento,dc=impacta" -secgrp yes -scope g
dsadd group "cn=acl_FS_Financeiro_RW,ou=laboratorio,dc=treiamento,dc=impacta" -secgrp yes -scope l
dsadd group "cn=acl_FS_Administrativo_RW,ou=laboratorio,dc=treiamento,dc=impacta" -secgrp yes -scope l
dsadd group "cn=acl_FS_TI_RW,ou=laboratorio,dc=treiamento,dc=impacta" -secgrp yes -scope l

net share Financas$=c:\storage\financeiro /grant:everyone,Full
net share Administrativo$=c:\storage\administrativo /grant:everyone,Full

cacls "c:\storage\financeiro" /E /P treinamento\acl_fs_financeiro_RW:C
cacls "c:\storage\administrativo" /E /P treinamento\acl_fs_administrativo_RW:C