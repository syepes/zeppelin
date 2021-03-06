#!/bin/bash
#
# Copyright 2007 The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FWDIR="$(cd $(dirname "$0"); pwd)"

if [[ -z "${ZEPPELIN_HOME}" ]]; then
  # Make ZEPPELIN_HOME look cleaner in logs by getting rid of the
  # extra ../
  export ZEPPELIN_HOME="$(cd "${FWDIR}/.."; pwd)"
fi

if [[ -z "${ZEPPELIN_CONF_DIR}" ]]; then
  export ZEPPELIN_CONF_DIR="${ZEPPELIN_HOME}/conf"
fi

if [[ -z "${ZEPPELIN_LOG_DIR}" ]]; then
  export ZEPPELIN_LOG_DIR="${ZEPPELIN_HOME}/logs"
fi

if [[ -z "${ZEPPELIN_NOTEBOOK_DIR}" ]]; then
  export ZEPPELIN_NOTEBOOK_DIR="${ZEPPELIN_HOME}/notebook"
fi

if [[ -z "$ZEPPELIN_PID_DIR" ]]; then
  export ZEPPELIN_PID_DIR="${ZEPPELIN_HOME}/run"
fi

if [[ -z "${ZEPPELIN_WAR}" ]]; then
  if [[ -d "${ZEPPELIN_HOME}/zeppelin-web/src/main/webapp" ]]; then
    export ZEPPELIN_WAR="${ZEPPELIN_HOME}/zeppelin-web/src/main/webapp"
  else
    export ZEPPELIN_WAR=$(find -L "${ZEPPELIN_HOME}" -name "zeppelin-web*.war")
  fi
fi

if [[ -z "${ZEPPELIN_API_WAR}" ]]; then
  if [[ -d "${ZEPPELIN_HOME}/zeppelin-docs/src/main/swagger" ]]; then
    export ZEPPELIN_API_WAR="${ZEPPELIN_HOME}/zeppelin-docs/src/main/swagger"
  else
    export ZEPPELIN_API_WAR=$(find -L "${ZEPPELIN_HOME}" -name "zeppelin-api-ui*.war")
  fi
fi

if [[ -z "$ZEPPELIN_INTERPRETER_DIR" ]]; then
  export ZEPPELIN_INTERPRETER_DIR="${ZEPPELIN_HOME}/interpreter"
fi

ls ${ZEPPELIN_HOME}/interpreter/spark/spark-core_2.10* | grep 'spark[-]core_2[.]10[-]1[.]2' > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]; then
   export SPARK_1_2_WORKAROUND
fi

if [[ -f "${ZEPPELIN_CONF_DIR}/zeppelin-env.sh" ]]; then
  . "${ZEPPELIN_CONF_DIR}/zeppelin-env.sh"
fi

ZEPPELIN_CLASSPATH+=":${ZEPPELIN_CONF_DIR}"

function addJarInDir(){
  if [[ -d "${1}" ]]; then
    for jar in $(find -L "${1}" -maxdepth 1 -name '*jar'); do
      ZEPPELIN_CLASSPATH="$jar:$ZEPPELIN_CLASSPATH"
    done
  fi
}

addJarInDir "${ZEPPELIN_HOME}"
addJarInDir "${ZEPPELIN_HOME}/lib"
addJarInDir "${ZEPPELIN_HOME}/zeppelin-zengine/target/lib"
addJarInDir "${ZEPPELIN_HOME}/zeppelin-server/target/lib"
addJarInDir "${ZEPPELIN_HOME}/zeppelin-web/target/lib"
if [[ -z "${SPARK_1_2_WORKAROUND}" ]]; then
  addJarInDir "${ZEPPELIN_HOME}/interpreter/spark"
  addJarInDir "${ZEPPELIN_HOME}/interpreter/sh"
  addJarInDir "${ZEPPELIN_HOME}/interpreter/md"
fi

if [[ -d "${ZEPPELIN_HOME}/zeppelin-zengine/target/classes" ]]; then
  ZEPPELIN_CLASSPATH+=":${ZEPPELIN_HOME}/zeppelin-zengine/target/classes"
fi

if [[ -d "${ZEPPELIN_HOME}/zeppelin-server/target/classes" ]]; then
  ZEPPELIN_CLASSPATH+=":${ZEPPELIN_HOME}/zeppelin-server/target/classes"
fi

if [[ ! -z "${SPARK_HOME}" ]] && [[ -d "${SPARK_HOME}" ]]; then
  addJarInDir "${SPARK_HOME}"
fi

if [[ ! -z "${HADOOP_HOME}" ]] && [[ -d "${HADOOP_HOME}" ]]; then
  addJarInDir "${HADOOP_HOME}"
fi

if [[ ! -z "${HADOOP_CONF_DIR}" ]] && [[ -d "${HADOOP_CONF_DIR}" ]]; then
  ZEPPELIN_CLASSPATH+=":${HADOOP_CONF_DIR}"
fi

export ZEPPELIN_CLASSPATH
export SPARK_CLASSPATH+=":${ZEPPELIN_CLASSPATH}"
export CLASSPATH+=":${ZEPPELIN_CLASSPATH}"

# Text encoding for 
# read/write job into files,
# receiving/displaying query/result.
if [[ -z "${ZEPPELIN_ENCODING}" ]]; then
  export ZEPPELIN_ENCODING="UTF-8"
fi

if [[ -z "$ZEPPELIN_MEM" ]]; then
  export ZEPPELIN_MEM="-Xmx1024m -XX:MaxPermSize=512m"
fi

JAVA_OPTS+="${ZEPPELIN_JAVA_OPTS} -Dfile.encoding=${ZEPPELIN_ENCODING} ${ZEPPELIN_MEM}"
export JAVA_OPTS

if [[ -n "${JAVA_HOME}" ]]; then
  ZEPPELIN_RUNNER="${JAVA_HOME}/bin/java"
else
  ZEPPELIN_RUNNER=java
fi

export ZEPPELIN_RUNNER

if [[ -z "$ZEPPELIN_IDENT_STRING" ]]; then
  export ZEPPELIN_IDENT_STRING="${USER}"
fi

if [[ -z "$DEBUG" ]]; then
  export DEBUG=0
fi
