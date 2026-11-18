require 'rails_helper'

# Notifications are broadcast from background jobs (job container) to browsers connected to
# the web container. Two Action Cable servers here stand in for those two processes; the
# production adapter must carry a message from one to the other (SAM1-25).
RSpec.describe 'Action Cable across processes', type: :model do
  # Production's cable.yml points Solid Cable at the cable database; the test environment
  # uses the test adapter, so connect it here.
  before do
    SolidCable::Record.connects_to(database: { writing: :cable }) unless SolidCable::Record.connection_db_config.name == 'cable'
  end

  after { SolidCable::Message.delete_all }

  def server(adapter)
    ActionCable::Server::Base.new(config: ActionCable::Server::Configuration.new).tap do |s|
      s.config.cable = { 'adapter' => adapter, 'polling_interval' => 0.05, 'message_retention' => '1.day' }
      s.config.logger = Logger.new(nil)
    end
  end

  def delivered_across_processes(adapter)
    web = server(adapter)
    job = server(adapter)
    received = Queue.new
    web.pubsub.subscribe('user:1:notifications', ->(message) { received << message }, -> {})
    sleep 0.2 # let the web side start listening

    job.pubsub.broadcast('user:1:notifications', 'badge update')
    Timeout.timeout(2) { received.pop }
  rescue Timeout::Error
    nil
  ensure
    [web, job].each { |s| s&.pubsub&.shutdown }
  end

  it 'delivers a broadcast made in the job process to the web process with Solid Cable' do
    expect(delivered_across_processes('solid_cable')).to eq('badge update')
  end

  it 'would not with the async adapter production used before' do
    expect(delivered_across_processes('async')).to be_nil
  end

  it 'is what production is configured to use' do
    production = ActiveSupport::ConfigurationFile.parse(Rails.root.join('config/cable.yml'))['production']

    expect(production).to include('adapter' => 'solid_cable', 'connects_to' => { 'database' => { 'writing' => 'cable' } })
  end
end
