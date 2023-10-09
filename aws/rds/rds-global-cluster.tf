resource "aws_rds_global_cluster" "global_cluster" {
  count = local.is_aurora ? (
    var.aurora_global_cluster != null ? 1 : 0
  ) : 0

  global_cluster_identifier = var.aurora_global_cluster.name
  database_name             = var.db_name
  deletion_protection       = var.delete_protection_enabled
  engine                    = var.engine.type
  engine_version            = var.engine.version
  force_destroy             = true
}
