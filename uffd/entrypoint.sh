#!/usr/bin/env bash
set -x

uffd-admin db upgrade

# Populate with sample data
UFFD_GROUPS=$(uffd-admin group list)
if [[ "${UFFD_GROUPS}" == "" ]]; then
  uffd-admin group create 'uffd_access' --description 'Access to SSO'
  uffd-admin group create 'uffd_admin' --description 'Access to administer UFFD'
  uffd-admin role create 'base' --default --add-group 'uffd_access'
  uffd-admin role create 'admin' --default --add-group 'uffd_admin'
  uffd-admin user create 'testuser' --password 'userpassword' --mail 'test@example.org' --displayname 'Test User'
  uffd-admin user create 'testadmin' --password 'adminpassword' --mail 'admin@example.org' --displayname 'Test Admin' --add-role 'admin'
fi

exec uffd-admin run --host=0.0.0.0
