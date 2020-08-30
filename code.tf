# Login to AWS

provider "aws" {
    region     = "ap-south-1"
    profile    = "iam-user"
    access_key = "your-access-key"
    secret_key = "your-secret-key"
}







# Creating the VPC

resource "aws_vpc" "task3-vpc" {
    cidr_block               = "192.168.0.0/16"
    instance_tenancy         = "default"
    enable_dns_hostnames     = "true"
    
    tags = {
        Name = "task3-vpc"
    }
}








# Creating Subnet

# Public Subnet
resource "aws_subnet" "pub-subnet" {
    depends_on              = [ aws_vpc.task3-vpc ,]
    vpc_id                  = aws_vpc.task3-vpc.id
    cidr_block              = "192.168.0.0/24"
    availability_zone       = "ap-south-1a"
    map_public_ip_on_launch = "true"
    
    tags = {
        Name = "pub-subnet"
    }
}









# Private Subnet
resource "aws_subnet" "priv-subnet" {
    depends_on         = [ aws_vpc.task3-vpc ,]
    vpc_id             = aws_vpc.task3-vpc.id
    cidr_block         = "192.168.1.0/24"
    availability_zone  = "ap-south-1b"
    
    tags = {
        Name = "priv-subnet"
    }
}








# Creating Internet Gateway

resource "aws_internet_gateway" "task3-internet-gateway" {
    depends_on       = [ aws_vpc.task3-vpc ,]
    vpc_id           = aws_vpc.task3-vpc.id
    tags = {
        Name = "task3-internet-gateway"
    }
}








# Creating Route Table for Internet Gateway for Public Access

resource "aws_route_table" "task3-route-table" {
    depends_on         = [ aws_vpc.task3-vpc ,]
    vpc_id             = aws_vpc.task3-vpc.id
    route {
        cidr_block     = "0.0.0.0/0"
        gateway_id     = aws_internet_gateway.task3-internet-gateway.id
    }
 
    tags = {
        Name = "task3-route-table"
    }
}








# Association of Route table to Public Subnet

resource "aws_route_table_association" "pub-subnet-route-table" {
    depends_on        = [ aws_route_table.task3-route-table , aws_subnet.pub-subnet ]    
    subnet_id         = aws_subnet.pub-subnet.id
    route_table_id    = aws_route_table.task3-route-table.id
}









# Generating Key pair

resource "tls_private_key" "archKeyPair" {
    algorithm   = "RSA"
}

resource "aws_key_pair" "archKey" {
    key_name   = "archKey"
    public_key = "ssh-rsa 8Ep5lwgaUvcKiDOdya2BSgv4mNUQD0=silverhonk@armour"

    depends_on = [tls_private_key.archKeyPair]
}








# Creating Security Group for WordPress

resource "aws_security_group" "wordpress-security-group" {
    depends_on      = [ aws_vpc.task3-vpc ,]
    name            = "wp-allow"
    description     = "https and ssh"
    vpc_id          = aws_vpc.task3-vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name ="wp-allow"
    }
}







# Creating Security Group for MySQL

resource "aws_security_group" "msql-security-group" {
    depends_on     = [ aws_vpc.task3-vpc ,]
    name            = "msql-allow"
    description     = "mysql-allow-port-3306"
    vpc_id          = aws_vpc.task3-vpc.id

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name =    "msql-allow"
    }
}








# Launch WordPress Instance

resource "aws_instance" "wordpress-instance" {
    depends_on      = [ aws_subnet.pub-subnet , aws_security_group.wordpress-security-group]
    ami             = "ami-7e257211"
    instance_type   = "t2.micro"
    key_name        = aws_key_pair.archKey.key_name
    security_groups = [aws_security_group.wordpress-security-group.id ,]
        subnet_id   = aws_subnet.pub-subnet.id
 
    tags = {
        Name = "wp-instance"
    }
}








# Launching MySQL Instance

resource "aws_instance" "mysql-instance" {
    depends_on      = [ aws_subnet.priv-subnet , aws_security_group.msql-security-group]
    ami             = "ami-08706cb5f68222d09"
    instance_type   = "t2.micro"
    key_name        = aws_key_pair.archKey.key_name
    security_groups = [aws_security_group.msql-security-group.id ,]
    subnet_id       = aws_subnet.priv-subnet.id
 
    tags = {
        Name = "mysql-instance"
    }
}







# Get public IP of WordPress

output "wordpress-ip" {
    value = aws_instance.wordpress-instance.public_ip
}






# Connect to the WordPress

resource "null_resource" "open-wp"  {

    depends_on = [aws_instance.wordpress-instance, aws_instance.mysql-instance]
}



