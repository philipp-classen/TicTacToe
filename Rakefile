#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Added to get rid of the 'uninitialized constant Rake::DSL' error
require 'rake/dsl_definition'

require File.expand_path('../config/application', __FILE__)

TicTacToe::Application.load_tasks
