FROM sentry:8.11-onbuild

RUN apt-get update && apt-get install -y python-dev libldap2-dev libsasl2-dev libssl-dev
RUN pip install django-auth-ldap

