#!/bin/bash
if [ -z $3 ]; then
	new_db_name=$2
else
	new_db_name=$3
fi
# Teod
if [ $1 == "da" ]; then
	if [ $2 == "staking" ]; then
		new_username='bb_89wSnt3a'
	fi
    if [ $2 == "bitbuy_stocks" ]; then
		new_username='stocks_user'
    fi
    if [ $2 == "bitbuy_api_accounts" ]; then
		new_username='bitbuy_api_accounts_admin'
    fi
    if [ $2 == "bitbuy_api_crypto" ]; then
		new_username='bitbuy_api_crypto_admin'
    fi
    new_db_host='bbtd-np-main01-us-east-2-aurora.cluster-cvalc5s3nz9x.us-east-2.rds.amazonaws.com'
fi
# Staging
if [ $1 == "qa" ]; then
	if [ $2 == "staking" ]; then
		new_username='staking'
	fi
    if [ $2 == "bitbuy_stocks" ]; then
		new_username='stocks_user'
    fi
    if [ $2 == "bitbuy_api_accounts" ]; then
		new_username='bitbuy_api_accounts_admin'
    fi
    if [ $2 == "bitbuy_api_crypto" ]; then
		new_username='bitbuy_api_crypto_admin'
    fi
    new_db_host='bbrp-np-main01-us-east-2-aurora.cluster-cmdhkr1n0sby.us-east-2.rds.amazonaws.com'
fi
# Prod
if [ $1 == "pd" ]; then
	if [ $2 == "staking" ]; then
		new_username=''
	fi
    if [ $2 == "bitbuy_stocks" ]; then
		new_username='stocks_user'
    fi
    if [ $2 == "bitbuy_api_accounts" ]; then
		new_username='bitbuy_api_accounts_admin'
    fi
    if [ $2 == "bitbuy_api_crypto" ]; then
		new_username='bitbuy_api_crypto_admin'
    fi
    new_db_host='bbpd-pd-main01-us-east-2-aurora.cluster-cmtameqgasky.us-east-2.rds.amazonaws.com'
fi
