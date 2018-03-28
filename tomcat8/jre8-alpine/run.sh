#!/bin/sh
# shellcheck disable=SC2013,SC2046
# Thanks to Virginia Tech and College of William and Mary for some of the setup in this file

PROPFILE="/usr/local/tomcat/conf/catalina.properties"
if [ ! -f "$PROPFILE" ]; then
  echo "Unable to find properties file $PROPFILE"
  exit 1
fi

setProperty() {
  prop=$1
  val=$2

  if [ "$prop" = "cas.url" ]; then
    for settings_file in /usr/local/tomcat/webapps/*/WEB-INF/web.xml; do
      xml ed  --inplace -N x="http://java.sun.com/xml/ns/javaee" -u "/x:web-app/x:filter[x:filter-name[normalize-space(text())='CAS Validation Filter']]/x:init-param[x:param-name[normalize-space(text())='serverName']]/x:param-value" -v "$val" "$settings_file"
    done
  fi

  if [ "$prop" = "banner9.baseurl" ]; then
    for settings_file in /usr/local/tomcat/webapps/*/WEB-INF/web.xml; do
      xml ed  --inplace -N x="http://java.sun.com/xml/ns/javaee" -u "/x:web-app/x:filter[x:filter-name[normalize-space(text())='CAS Validation Filter']]/x:init-param[x:param-name[normalize-space(text())='casServerUrlPrefix']]/x:param-value" -v "$val" "$settings_file"
    done
  fi

  if [ $(grep -c "$prop" "$PROPFILE") -eq 0 ]; then
    echo "${prop}=$val" >> "$PROPFILE"
  else
    val=$(echo "$val" |sed 's#/#\\/#g')
    sed -i "s/$prop=.*/$prop=$val/" "$PROPFILE"
  fi
}

setPropsFromFile() {
  file=$1
  for l in $(grep '=' "$file" | grep -v '^ *#'); do
    prop=$(echo "$l" |cut -d= -f1)
    val=$(echo "$l" |cut -d= -f2)
    setProperty "$prop" "$val"
  done
}

if [ -f "$CONFIG_FILE" ]; then
    setPropsFromFile "$CONFIG_FILE"
fi

# Pull properties from docker secrets
if [ -d /run/secrets ]; then
  for file in /run/secrets/*; do
    prop=$(basename "$file")
    val=$(cat "$file")
    setProperty "$prop" "$val"
  done
fi

setPropFromEnv() {
  prop=$1
  val=$2
  # If no value was given, abort
  [ -z "$val" ] && return
  if [ $(grep -c $prop $PROPFILE) -eq 0 ]; then
    setProperty $prop $val
  fi
}

if [ -z $CONFIG_FILE ]; then
  setPropFromEnv bannerdb.jdbc "$BANNERDB_JDBC"
  setPropFromEnv banproxy.username "$BANPROXY_USERNAME"
  setPropFromEnv banproxy.password "$BANPROXY_PASSWORD"
  setPropFromEnv banproxy.initialsize "$BANPROXY_INITALSIZE"
  setPropFromEnv banproxy.maxtotal "$BANPROXY_MAXTOTAL"
  setPropFromEnv banproxy.maxidle "$BANPROXY_MAXIDLE"
  setPropFromEnv banproxy.maxwait "$BANPROXY_MAXWAIT"
  setPropFromEnv banssuser.username "$BANSSUSER_USERNAME"
  setPropFromEnv banssuser.password "$BANSSUSER_PASSWORD"
  setPropFromEnv banssuser.initialsize "$BANSSUSER_INITALSIZE"
  setPropFromEnv banssuser.maxtotal "$BANSSUSER_MAXTOTAL"
  setPropFromEnv banssuser.maxidle "$BANSSUSER_MAXIDLE"
  setPropFromEnv banssuser.maxwait "$BANSSUSER_MAXWAIT"
  setPropFromEnv cas.url "$CAS_URL"
  setPropFromEnv banner9.baseurl "$BANNER9_URL"
fi
exec catalina.sh run
