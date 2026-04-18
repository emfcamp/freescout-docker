#!/usr/bin/python3

import os
os.environ['FLASK_RUN_FROM_CLI'] = 'true'
os.environ['LANG'] = 'en_GB.utf8'
os.environ['CONFIG_PATH'] = '/etc/uffd/uffd.cfg'

import sys
sys.path.append('/usr/share/uffd')

from typing import Any

import click
from flask import Flask
from flask.cli import ScriptInfo, AppGroup
import uffd


class CustomAppGroup(AppGroup):

    def make_context(
        self,
        info_name: str | None,
        args: list[str],
        parent: click.Context | None = None,
        **extra: Any,
    ) -> click.Context:
        if "obj" not in extra and "obj" not in self.context_settings:
            extra["obj"] = ScriptInfo(
                create_app=uffd.create_app,
                set_debug_flag=True,
                load_dotenv_defaults=True,
            )
        return super().make_context(info_name, args, parent=parent, **extra)


@click.group(cls=CustomAppGroup)
def cli():
    """Management script"""

@cli.command("create-service")
@click.argument("name")
@click.argument("access-group-name")
def create_service(name, access_group_name):
    from uffd.models import RemailerMode, Service, Group
    from uffd.database import db

    access_group = Group.query.filter_by(name=access_group_name).one_or_none()
    if not access_group:
        print(f"Couldn't find group {access_group_name}", file=sys.stderr)
        return

    new_service = Service(
        name=name,
        limit_access=True,
        access_group=access_group,
        remailer_mode=RemailerMode.DISABLED,
    )
    db.session.add(new_service)
    db.session.commit()

@cli.command("create-oauth2-client")
@click.argument("service-name")
@click.argument("client-id")
@click.argument("client-secret")
@click.argument("redirect-uri")
def create_oauth2_client(service_name, client_id, client_secret, redirect_uri):
    from uffd.models import Service, OAuth2Client
    from uffd.database import db

    service = Service.query.filter_by(name=service_name).one_or_none()
    if not service:
        print(f"Couldn't find service {service_name}", file=sys.stderr)
        return

    client = OAuth2Client(
        service=service,
        client_id=client_id,
        client_secret=client_secret,
    )
    db.session.add(client)

    client.redirect_uris = [redirect_uri]
    db.session.commit()

@cli.command("create-api-client")
@click.argument("service-name")
@click.argument("api-user")
@click.argument("api-secret")
@click.argument("permissions", nargs=-1)
def create_api_client(service_name, api_user, api_secret, permissions):
    from uffd.models import Service, APIClient
    from uffd.database import db

    service = Service.query.filter_by(name=service_name).one_or_none()
    if not service:
        print(f"Couldn't find service {service_name}", file=sys.stderr)
        return

    client = APIClient(
        service=service,
        auth_username=api_user,
        auth_password=api_secret,
    )
    failed = False
    for perm in permissions:
        if APIClient.permission_exists(perm):
            setattr(client, f'perm_{perm}', True)
        else:
            print(f"No such permission {perm}", file=sys.stderr)
            failed = True
    if failed:
        return
    db.session.add(client)
    db.session.commit()


if __name__ == '__main__':
    cli()
