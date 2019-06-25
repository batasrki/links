ExUnit.start()
Links.RedisRepo.start_link(:particle_transporter)
Links.PeriodicImporter.start_link(interval: 1000, key: "test:set")
Links.LinksMockServer.start_link(nil)
