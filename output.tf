
output "availabezones"{
    value = data.aws_availability_zones.available.names
}

output "vpcid"{
    value = aws_vpc.vpc.id
}