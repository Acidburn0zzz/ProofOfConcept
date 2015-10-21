#!/usr/bin/ruby

require './copy_peste'

CopyPeste::Application.load_greetings_module('Hello')
CopyPeste::Application.run_greetings_module('Hello')

CopyPeste::Application.load_greetings_module('Bye')
CopyPeste::Application.run_greetings_module('Bye')
