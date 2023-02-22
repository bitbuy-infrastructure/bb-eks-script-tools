# DMS
Automatically setup and execute an AWS Data Migration Service.
---
### Requirements:
```bash
brew install awscli && brew install jq
aws configure
AWS Access Key ID []: ****************XRUY
AWS Secret Access Key []: ****************3JeB
```
---
### How to execute:
```bash
cd dms
# required:
old_master_pwd=''
new_user_pwd=''
# ex.: old_master_pwd='xxxx' new_user_pwd='yyy' ./dms.sh da bitbuy_stocks
old_master_pwd='xxxx' new_user_pwd='yyy' ./dms.sh <end> <db_name> <optional_new_db_name> 
```
---
### Logs output:
```bash
tail -f log_dms.log
```
---
