#!/usr/bin/env bash

export GPU_MAX_HEAP_SIZE=100
export GPU_MAX_USE_SYNC_OBJECTS=1
export GPU_SINGLE_ALLOC_PERCENT=100
export GPU_MAX_ALLOC_PERCENT=100
export GPU_MAX_SINGLE_ALLOC_PERCENT=100
export GPU_ENABLE_LARGE_ALLOCATION=100
export GPU_MAX_WORKGROUP_SIZE=1024

[[ `ps aux | grep "srbminer_custom_bin" | grep -v grep | wc -l` != 0 ]] &&
  echo -e "${RED}$CUSTOM_NAME miner is already running${NOCOLOR}" &&
  exit 1

. h-manifest.conf

unset LD_LIBRARY_PATH

conf=`cat $MINER_CONFIG_FILENAME`

if [[ $conf=~';' ]]; then
    conf=`echo $conf | tr -d '\'`
fi

eval "unbuffer ./srbminer_custom_bin ${conf//;/'\;'} --api-enable --api-port $MINER_API_PORT --log-file $CUSTOM_LOG_BASENAME.log"