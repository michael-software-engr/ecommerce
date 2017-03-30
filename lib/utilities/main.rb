# ... edited by app gen (utilities)

require_relative 'thor'

def relative_dir(path = nil, ext: '.rb')
  dir = File.basename(caller.first.split(':').first, ext)
            .sub(/\A [[:digit:]]{2} _/x, '')

  return dir if !path
  return File.join dir, path
end

def task_title(current_task, include_comment: true)
  tname = current_task.name
  return tname if !include_comment

  comment = current_task.comment
  return [tname, ' - ', comment.first.downcase, comment[1..-1]].join
end

def help(current_task, text_list: [], tasks_to_run: nil)
  ThorUtil.info task_title current_task, include_comment: false

  text_list.each do |text|
    ThorUtil.say_status nil, [text.first.upcase, text[1..-1]].join
  end

  return if !tasks_to_run

  ThorUtil.say_status nil, 'Will run the following tasks ...'

  tasks_to_run.each do |task_name|
    ThorUtil.say_status nil, task_name.inspect
  end
  ThorUtil.say_status nil, ''
end
