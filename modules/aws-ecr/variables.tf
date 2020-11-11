variable "repository_name" {
  type = string
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "image_scanning_configuration_scan_on_push" {
  type        = bool
  default     = true
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
}

variable "keep_image_size" {
  type        = string
  default     = "7"
}
