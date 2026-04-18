#!/usr/bin/env bash
set -x

uffd-admin db upgrade

# Populate with sample data
UFFD_GROUPS=$(uffd-admin group list)
if [[ "${UFFD_GROUPS}" == "" ]]; then
  uffd-admin group create 'uffd_access' --description 'Access to SSO'
  uffd-admin group create 'uffd_admin' --description 'Access to administer UFFD'
  uffd-admin group create 'freescout_access' --description 'Access to FreeScout'
  uffd-admin group create 'freescout_admin' --description 'Admin access to FreeScout'
  uffd-admin group create 'freescout_mailbox_misc' --description 'Access to "MISC" Mailbox'
  uffd-admin group create 'freescout_mailbox_admin' --description 'Access to "ADMIN" Mailbox'
  uffd-admin group create 'freescout_mailbox_honk' --description 'Access to "HONK" Mailbox'
  uffd-admin role create 'base' --default --add-group 'uffd_access'
  uffd-admin role create 'freescout-misc' --add-group 'freescout_access' --add-group 'freescout_mailbox_misc'
  uffd-admin role create 'freescout-admin' --add-group 'freescout_access' --add-group 'freescout_admin' --add-group 'freescout_mailbox_admin'
  uffd-admin role create 'freescout-honk' --add-group 'freescout_access' --add-group 'freescout_mailbox_honk'
  uffd-admin role create 'admin' --add-group 'uffd_admin' --add-role 'freescout-admin'
  uffd-admin user create 'testuser' --password 'userpassword' --mail 'test@example.org' --displayname 'Test User' --add-role 'freescout-misc'
  uffd-admin user create 'testadmin' --password 'adminpassword' --mail 'admin@example.org' --displayname 'Test Admin' --add-role 'admin' --add-role 'freescout-honk'

  /usr/local/bin/provision.py create-service freescout freescout_access
  /usr/local/bin/provision.py create-oauth2-client freescout $CLIENT_ID $CLIENT_SECRET http://localhost:8137/oauthproxy/callback
  /usr/local/bin/provision.py create-api-client freescout $UFFD_LDAP_USER $UFFD_LDAP_USER users checkpassword
fi

exec uffd-admin run --host=0.0.0.0
