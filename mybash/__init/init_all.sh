



  function bash_functions() {

    print -l ${(ok)functions} | grep -v '^_'
    echo "List of User bash functions"

  }




  function find_pid() {

     local name="$1"
     ps -ww -p $(pgrep -f "$name")

  }


  function find_pid_only() {

     local name="$1"
     local aa 
     aa=$(ps -ww -p $(pgrep -f "$name"))
     echo "$aa" | awk 'NR==2 {print $1}' 

  }



  function kill_process_every_5m() {

    local pid1

    # while true; do
        pid1=$(find_pid_only "WpsCloudSvr")
        kill -9 $pid1  2>/dev/null
        sleep 300
    #done

   }





  function psfaux() {
     # brew install pstree
     #  ps -axwwo   user,pid,ppid,pgid,rss,%mem,%cpu,command    
     pstree -p $$

  }





  function psfaux1() {
      #### macos only 
      current_pid=$$
      echo "current_pid: $current_pid"

      # Function to get all child processes of a given PID
      get_child_pids() {
          local parent_pid=$1
          echo "" >  "/tmp/ztmp_pid.txt"
          get_subprocess0  $parent_pid >>  "/tmp/ztmp_pid.txt"
          cmd_list=$(cat  "/tmp/ztmp_pid.txt" )
          echo "$cmd_list"        
          # echo "${cmd_list%?}"
          # ps -o pid,ppid | awk -v ppid=$parent_pid '$2 == ppid { print $1 }'
      }

      # Get all child processes of the current shell
      child_pids=$(get_child_pids $current_pid)
      echo "sub-process:  $child_pids "

      # Display memory and CPU usage for each child process
      while read -r pid; do
          if [[ $pid == "" ]]; then continue; fi
          ps -p $pid  -o pid,rss,%mem,%cpu,command
      done <<< "$child_pids"
  }



  function psfauxpy() {

      child_pids=$(ps aux | grep "python" | awk '{print $2}')
      echo "$pids"


      # Get all child processes of the current shell
      # child_pids=$(get_child_pids $current_pid)
      echo "sub-process:  $child_pids "

      # Display memory and CPU usage for each child process
      while read -r pid; do
          if [[ $pid == "" ]]; then continue; fi
          ps -p $pid  -o pid,rss,%mem,%cpu,command
      done <<< "$child_pids"

  }


  function psfaux_log() {

      ##  psfaux_log  check1 &
      local freq="$2"         && [ -z $2 ] &&  local freq="15"

      ymdhms=$(TZ='Asia/Tokyo' date +'%Y%m%d_%H%M%S')
      ymd=$(TZ='Asia/Tokyo' date +'%Y%m%d')
      local mylog="ztmp/log/psfaux/${ymd}/log_psfaux_ram_${ymdhms}.py"
      mkdir -p  $(dirname "$mylog")

      # Run the myfun function every 60 seconds for 600 seconds
      echo -e "$1 \n\n"  &>> $mylog 
      end_time=$((SECONDS + 600))
      while [ $SECONDS -lt $end_time ]; do
          echo $(TZ='Asia/Tokyo' date +'%Y%m%d_%H%M%S') &>> $mylog
          # psfaux1          &>> $mylog
          psfauxpy          &>> $mylog        
          echo -e "\n\n\n"   &>> $mylog

          sleep $freq
      done

  }





    ##### Function to get all child processes of a given PID
    function get_subprocess0() {
        # curr_pid="$(get_current_shell_pid)"
        # get_subprocess $curr_pid
        # local pid="$1"   && [ -z $1 ] &&  local_pid="$(get_current_shell_pid)" 
        # echo "current_shell_pid: $local_pid"
        #    pidlist=$(get_subprocesses $$)
        local pid="$1"
        local result=""
        for spid in $(pgrep -P "$pid"); do
            # local cmd=$(ps -p "$spid" -o comm=)   ## short cmd
            local cmd=$(ps -p "$spid" -o pid)    ### long cmd  
            result+="$spid\n"
            result+=$(get_subprocess0 "$spid")
        done
        echo "$result"
    }


    function process_find(){
        # Find the processes with the command "sleep"
        #.  pid_find sleep
        pids=$(pgrep -f "$1")

        # Loop through the PIDs
        for pid in $pids; do
            # Get the PPID of the process
            ppid=$(ps -o ppid= -p $pid)
            cmd=$(ps -o command= -p $pid)         # Get the command information of the process

            echo "### PID: $pid, $cmd"
            echo ""

            ccmd=$(ps -o command= -p $ppid)
            echo "ParentID: $ppid, $ccmd"
            echo ""

            start_time=$(ps -o lstart= -p $pid)
            start_time=${start_time//[^a-zA-Z0-9: ]/}
            start_timestamp=$(date -j -f "%a %b %d %T %Y" "$start_time" +%s)
            current_timestamp=$(date +%s)
            duration=$((current_timestamp - start_timestamp))
            echo "Duration: $duration seconds"

        done
    }
    alias pid_find=process_find



  function rm_old_files() {
        # delete_old_files mlruns  30  dryrun 
        # Assign the arguments to local variables
        local dir0="$1"         && [ -z $1 ] &&  echo "delete_old_files mlruns  30  dryrun  " && return ""
        local n_days="$2"       && [ -z $2 ] &&  local n_days="12000" 
        local dryrun="$3"       && [ -z $3 ] &&  local dryrun="dryrun"

        
        # Check if the dryrun flag is set
        if [ "$dryrun" = "dryrun" ]; then
             # Use echo and find -print to print the list of files to be deleted without executing them
             echo "Dryrun: following files would be deleted:"
             find "$dir0" -type f -mtime +"$n_days" -print
        else
             # Use find and rm to delete files older than n_days in the directory
            find "$dir0" -type f -mtime +"$n_days" -exec rm -f {} +
        fi

  }



