#!/usr/bin/env bash

HOST="localhost"
MQTT_PORT=1883
ARARA_POWER_OUTLET_FRIENDLY_NAME="power_outlet"
TOPIC="zigbee2mqtt/${ARARA_POWER_OUTLET_FRIENDLY_NAME}/set"
LOWER_LIMIT=20
UPPER_LIMIT=80

get_battery_level () {
    acpi | \
    tail -n 1 | \
    grep --only-matching --extended-regexp '[0-9]{1,2}%' | \
    grep --only-matching '[0-9]*'
}


while true; do
    echo "we are running!"
    BATTERY_PERCENTAGE=$(get_battery_level)
    POWER_OUTLET_STATE=""

    echo "battery percentage is ${BATTERY_PERCENTAGE}"

    if [[ ${BATTERY_PERCENTAGE} -le ${LOWER_LIMIT} ]]; then
        POWER_OUTLET_STATE="true"

    elif [[ ${BATTERY_PERCENTAGE} -ge ${UPPER_LIMIT} ]]; then
        POWER_OUTLET_STATE="false"
    fi

    if [[ -n "${POWER_OUTLET_STATE}" ]]; then
        MSG='{"state": "${POWER_OUTLET_STATE}" }'
        echo "$MSG"
        # mosquitto_pub --host ${HOST} --port ${MQTT_PORT} --topic ${TOPIC} --message "${MSG}"
    else
        echo "there is nothing to do!"
    fi
    
    sleep 300 # 60 * 5 = 5 min

done


