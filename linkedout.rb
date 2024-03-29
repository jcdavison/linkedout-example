require 'sinatra'
require 'sinatra/partial'
require 'better_errors'

require_relative 'config/dotenv'
require_relative 'models'

set :partial_template_engine, :erb

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

helpers do
  def default_user
    @default_user ||= User.last
  end
end

get "/" do
  @jobs = default_user.jobs
  @skills = default_user.skills

  erb :'resumes/show'
end

get "/users/edit" do
  erb :'users/edit'
end

put "/users/edit" do
  user_attrs = params[:user]

  default_user.update(user_attrs)

  redirect "/"
end

post "/jobs" do
  job_attrs = params[:job]
  job_attrs.merge!({ :user => default_user })

  job = Job.new(job_attrs)
  job.save

  if request.xhr?
    html =  "<li>"
    html += partial :'partials/job', :locals => { :job => job }
    html += partial :'partials/job_edit', :locals => { :job => job, :hidden => true }
    html += "</li>"
    html
  else
    redirect "/"
  end
end

put "/jobs/:job_id" do
  job_id = params[:job_id]
  job_attrs = params[:job]

  job = Job.get(job_id)
  job.update(job_attrs)

  if request.xhr?
    partial :'partials/job', :locals => { :job => job }
  else
    redirect "/"
  end
end

delete "/jobs/:job_id" do
  job_id = params[:job_id]
  job_attrs = params[:job]

  job = Job.get(job_id)
  job.destroy

  if request.xhr?
    job_id
  else
    redirect "/"
  end
end

post "/skills" do
  skill_attrs = params[:skill]
  skill_attrs.merge!({ :user => default_user })

  skill = Skill.new(skill_attrs)
  skill.save

  if request.xhr? # this will return true when handling an AJAX request
    html =  "<li>"
    html += partial :'partials/skill', :locals => { :skill => skill }
    html += "</li>"
    html
  else
    redirect "/"
  end
end

delete "/skills/:skill_id" do
  skill_id = params[:skill_id]
  skill_attrs = params[:skill]

  skill = Skill.get(skill_id)
  skill.destroy

  if request.xhr?
    skill_id
  else
    redirect "/"
  end
end
