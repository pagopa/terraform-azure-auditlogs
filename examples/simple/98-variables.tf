variable "location" {
  type    = string
  default = "italynorth"
}

variable "tags" {
  type        = map(string)
  description = "Audit Log Solution"
  default = {
    CreatedBy   = "Terraform"
    Description = "Test with object replication"
  }
}

variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "adl-t-itn"
}
