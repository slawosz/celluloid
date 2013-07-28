#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'celluloid'
require 'benchmark/ips'

mailbox = Celluloid::Mailbox.new
latch_in, latch_out = Queue.new, Queue.new

latch = Thread.new do
  while true
    n = latch_in.pop
    for i in 0..n; mailbox.receive; end
    latch_out << :done
  end
end

Benchmark.ips do |ips|
  ips.report("messages") do |n|
    latch_in << n
    for i in 0..n; mailbox << :message; end
    latch_out.pop
  end
end
