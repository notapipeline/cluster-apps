# If vault isn't initialised, exit cleanly to allow the pods to start
# for the initialisation process
if [ "$(vault status | awk '/Initialized/{print $NF}')" != 'true' ]; then
    exit 0
fi

while true; do # Until told otherwise, enter an infinite loop
  for i in 1 2 3; do # For each node in the cluster
    while true; do # until we get a response from bwv

      # get a key for the current node
      # setting v to empty string if the connection cannot be established (bwv is not running)
      v=$(wget --no-check-certificate -q -O - --header "Authorization: Bearer $BW_TOKEN" $BW_ADDR/$BW_PATH?field=unseal-$i 2>&1 | grep -v refused);
      if [ "$v" != "" ]; then
        break;
      fi;

      # if we didn't get a response, sleep for a second and try again
      sleep 1;
    done;

    # Try and unseal the vault using the current key
    vault operator unseal $(echo $v | awk -F\" "/value/{print \$4}");
  done;

  # If Vault is unsealed, break the outer loop
  if [ $(vault status | grep Sealed | awk "{print \$NF}") = false ]; then
    break;
  fi;

  # If not, sleep for a second and try again
  sleep 1;
done
