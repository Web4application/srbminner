#!/usr/bin/env bash
# This file will contain functions related to gathering stats and displaying it for agent
# Agent will have to call mmp-stats.sh which will contain triggers for configuration files and etc.
# Do not add anything static in this file
GPU_COUNT=$1
LOG_FILE=$2
cd `dirname $0`
. mmp-external.conf

json_data=$(curl --connect-timeout 2 --max-time 5 --silent --noproxy '*' http://127.0.0.1:4444/)
if [[ $? -ne 0 || -z $json_data ]]; then
    echo -e "Miner API connection failed"
else

    units="hs"
    declare -A hashrate_data
    declare -A accepted_shares_data
    declare -A rejected_shares_data
    declare -A invalid_shares_data
    declare -A busid_data

    num_algorithms=$(echo "$json_data" | jq -r '.algorithms | length')

    for ((algo_idx = 0; algo_idx < num_algorithms; algo_idx++)); do
        hashrate_values=()
        accepted_shares=()
        rejected_shares=()
        invalid_shares=()
        busid_values=()

        cpu_hashrate=$(echo "$json_data" | jq -r ".algorithms[$algo_idx].hashrate.cpu.total // 0")
        gpu_total=$(echo "$json_data" | jq -r ".algorithms[$algo_idx].hashrate.gpu.total // 0")
        total_gpu_devices=$(echo "$json_data" | jq -r '.gpu_devices | length')
        total_acc=$(echo "$json_data" | jq -c -r ".algorithms[$algo_idx].shares.accepted")
        total_rej=$(echo "$json_data" | jq -c -r ".algorithms[$algo_idx].shares.rejected")

        if (( $(echo "$cpu_hashrate > 0" | bc -l) )); then
            hashrate_values+=("$cpu_hashrate")
            busid_values+=("\"cpu\"")
        fi

        if (( $(echo "$gpu_total > 0" | bc -l) )); then
            for ((i = 0; i < total_gpu_devices; i++)); do
                hashrate=$(echo "$json_data" | jq -c -r ".algorithms[$algo_idx].hashrate.gpu.gpu${i} // 0")
                hashrate_values+=("$hashrate")

                accepted=$(echo "$json_data" | jq -c -r ".algorithms[$algo_idx].gpu_accepted_shares.gpu${i} // 0")
                rejected=$(echo "$json_data" | jq -c -r ".algorithms[$algo_idx].gpu_rejected_shares.gpu${i} // 0")
                invalid=$(echo "$json_data" | jq -c -r ".algorithms[$algo_idx].gpu_compute_errors.gpu${i} // 0")

                accepted_shares+=("$accepted")
                rejected_shares+=("$rejected")
                invalid_shares+=("$invalid")

                busid=$(echo "$json_data" | jq -r ".gpu_devices[$i].bus_id")
                busid_values+=("$busid")
            done
        fi

        hash=$(printf '%s\n' "${hashrate_values[@]}" | jq -cs '.')
        acc=$(printf '%s\n' "${accepted_shares[@]}" | jq -cs '.')
        rej=$(printf '%s\n' "${rejected_shares[@]}" | jq -cs '.')
        inval=$(printf '%s\n' "${invalid_shares[@]}" | jq -cs '.')
        busid=$(printf '%s\n' "${busid_values[@]}" | jq -cs '.')

        hashrate_data["hash$algo_idx"]="$hash"
        accepted_shares_data["shares$algo_idx"]="{\"accepted\": $acc, \"rejected\": $rej, \"invalid\": $inval}"
        busid_data["busid$algo_idx"]="$busid"
        total_shares_array+=("[$total_acc, $total_rej]")
    done

    stats=$(jq -n \
            --arg units "$units" \
            --arg miner_name "$EXTERNAL_NAME" \
            --arg miner_version "$EXTERNAL_VERSION" \
            --argjson busid "${busid_data[busid0]}" \
            --argjson hash "${hashrate_data[hash0]}" \
            --argjson shares "${accepted_shares_data[shares0]}" \
            --argjson ar "${total_shares_array[0]}" \
            '{
      units: $units,
      busid: $busid,
      hash: $hash,
      shares: $shares,
      ar: $ar,
      miner_name: $miner_name,
      miner_version: $miner_version
    }')

    # If we have more than 1 algorithm idx, we append it here:
    if (( num_algorithms > 1 )); then
        stats=$(echo "$stats" | jq \
                --argjson hash2 "${hashrate_data[hash1]}" \
                --argjson shares2 "${accepted_shares_data[shares1]}" \
                --argjson ar2 "${total_shares_array[1]}" \
                '. + {
            hash2: $hash2,
            shares2: $shares2,
            ar2: $ar2
        }')
    fi

    echo "$stats"
fi
