# EMF Freescout Config

This repository contains the configuration for [EMF](https://emfcamp.org)'s
[Freescout](https://freescout.net) setup, which runs in Docker containers, and
makes use of Nginx as a reverse proxy, and [UFFD](https://git.cccv.de/uffd/uffd)
for authentication.

Nginx is responsible for checking a user is authenticated, and doing an OAuth
dance with UFFD if they're not. Freescout then makes use of UFFD's LDAP server
to obtain user details and assign them to the correct mailboxes, because the
OAuth support in Freescout requires manual admin of mailbox access.

There's also an IMAP & SMTP server somewhere which provides Freescout with
access to the actual emails that are being handled. That's provided by [waves
arms vaguely] something. We'll work that bit out if we get that far.

Here's a pretty picture of how all that fits together:

![Diagram](./doc/diagram.png)
