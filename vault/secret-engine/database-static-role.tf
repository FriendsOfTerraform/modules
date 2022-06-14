resource "vault_database_secret_backend_static_role" "static_roles" {
  for_each   = var.database_static_backend_roles
  depends_on = [vault_database_secret_backend_connection.postgres_database_connection]

  backend             = vault_mount.secret_mount[0].path
  name                = each.key
  db_name             = each.value.database_name
  username            = each.key
  rotation_period     = each.value.rotation_period_seconds != null ? each.value.rotation_period_seconds : 86400 # 24 hours
  rotation_statements = [file("${path.module}/_common/database/postgresql-rotation.sql")]
}