#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "paywallet-sandbox" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-paywallet-sandbox-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "paywallet-sandbox" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.paywallet-sandbox.id

  tags = tomap({
    "Name"                                      = "terraform-eks-paywallet-sandbox-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "paywallet-sandbox" {
  vpc_id = aws_vpc.paywallet-sandbox.id

  tags = {
    Name = "terraform-eks-paywallet-sandbox"
  }
}

resource "aws_route_table" "paywallet-sandbox" {
  vpc_id = aws_vpc.paywallet-sandbox.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.paywallet-sandbox.id
  }
}

resource "aws_route_table_association" "paywallet-sandbox" {
  count = 2

  subnet_id      = aws_subnet.paywallet-sandbox.*.id[count.index]
  route_table_id = aws_route_table.paywallet-sandbox.id
}
