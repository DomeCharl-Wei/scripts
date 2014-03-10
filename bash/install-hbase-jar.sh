#!/bin/bash
ROOT=`dirname $0`
JAR_NAME="hbase"
JAR_VERSION="0.94.16-SNAPSHOT"
JAR="$ROOT/target/$JAR_NAME-$JAR_VERSION.jar"
JAR_SOURCE="$ROOT/target/$JAR_NAME-$JAR_VERSION-sources.jar"
POM="$ROOT/pom.xml"
GROUPID="org.apache.hbase"

MVN=`which mvn`
if [ -z "$MVN" ]
then
    echo "Cannot find mvn, install mvn first"
    exit 1
fi

if [ ! -f $JAR ]
then
    echo "Cannot find $JAR"
    exit 1
fi

if [ ! -f $JAR_SOURCE ]
then
    echo "Cannot find $JAR_SOURCE"
    exit 1
fi

if [ ! -f "$POM" ]
then
    echo "Cannot find $POM"
    exit 1
fi

mvn install:install-file    \
    -Dfile=$JAR             \
    -Dsources=$JAR_SOURCE   \
    -DgroupId=$GROUPID      \
    -DartifactId=$JAR_NAME  \
    -Dversion=$JAR_VERSION  \
    -DpomFile=$POM          \
    -Dpackaging=jar
