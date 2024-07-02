variable "location" {
  type    = string
  default = "italynorth"
}

variable "tags" {
  type        = map(string)
  description = "Audit Log Solution"
  default = {
    CreatedBy = "Terraform"
  }
}

variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "adl-t-itn"
}

variable "auto_inflate" {
  type    = bool
  default = true
}

variable "account_replication" {
  type    = string
  default = "ZRS"
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "access_tier" {
  type    = string
  default = "Hot"
}

variable "table_names" {
  type    = list(any)
  default = ["AppEvents"]
}

