variable "private_subnet_id" {
  description = "ID de la subnet privada donde se montará FSx"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de security groups asociados a FSx"
  type        = list(string)
}
