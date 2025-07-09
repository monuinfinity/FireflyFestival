defmodule FireflyFestival do
  def start() do
    start(50)
  end

  def start(num_fireflies) do

    firefly_pids = []
    firefly_pids = startFireflies(num_fireflies, firefly_pids, 0)
    
    sendFirefliList(firefly_pids, firefly_pids)
    
    printResult(firefly_pids)
  end

  def startFireflies(count, pids, index) do
    if count == 0 do
      pids 
    else
      pid = spawn(fn -> fireflyProcess(index) end)
      startFireflies(count - 1, [pid | pids], index + 1)
    end
  end

  def sendFirefliList(firefly_list, all_pids) do
    if length(firefly_list) == 0 do
      :ok
    else
      first_firefly = hd(firefly_list)       
      remaining = tl(firefly_list)         
      send(first_firefly, {:firefly_list, all_pids})
      sendFirefliList(remaining, all_pids)
    end
  end

  def fireflyProcess(my_index) do
    start_time = :rand.uniform(2000)    
    all_fireflies = receive do
      {:firefly_list, pids} -> pids
    end
    
    fireflyLoop(my_index, :off, start_time, all_fireflies)
  end

  def fireflyLoop(my_index, state, time, all_fireflies) do
    :timer.sleep(100)  
    new_time = time + 100
    
    case state do
      :off ->
        if new_time >= 2000 do  
          sendToallaboutBlink(my_index, all_fireflies)
          fireflyLoop(my_index, :on, 0, all_fireflies)
        else
          new_time_after_blinks = blinksCheck(new_time, my_index, length(all_fireflies))
          fireflyLoop(my_index, :off, new_time_after_blinks, all_fireflies)
        end
      
      :on ->
        if new_time >= 500 do
          fireflyLoop(my_index, :off, 0, all_fireflies)
        else
          anyMsgWhileOn(my_index, state, new_time, all_fireflies)
        end
    end
  end

  def sendToallaboutBlink(my_index, all_fireflies) do
    tellFireflies(all_fireflies, my_index)
  end

  def tellFireflies(firefly_list, my_index) do
    if length(firefly_list) == 0 do
      :ok
    else
      first_firefly = hd(firefly_list)
      remaining = tl(firefly_list)
      send(first_firefly, {:blink, my_index})
      tellFireflies(remaining, my_index)
    end
  end

  def blinksCheck(current_time, my_index, total_fireflies) do

    left_neighbor = if my_index == 0 do
      total_fireflies - 1
    else
      my_index - 1
    end
    
    receive do
      {:blink, from_index} ->
        if from_index == left_neighbor do
          min(current_time + 1000, 2000)
        else
          current_time
        end
      {:get_state, from_pid} ->
        send(from_pid, {:state, my_index, :off})
        current_time
    after
      0 -> current_time  
    end
  end

  def anyMsgWhileOn(my_index, state, time, all_fireflies) do
    
    receive do
      {:blink, _from_index} ->
    
        fireflyLoop(my_index, state, time, all_fireflies)
      {:get_state, from_pid} ->
        send(from_pid, {:state, my_index, :on})
        fireflyLoop(my_index, state, time, all_fireflies)
    after
      0 -> fireflyLoop(my_index, state, time, all_fireflies)
    end
  end

  def printResult(firefly_pids) do
    
    IO.write(IO.ANSI.clear() <> IO.ANSI.home())
    
    takeState(firefly_pids)
    
    states = combineAllStates(length(firefly_pids), [])
        
    printFireflies(states)
    :timer.sleep(33) 
    printResult(firefly_pids)
  end

  def takeState(pid_list) do
    if length(pid_list) == 0 do
      :ok
    else
      [pid | rest] = pid_list
      send(pid, {:get_state, self()})
      takeState(rest)
    end
  end

  def combineAllStates(count, states) do
    if count == 0 do
      states
    else
      receive do
        {:state, index, state} ->
          combineAllStates(count - 1, [{index, state} | states])
      after
        50 ->
          states 
      end
    end
  end


  def printFireflies(firefly_list) do
    if length(firefly_list) == 0 do
      IO.puts("")
    else
      [{_index, state} | rest] = firefly_list
      if state == :on do
        IO.write("B")
      else
        IO.write(" ")
      end
      printFireflies(rest)
    end
  end
end
