# Network Definition 
resource "aws_vpc" "poc_vpc" {
  cidr_block = "172.200.0.0/16"
  tags = {
    Name = "vpc-poc"
  }
}

# Public subnets for 1 availability zones
resource "aws_subnet" "poc_public_subnet-a" {
  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = "172.200.0.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "poc-public-subnet-a"
  }
}

# Private subnets for 1 availability zones
resource "aws_subnet" "poc_private_subnet-a" {
  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = "172.200.16.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "poc-private-subnet-a"
  }
}

# DB subnets for 1 availability zones
resource "aws_subnet" "poc_db_subnet-a" {
  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = "172.200.32.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "poc-db-subnet-a"
  }
}

# VPC Route tables
resource "aws_route_table" "poc_public_rt" {
  vpc_id = aws_vpc.poc_vpc.id
  tags = {
    Name = "poc-public-rt"
  }
}

resource "aws_route_table" "poc_private_rt" {
  vpc_id = aws_vpc.poc_vpc.id
  tags = {
    Name = "poc-private-rt"
  }
}

resource "aws_route_table" "poc_db_rt" {
  vpc_id = aws_vpc.poc_vpc.id
  tags = {
    Name = "poc-db-rt"
  }
}

# Public subnets route table association
resource "aws_route_table_association" "public_rt_a" {
  subnet_id = aws_subnet.poc_public_subnet-a.id
  route_table_id = aws_route_table.poc_public_rt.id
}

# Private subnets route table association
resource "aws_route_table_association" "private_rt_a" {
  subnet_id = aws_subnet.poc_private_subnet-a.id
  route_table_id = aws_route_table.poc_private_rt.id
}

# DB subnets route table association
resource "aws_route_table_association" "db_rt_a" {
  subnet_id = aws_subnet.poc_db_subnet-a.id
  route_table_id = aws_route_table.poc_db_rt.id
}

# Internet Gateway Definition
resource "aws_internet_gateway" "poc_igw_01" {
  vpc_id = aws_vpc.poc_vpc.id
  tags = {
    Name = "poc-igw"
  }
}

# Internet Route for public subnets
resource "aws_route" "poc_internet_rt_01" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.poc_public_rt.id
  gateway_id = aws_internet_gateway.poc_igw_01.id
}

#create a security group for RDS Database Instance
resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id      = aws_vpc.poc_vpc.id
}

resource "aws_db_subnet_group" "poc_db_subnet_group" {
  name = "poc_db_subnet_group"
  subnet_ids = [aws_subnet.poc_public_subnet-a.id, aws_subnet.poc_private_subnet-a.id]
}

#create a RDS Database Instance
resource "aws_db_instance" "myinstance" {
  # name                   = var.db_name
  engine                 = "sqlserver-ex"
  identifier             = "myrdsinstance"
  allocated_storage      = 20
  engine_version         = "14.00.3451.2.v1"
  instance_class         = "db.t2.micro"
  username               = var.admin_user
  password               = var.admin_pass
  # parameter_group_name   = "default.mssql"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  port = 1433
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = "${aws_db_subnet_group.poc_db_subnet_group.name}"

}

resource "null_resource" "execute_sql" {
  provisioner "local-exec" {
    command = "sqlcmd -U ${var.admin_user} -S ${aws_db_instance.myinstance.address},${aws_db_instance.myinstance.port} -i ../../modules/rds/dump_db.sql"
  }
  depends_on = [aws_db_instance.myinstance]
}


