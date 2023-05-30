task = {}

function add_task(task_type, ...)
    local parameters = {...}
    table.insert(task, {task_type, table.unpack(parameters)})
  end
    
  clear_tasks = function()
      for i=1, #task do
          table.remove(task, i)
      end
  end
  
  get_task = function(task_id)
      return task[task_id]
  end

  get_all_tasks = function()
    return task
end
  
  delete_task = function(task_id)
      table.remove(task, task_id)
  end
      
  remote.add_interface("actions", {
    add_task=add_task,
    clear_tasks=clear_tasks,
    get_task=get_task,
    get_all_tasks=get_all_tasks,
    delete_task=delete_task,
      })

return task
