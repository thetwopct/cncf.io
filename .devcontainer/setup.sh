#! /bin/bash

SLUG=CNCF
PROJECT_TYPE=theme

if [[ ! -z "$CODESPACE_NAME" ]]
then
	SITE_HOST="https://${CODESPACE_NAME}-8080.preview.app.github.dev"
else
	SITE_HOST="http://localhost:8080"
fi

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>setup.log 2>&1

source ~/.bashrc

# Install dependencies
cd /var/www/html/web/wp-content/themes/cncf-twenty-two/
npm i && npm run build

# Install WordPress and activate the plugin/theme.
cd /var/www/html/
echo "Setting up WordPress at $SITE_HOST"
wp db reset --yes

wp core install --url="$SITE_HOST" --title="CNCF.io Development" --admin_user="admin" --admin_email="admin@example.com" --admin_password="password" --skip-email

composer --version

wp site empty --yes 
wp option update date_format "j F Y"
wp option update default_comment_status "closed"
wp option update thread_comments 0
wp option update show_avatars 0
wp option update comment_moderation 1
wp option update permalink_structure "/%postname%/" 

echo "Activate $SLUG"
wp theme activate cncf-twenty-two

wp option get siteurl
