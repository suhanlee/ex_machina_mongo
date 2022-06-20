import Config

config :ex_machina_mongo, ExMachinaMongoTest.MyRepo,
  database: "ex_machina_mongo_test",
  seeds: ["127.0.0.1"],
  show_sensitive_data_on_connection_error: true

config :mongodb_driver,
  log: false
