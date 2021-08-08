#!/bin/bash

error () {
    echo -e "\nERROR: $1"
    exit 1
}

check_naming () {
    echo -n "Checking target naming..."

    for target_config in configs/default/*.config; do
        BOARD_NAME=$(sed -n 's/^ *board_name \([^#]\+\).*$/\1/p' ${target_config} | sed -e 's/[[:space:]]*$//')
        MANUFACTURER_ID=$(sed -n 's/^ *manufacturer_id \+\([^#]\{1,4\}\).*$/\1/p' ${target_config} | sed -e 's/[[:space:]]*$//')
        FILE_NAME=$(basename ${target_config})

        if [ $(printf %s "${BOARD_NAME}" | grep -c .) -gt 1 ]; then
            error "More than one board_name found in Unified Target configuration ${target_config}."
            exit 1
        fi

        if [ $(printf %s "${MANUFACTURER_ID}" | grep -c .) -gt 1 ]; then
            error "More than one manufacturer_id found in Unified Target configuration ${target_config}."
            exit 1
        fi

        if [ $(echo "${BOARD_NAME}" | grep -c '[^[:upper:][:digit:]_]') -ne 0 ]; then
            error "Invalid characters found in board_name (${BOARD_NAME}, allowed 'A'-'Z', '0'-'9', '_') in Unified Target configuration ${target_config}."
            exit 1
        fi

        if [ $(echo "${MANUFACTURER_ID}" | grep -c '[^[:upper:][:digit:]_]') -ne 0 ]; then
            error "Invalid characters found in manufacturer_id (${MANUFACTURER_ID}, allowed 'A'-'Z', '0'-'9', '_') in Unified Target configuration ${target_config}."
            exit 1
        fi

        if [ "${FILE_NAME}" != "${MANUFACTURER_ID}-${BOARD_NAME}.config" ]; then
            error "File name does not match board name (${BOARD_NAME}) / manufacturer id (${MANUFACTURER_ID}) in Unified Target configuration ${target_config}."
            exit 1
        fi
    done

    echo "done."
}

check_encoding () {
    echo -n "Checking file encoding..."

    for target_config in configs/default/*; do
        if $(grep -U $'\x0D' -q ${target_config}); then
            error "File ${target_config} has got invalid (DOS) line endings."
            exit 1
        fi
    done

    echo "done."
}

check_naming
check_encoding
