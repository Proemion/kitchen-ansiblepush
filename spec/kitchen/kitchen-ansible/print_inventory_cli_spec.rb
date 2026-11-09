require_relative '../../spec_helper'

require 'kitchen-ansible/print_inventory_cli'

describe PrintInventory do
  before :each do
    ENV['INSTANCE_NAME'] = 'example_suite'
    @printinventory = PrintInventory.new
  end

  describe '#new' do
    it 'Returns PrintInventory' do
      expect(@printinventory).to be_an_instance_of(PrintInventory)
    end
  end

  describe '#construct' do
    it 'Returns groups as dicts with hosts' do
      allow(@printinventory).to receive(:read_all_hosts).and_return(['host.yml'])
      allow(@printinventory).to receive(:read_from_yaml).with('host.yml').and_return(
        'vm1' => { 'ansible_host' => '10.0.0.1', 'mygroup' => %w[kitchen chatbolt] }
      )
      inventory = @printinventory.construct
      expect(inventory['all']).to eq('hosts' => ['vm1'])
      expect(inventory['kitchen']).to eq('hosts' => ['vm1'])
      expect(inventory['chatbolt']).to eq('hosts' => ['vm1'])
      expect(inventory['_meta']['hostvars']['vm1']).to eq('ansible_host' => '10.0.0.1')
    end
  end
end
