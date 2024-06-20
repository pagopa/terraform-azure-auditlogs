variable "location" {
  type    = string
  default = "italynorth"
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "adl-t-itn"
}

