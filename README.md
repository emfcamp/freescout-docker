# EMF Freescout Config

This repository contains the configuration for [EMF](https://emfcamp.org)'s
[Freescout](https://freescout.net) setup, which runs in Docker containers, and
makes use of Nginx as a reverse proxy, and [UFFD](https://git.cccv.de/uffd/uffd)
for authentication.

We use [Vouch](https://github.com/vouch/vouch-proxy/) in conjunction with Nginx's
`auth_request` support to force user's to perform authentication against an OIDC
provider (in our case [UFFD](https://git.cccv.de/uffd/uffd)) before they can
access Freescout. Nginx will pass the logged in user's username in the `X_AUTH_USER`
FastCGI variable to Freescout if the user is authenticated.

Freescout regularly queries the UFFD LDAP directory and creates user accounts
for anyone with access, setting access to appropriate mailboxes based on group
memberships.

There's also an IMAP & SMTP server somewhere which provides Freescout with
access to the actual emails that are being handled. That's provided by [waves
arms vaguely] something. We'll work that bit out if we get that far.

Here's a pretty picture of how all that fits together:

![Diagram](./doc/diagram.png)

## Deployment

1. Create a service and OAuth client for Freescout in UFFD. The redirect URI is
  `http://example.org/vouch/auth` and logout URI is `GET http://example.org/vouch/logout`.
2. Update the values in `.env` (or set environment variables via some other method)
   to match your actual setup.
3. `docker compose up` to start the neccessary services.
4. You should now be able to access the Freescout instance. After OAuth you'll
   be presented with a log in screen. Use the default username and password from
   `.env` to log in.
5. Follow the steps in Freescout Setup below.

## Development

`docker compose -f docker-compose.yml -f docker-compose.dev.yml up` will bring
up a stack consisting of the Freescout setup, plus UFFD configured with some
test users. `testadmin / adminpassword` will log you in as an administrator,
`testuser / userpassword` as a standard user.

## Freescout Setup

This all assumes you're running with the default settings from `.env`. Change them
if you're not.

1. Log in as admin@example.org with the password `password`.
2. Activate the LDAP module.
3. Go to LDAP settings
   1. LDAP Host: `uffd-ldap`
   2. Port: `389`
   3. Bind DN: `ou=system,dc=example,dc=org`
   4. Bind Username: `service`
   5. Bind Password: `password`
   6. Click "Connect & Fetch Attributes"
   7. Map `mail` to Email, `cn` to First Name, and `sn` to everything else (this is a nasty
      hack taking advantage of UFFD not setting a surname field to allow optional fields to
      be ignored).
   8. DNs and Filters: `dc=example,dc=or(objectclass=person)` to import all users
   9. Toggle Automatic Import on
   10. Toggle Automatic Permission Sync on
   11. Toggle LDAP Authentication on
   12. Set $_SERVER key to `X_AUTH_USER`
   13. Set Locate users by to `mail`
4. Go to Manage -> Users, and grant your own user the Administrator role.

If you delete all your cookies and log back in you should now be dropped straight
in as your authenticated user.

## Configuring Mailbox Access

Mailbox access can either be manually configured by an admin (not a good idea)
or automatically synchronised via LDAP. To configure via LDAP you need to feed
Freescout a query to find all the relevant users, which will typically look
something like `(&(memberOf=cn=group-name,ou=groups,dc=example,dc=org))`.

Any LDAP query that returns a list of users will work.

## Snags

* Nginx is configured to redirect Freescout's logout page to Vouch, so that your
  OAuth token is revoked. This works in most cases, but if you then log in again
  as a different user the cookie left behind by Freescout will still think your
  the user you initially logged in as. Delete all your cookies if you need to
  change users.
