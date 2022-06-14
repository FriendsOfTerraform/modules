resource "vault_database_secret_backend_connection" "postgres_database_connection" {
  for_each = lower(var.secret_engine) == "database" ? (
    var.database_config.postgres != null ? var.database_config.postgres : {}
  ) : {}

  backend       = vault_mount.secret_mount[0].path
  name          = each.key
  allowed_roles = each.value.allowed_roles

  postgresql {
    connection_url          = each.value.connection_url
    max_open_connections    = each.value.max_open_connections
    max_idle_connections    = each.value.max_idle_connections
    max_connection_lifetime = each.value.max_connection_lifetime_seconds
  }

  verify_connection        = true
  root_rotation_statements = [file("${path.module}/_common/database/postgresql-rotation.sql")]
}