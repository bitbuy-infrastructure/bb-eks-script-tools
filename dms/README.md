# DMS
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
old_master_pwd=''
new_user_pwd=''
./dms.sh <end> <db_name> <optional_new_db_name> 
```
---
### Logs output:
```bash
tail -f log_dms.log
```
---
