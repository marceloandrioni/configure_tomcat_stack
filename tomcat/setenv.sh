#!/bin/sh
#
# ENVARS for Tomcat
#
export CATALINA_HOME="/usr/local/tds/tomcat"

export CATALINA_BASE="/usr/local/tds/tomcat"

export JAVA_HOME="/usr/local/tds/jdk"

# TDS specific ENVARS
#
# Define where the TDS content directory will live
#   THIS IS CRITICAL and there is NO DEFAULT - the
#   TDS will not start without this.
#
CONTENT_ROOT=-Dtds.content.root.path=/usr/local/tds/content

# Set java prefs related variables (used by the wms service, for example)
JAVA_PREFS_ROOTS="-Djava.util.prefs.systemRoot=$CONTENT_ROOT/thredds/javaUtilPrefs \
                  -Djava.util.prefs.userRoot=$CONTENT_ROOT/thredds/javaUtilPrefs"

#
# Some commonly used JAVA_OPTS settings:
#
# NORMAL="-d64 -Xmx4096m -Xms512m -server -ea"   # Oracle JDK 11 fails with -d64
NORMAL="-Xmx4096m -Xms512m -server -ea"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"

#
# Standard setup.
#
JAVA_OPTS="$CONTENT_ROOT $NORMAL $HEAP_DUMP $HEADLESS $JAVA_PREFS_ROOTS"

export JAVA_OPTS
