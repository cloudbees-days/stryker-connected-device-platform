resource "aws_security_group" "device_management" {
  name        = "stryker-cdp-device-management"
  description = "Security group for connected device management plane"
  vpc_id      = var.vpc_id

  # Inbound: HTTPS from approved load balancer only
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
    description = "HTTPS from internal VPC only"
  }

  # WARNING: CCI-IAC-001 VIOLATION
  # SSH management port exposed to all public internet traffic.
  # Must be restricted to VPN CIDR (10.200.0.0/16) per OSEP network policy.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH — TEMP open during migration, never restricted"
  }

  # Device telemetry inbound
  ingress {
    from_port   = 8883
    to_port     = 8883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MQTT/TLS for device telemetry"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "cdp-device-management"
    Environment = "production"
    Team        = "connected-device-platform"
    Criticality = "critical"
    Regulated   = "true"
  }
}

resource "aws_security_group" "device_telemetry_ingest" {
  name        = "stryker-cdp-telemetry-ingest"
  description = "Security group for telemetry ingestion pipeline"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8883
    to_port     = 8883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MQTT/TLS inbound from field devices"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cdp-telemetry-ingest"
    Team = "connected-device-platform"
  }
}
