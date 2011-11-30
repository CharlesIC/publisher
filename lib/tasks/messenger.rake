namespace :messenger do
  desc "Run queue consumer"
  task :listen => %w{listen:metadata_sync listen:router_bridge}

  namespace :listen do
    desc "Run queue consumer for metadata_sync"
    task :metadata_sync do
      Daemonette.run("publisher_metadata_sync") do
        Rake::Task["environment"].invoke
        MetadataSync.new(Rails.logger).run
      end
    end

    desc "Run queue consumer for router_bridge"
    task :router_bridge do
      Daemonette.run("publisher_router_bridge") do
        Rake::Task["environment"].invoke
        RouterBridge.instance.listen
      end
    end
  end
end
