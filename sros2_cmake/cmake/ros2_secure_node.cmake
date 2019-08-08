# Copyright 2016-2019 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

macro(ros2_secure_node)
  # ros2_secure_node(NODES <node_1> <node_2>...<node_n>)
  #
  # NODES (macro multi-arg) takes the node names for which artifacts will be generated
  # SECURITY (cmake arg) if not defined or OFF, will not generate keystore/keys/permissions
  # POLICY_FILE (cmake arg) if defined, policies defined in the file will used to generate permission files for all the nodes listed in the policy file
  # ROS_SECURITY_ROOT_DIRECTORY (env variable) will be the location of the keystore
  if(NOT SECURITY)
    message(STATUS "Not generating security files")
    return()
  endif()
  find_program(PROGRAM ros2)

  if(DEFINED ENV{ROS_SECURITY_ROOT_DIRECTORY})
    set(SECURITY_KEYSTORE $ENV{ROS_SECURITY_ROOT_DIRECTORY})
  else()
    set(SECURITY_KEYSTORE ${DEFAULT_KEYSTORE})
  endif()
  cmake_parse_arguments(ros2_secure_node "" "" "NODES" ${ARGN})
  set(generate_artifacts_command ${PROGRAM} security generate_artifacts -k ${SECURITY_KEYSTORE})
  list(LENGTH ros2_secure_node_NODES nb_nodes)
  if(${nb_nodes} GREATER "0")
    list(APPEND generate_artifacts_command "-n")
    foreach(node ${ros2_secure_node_NODES})
        list(APPEND generate_artifacts_command ${node})
    endforeach()
  endif()
  if(POLICY_FILE)
    if(EXISTS ${POLICY_FILE})
      set(policy ${POLICY_FILE})
      list(APPEND generate_artifacts_command -p ${policy})
    else()
      message(WARNING "policy file '${POLICY_FILE}' doesn't exist, skipping..")
    endif()
  endif()

  message(STATUS "Executing: ${generate_artifacts_command}")
  execute_process(
    COMMAND ${generate_artifacts_command}
    RESULT_VARIABLE GENERATE_ARTIFACTS_RESULT
    ERROR_VARIABLE GENERATE_ARTIFACTS_ERROR
  )
  if(NOT ${GENERATE_ARTIFACTS_RESULT} EQUAL 0)
    message(WARNING "Failed to generate security artifacts: ${GENERATE_ARTIFACTS_ERROR}")
  else()
    message(STATUS "artifacts generated successfully")
  endif()
endmacro()

