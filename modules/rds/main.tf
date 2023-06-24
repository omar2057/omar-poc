resource "aws_vpc" "poc_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "poc_vpc"
  }
}

resource "aws_subnet" "poc_public_subnet_1" {
  vpc_id = aws_vpc.poc_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "poc_PublicSubnet1"
  }
}

resource "aws_subnet" "poc_public_subnet_2" {
  vpc_id = aws_vpc.poc_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "poc_PublicSubnet2"
  }
}

resource "aws_internet_gateway" "poc_igw" {
  vpc_id = aws_vpc.poc_vpc.id
  tags = {
    Name = "poc_igw"
  }
}

resource "aws_route_table" "poc_public_db_rt" {
  vpc_id = aws_vpc.poc_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc_igw.id
  }
  tags = {
    Name = "poc-db-rt"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.poc_public_subnet_1.id
  route_table_id = aws_route_table.poc_public_db_rt.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.poc_public_subnet_2.id
  route_table_id = aws_route_table.poc_public_db_rt.id
}

resource "aws_db_subnet_group" "poc_db_subnet_group" {
  name       = "poc_dbgroup"
  subnet_ids = [
    aws_subnet.poc_public_subnet_1.id,
    aws_subnet.poc_public_subnet_2.id,
  ]
  tags = {
    Name = "poc_dbgroup"
  }
}

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


