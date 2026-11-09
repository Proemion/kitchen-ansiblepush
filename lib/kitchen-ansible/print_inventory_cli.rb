#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'kitchen-ansible/util_inventory.rb'

class PrintInventory
  def initialize
    temp_group_path = File.join(TEMP_INV_DIR, ENV["INSTANCE_NAME"], TEMP_GROUP_FILE)
    @inventory = {}
    @all = []
    @groups = if File.exist?(temp_group_path)
                read_from_yaml temp_group_path
              else
                {}
              end
    @hosts = {}
  end

  def read_from_yaml(yaml_file)
    YAML.load_file yaml_file
  end

  def read_all_hosts
    Dir.glob(File.join(TEMP_INV_DIR, ENV["INSTANCE_NAME"], 'ansiblepush_host_*.yml'))
  end

  def construct
    read_all_hosts.each do |inv_yml|
      vm = read_from_yaml inv_yml
      vm.each do |host, host_attr|
        if host_attr['mygroup']
          if host_attr['mygroup'].is_a?(Hash)
            host_attr['mygroup'].each do |group|
              add_to_group(group, host)
            end
          elsif host_attr['mygroup'].is_a?(String)
            add_to_group(host_attr['mygroup'], host)
          elsif host_attr['mygroup'].is_a?(Array)
            host_attr['mygroup'].each do |group|
              add_to_group(group, host)
            end
          end
        end
        host_attr.delete('mygroup')
        @hosts[host] = host_attr
        @all << host
      end
    end

    @inventory = { 'all' => { 'hosts' => @all }, '_meta' => { 'hostvars' => @hosts } }
    @groups.merge(@inventory)
  end

  # Groups must be dicts ({ 'hosts' => [...] })
  def add_to_group(group, host)
    @groups[group] = { 'hosts' => @groups[group] } if @groups[group].is_a?(Array)
    @groups[group] ||= { 'hosts' => [] }
    @groups[group]['hosts'] ||= []
    @groups[group]['hosts'] << host
  end

  def output_json
    puts JSON.pretty_generate(@inventory)
  end

  def run
    @inventory = construct
    output_json
  end
end
