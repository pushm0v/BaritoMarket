require 'rails_helper'

RSpec.describe PathfinderProvisioner do
  describe '#provision!' do
    before(:all) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'

      # Mock Pathfinder API
      stub_request(:post, "http://#{@pathfinder_host}/api/v1/ext_app/containers.json").
        with(
          query: {
            'cluster_name' => @pathfinder_cluster
          },
          body: {
            'container' => {
              'hostname' => 'test-01',
              'image' => '18.04',
            }
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 201,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'error' => '',
            'data' => {
              'ipaddress' => '127.0.0.1'
            }
          }.to_json
        })
    end

    it 'should make necessary calls to Pathfinder and return the response' do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      provision_result = pathfinder_provisioner.provision!('test-01')
      expect(provision_result).to eq({
        'success' => true,
        'data' => {'ipaddress' => '127.0.0.1'},
      })
    end
  end

  describe '#reprovision!' do
    before(:all) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'

      # Mock Pathfinder API
      stub_request(:post, "http://#{@pathfinder_host}/api/v1/ext_app/containers/test-01/reschedule").
        with(
          query: {
            'cluster_name' => @pathfinder_cluster
          },
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 201,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'error' => '',
            'data' => {
              'ipaddress' => '127.0.0.1'
            }
          }.to_json
        })
    end

    it 'should make necessary calls to Pathfinder and return the response' do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      provision_result = pathfinder_provisioner.reprovision!('test-01')
      expect(provision_result).to eq({
        'success' => true,
        'data' => {'ipaddress' => '127.0.0.1'},
      })
    end
  end

  describe '#delete_container!' do
    before(:all) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'

      # Mock Pathfinder API
      stub_request(:post, "http://#{@pathfinder_host}/api/v1/ext_app/containers/test-01/schedule_deletion").
        with(
          query: {
            'cluster_name' => @pathfinder_cluster
          },
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 201,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'error' => '',
            'data' => {
              'status' => 'SCHEDULE_DELETION'
            }
          }.to_json
        })
    end

    it 'should make necessary calls to Pathfinder and return the response' do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      provision_result = pathfinder_provisioner.delete_container!('test-01')
      expect(provision_result).to eq({
        'success' => true,
        "data" => {
          "error" => "",
          "data" => {
            "status" => "SCHEDULE_DELETION"
          }
        }
      })
    end
  end
end
