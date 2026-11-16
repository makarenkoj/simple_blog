# N+1 gate: Prosopite raises on repeated SQL fingerprints from one call site.
#
# The scan window must match one unit of work, or legitimate repeats look like N+1:
# - request specs: one window per HTTP request (an example may send several);
# - system specs: not scanned, one example visits many pages;
# - everything else (models, services, jobs): one window per example,
#   except examples tagged `prosopite: false`.
Prosopite.raise = true
# Only N+1s that run through our code count; a spec's factory setup creating many
# users (friendly_id slug checks) is not an app N+1. App callbacks stay covered.
Prosopite.focus_stack_paths = [Rails.root.join('app').to_s]
# Generating a variant (and storing its record) happens once per image and variation;
# the per-render lookup of an existing variant record stays scanned.
Prosopite.pause_during('transform.active_storage')

module ProsopitePerRequest
  def process(...)
    Prosopite.scan
    super
  ensure
    Prosopite.finish
  end
end

ActionDispatch::Integration::Session.prepend(ProsopitePerRequest)

RSpec.configure do |config|
  config.around do |example|
    # `prosopite: false` marks an example that calls one public method many times on
    # purpose (spam guards, volume checks): the repeats are the test, not an N+1.
    next example.run if %i[request system].include?(example.metadata[:type]) || example.metadata[:prosopite] == false

    Prosopite.scan
    begin
      example.run
    ensure
      Prosopite.finish
    end
  end
end
