#!/usr/bin/env bash

HOST="192.168.0.176"
MQTT_PORT=1883
ARARA_POWER_OUTLET_FRIENDLY_NAME="immax_neo_power_plug"
TOPIC="zigbee2mqtt/${ARARA_POWER_OUTLET_FRIENDLY_NAME}/set"
LOWER_LIMIT=20
UPPER_LIMIT=80

# TODO 2021 April 26 16:43 Kristoffer-PBS
# filter the output from 'acpi' in a more efficient way
get_battery_level () {
    acpi | \
    tail --lines 1 | \
    grep --only-matching --extended-regexp '[0-9]{1,3}%' | \
    grep --only-matching '[0-9]*'
}

BATTERY_PERCENTAGE=$(get_battery_level)
POWER_PLUG_STATE=""

echo "battery level is:    $BATTERY_PERCENTAGE"

if [[ ${BATTERY_PERCENTAGE} -le ${LOWER_LIMIT} ]]; then
    POWER_PLUG_STATE="ON"

elif [[ ${BATTERY_PERCENTAGE} -ge ${UPPER_LIMIT} ]]; then
    POWER_PLUG_STATE="OFF"
fi

if [[ -n "${POWER_PLUG_STATE}" ]]; then
    MSG="{\"state\": \"${POWER_PLUG_STATE}\" }"
    mosquitto_pub --host ${HOST} --port ${MQTT_PORT} --topic ${TOPIC} --message "${MSG}"
fi
