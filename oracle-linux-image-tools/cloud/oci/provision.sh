#!/usr/bin/env bash
#
# Packer provisioning script for OCI
#
# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at
# https://oss.oracle.com/licenses/upl
#
# Description: OVM specific provisioning. This module provides 2 functions,
# both are optional.
#   cloud::provision: provision the instance
#   cloud::cleanup: instance cleanup before shutdown
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

#######################################
# Configure OCI instance
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
cloud::config()
{
  echo_message "Setup network"
  # simple eth0 configuration
  cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<-EOF
	DEVICE="eth0"
	BOOTPROTO="dhcp"
	ONBOOT="yes"
	TYPE="Ethernet"
	USERCTL="yes"
	PEERDNS="yes"
	IPV6INIT="no"
	PERSISTENT_DHCLIENT="1"
	EOF
}

#######################################
# Install QEMU guest agent
# Globals:
#   YUM_VERBOSE
# Arguments:
#   None
# Returns:
#   None
#######################################
cloud::install_agent()
{
  echo_message "Install guest agent"
  yum install -y "${YUM_VERBOSE}" qemu-guest-agent
}

#######################################
# Install cloud-init, use CLOUD_USER if specified
# Globals:
#   YUM_VERBOSE
# Arguments:
#   None
# Returns:
#   None
#######################################
cloud::cloud_init()
{
  echo_message "Install cloud-init: ${CLOUD_INIT^^}"
  if [[ "${CLOUD_INIT,,}" = "yes" ]]; then
    yum install -y "${YUM_VERBOSE}" cloud-init
    if [[ -n "${CLOUD_USER}" ]]; then
      sed -i -e "s/\(^\s\+name:\).*/\1 ${CLOUD_USER}/" /etc/cloud/cloud.cfg
    fi
  fi
}

#######################################
# Provisioning module
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
cloud::provision()
{
  cloud::install_agent
  cloud::cloud_init
  cloud::config
}

#######################################
# Cleanup module
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
cloud::cleanup()
{
  :
}
