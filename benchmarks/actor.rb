#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'celluloid'
require 'benchmark/ips'

class ExampleActor
  include Celluloid

  def initialize
    @condition = Condition.new
  end

  def example_method; end

  def finished
    @condition.signal
  end

  def wait_until_finished
    @condition.wait
  end
end

example_actor = ExampleActor.new

Benchmark.ips do |ips|
  ips.report("spawn")       { ExampleActor.new.terminate }

  ips.report("calls")       { example_actor.example_method }

  ips.report("async calls") do |n|
    waiter = example_actor.future.wait_until_finished

    (n - 1).times { example_actor.async.example_method }
    example_actor.async.finished

    waiter.value
  end
end
