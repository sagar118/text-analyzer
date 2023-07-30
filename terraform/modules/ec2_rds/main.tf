// This data object is going to be
// holding all the available availability
// zones in our defined region
data "aws_availability_zones" "available" {
  state = "available"
}

// Create a VPC named "vpc"
resource "aws_vpc" "vpc_block" {
  // Here we are setting the CIDR block of the VPC
  // to the "vpc_cidr_block" variable
  cidr_block           = var.vpc_cidr_block
  // We want DNS hostnames enabled for this VPC
  enable_dns_hostnames = true

  // We are tagging the VPC with the name "vpc_block"
  tags = {
    Name = "mlops-zc-ta-vpc-block-${var.env}"
  }
}

// Create an internet gateway named "igw"
// and attach it to the "vpc" VPC
resource "aws_internet_gateway" "igw_block" {
  // Here we are attaching the IGW to the 
  // vpc VPC
  vpc_id = aws_vpc.vpc_block.id

  // We are tagging the IGW with the name igw
  tags = {
    Name = "mlops-zc-ta-igw-block-${var.env}"
  }
}

// Create a group of public subnets based on the variable subnet_count.public
resource "aws_subnet" "public_subnet" {
  // count is the number of resources we want to create
  // here we are referencing the subnet_count.public variable which
  // current assigned to 1 so only 1 public subnet will be created
  count             = var.subnet_count.public
  
  // Put the subnet into the "vpc_block" VPC
  vpc_id            = aws_vpc.vpc_block.id
  
  // We are grabbing a CIDR block from the "public_subnet_cidr_blocks" variable
  // since it is a list, we need to grab the element based on count,
  // since count is 1, we will be grabbing the first cidr block 
  // which is going to be 10.0.1.0/24
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  
  // We are grabbing the availability zone from the data object we created earlier
  // Since this is a list, we are grabbing the name of the element based on count,
  // so since count is 1, and our region is us-east-2, this should grab us-east-2a
  availability_zone = data.aws_availability_zones.available.names[count.index]

  // We are tagging the subnet with a name of "public_subnet_" and
  // suffixed with the count
  tags = {
    Name = "mlops-zc-ta-public-subnet-${count.index}-${var.env}"
  }
}

// Create a group of private subnets based on the variable subnet_count.private
resource "aws_subnet" "private_subnet" {
  // count is the number of resources we want to create
  // here we are referencing the subnet_count.private variable which
  // current assigned to 2, so 2 private subnets will be created
  count             = var.subnet_count.private
  
  // Put the subnet into the "vpc_block" VPC
  vpc_id            = aws_vpc.vpc_block.id
  
  // We are grabbing a CIDR block from the "private_subnet_cidr_blocks" variable
  // since it is a list, we need to grab the element based on count,
  // since count is 2, the first subnet will grab the CIDR block 10.0.101.0/24
  // and the second subnet will grab the CIDR block 10.0.102.0/24
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  
  // We are grabbing the availability zone from the data object we created earlier
  // Since this is a list, we are grabbing the name of the element based on count,
  // since count is 2, and our region is us-east-2, the first subnet should
  // grab us-east-2a and the second will grab us-east-2b
  availability_zone = data.aws_availability_zones.available.names[count.index]

  // We are tagging the subnet with a name of "private_subnet_" and
  // suffixed with the count
  tags = {
    Name = "mlops-zc-ta-private-subnet-${count.index}-${var.env}"
  }
}

// Create a public route table named "public_rt"
resource "aws_route_table" "public_rt" {
  // Put the route table in the "vpc_block" VPC
  vpc_id = aws_vpc.vpc_block.id

  // Since this is the public route table, it will need
  // access to the internet. So we are adding a route with
  // a destination of 0.0.0.0/0 and targeting the Internet 	 
  // Gateway "igw_block"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_block.id
  }
}

// Here we are going to add the public subnets to the 
// "public_rt" route table
resource "aws_route_table_association" "public" {
  // count is the number of subnets we want to associate with
  // this route table. We are using the subnet_count.public variable
  // which is currently 1, so we will be adding the 1 public subnet
  count          = var.subnet_count.public
  
  // Here we are making sure that the route table is
  // "public_rt" from above
  route_table_id = aws_route_table.public_rt.id
  
  // This is the subnet ID. Since the "public_subnet" is a 
  // list of the public subnets, we need to use count to grab the
  // subnet element and then grab the id of that subnet
  subnet_id      = 	aws_subnet.public_subnet[count.index].id
}

// Create a private route table named "private_rt"
resource "aws_route_table" "private_rt" {
  // Put the route table in the "VPC_block" VPC
  vpc_id = aws_vpc.vpc_block.id
  
  // Since this is going to be a private route table, 
  // we will not be adding a route
}

// Here we are going to add the private subnets to the
// route table "private_rt"
resource "aws_route_table_association" "private" {
  // count is the number of subnets we want to associate with
  // the route table. We are using the subnet_count.private variable
  // which is currently 2, so we will be adding the 2 private subnets
  count          = var.subnet_count.private
  
  // Here we are making sure that the route table is
  // "private_rt" from above
  route_table_id = aws_route_table.private_rt.id
  
  // This is the subnet ID. Since the "private_subnet" is a
  // list of private subnets, we need to use count to grab the
  // subnet element and then grab the ID of that subnet
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

// Create a security for the EC2 instances called "ec2_sg"
resource "aws_security_group" "ec2_sg" {
  // Basic details like the name and description of the SG
  name        = "mlops-zc-ta-ec2-sg-${var.env}"
  description = "Security group for ec2 servers"
  // We want the SG to be in the "vpc_block" VPC
  vpc_id      = aws_vpc.vpc_block.id

  // The first requirement we need to meet is "EC2 instances should 
  // be accessible anywhere on the internet via HTTP." So we will 
  // create an inbound rule that allows all traffic through
  // TCP port 80.
  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // The second requirement we need to meet is "Only you should be 
  // "able to access the EC2 instances via SSH." So we will create an 
  // inbound rule that allows SSH traffic ONLY from your IP address
  ingress {
    description = "Allow SSH from my computer"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This outbound rule is allowing all outbound traffic
  // with the EC2 instances
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Here we are tagging the SG with the name "ec2-sg"
  tags = {
    Name = "mlops-zc-ta-ec2-sg-${var.env}"
  }
}

// Create a security group for the RDS instances called "db_sg"
resource "aws_security_group" "db_sg" {
  // Basic details like the name and description of the SG
  name        = "mlops-zc-ta-db-sg-${var.env}"
  description = "Security group for databases"
  // We want the SG to be in the "vpc_block" VPC
  vpc_id      = aws_vpc.vpc_block.id

  // The third requirement was "RDS should be on a private subnet and 	
  // inaccessible via the internet." To accomplish that, we will 
  // not add any inbound or outbound rules for outside traffic.
  
  // The fourth and finally requirement was "Only the EC2 instances 
  // should be able to communicate with RDS." So we will create an
  // inbound rule that allows traffic from the EC2 security group
  // through TCP port 3306, which is the port that MySQL 
  // communicates through
  ingress {
    description     = "Allow Postgres traffic from only the ec2 instance"
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  // Here we are tagging the SG with the name "db-sg"
  tags = {
    Name = "mlops-zc-ta-db-sg-${var.env}"
  }
}

// Create a db subnet group named "db_subnet_group"
resource "aws_db_subnet_group" "db_subnet_group" {
  // The name and description of the db subnet group
  name        = "mlops-zc-ta-db-subnet-group-${var.env}"
  description = "DB subnet group"
  
  // Since the db subnet group requires 2 or more subnets, we are going to
  // loop through our private subnets in "private_subnet" and
  // add them to this db subnet group
  subnet_ids  = [for subnet in aws_subnet.private_subnet : subnet.id]
}

// Create a DB instance called "database"
resource "aws_db_instance" "database" {
  // The amount of storage in gigabytes that we want for the database. This is 
  // being set by the settings.database.allocated_storage variable, which is 
  // set to 10
  allocated_storage      = var.settings.database.allocated_storage
  
  // The engine we want for our database. This is being set by the 
  // settings.database.engine variable, which is set to "mysql"
  engine                 = var.settings.database.engine
  
  // The version of our database engine. This is being set by the 
  // settings.database.engine_version variable, which is set to "8.0.27"
  engine_version         = var.settings.database.engine_version
  
  // The instance type for our DB. This is being set by the 
  // settings.database.instance_class variable, which is set to "db.t2.micro"
  instance_class         = var.settings.database.instance_class
  
  // This is the name of our database. This is being set by the
  // settings.database.db_name variable
  db_name                = var.db_name
  
  // The master user of our database. This is being set by the
  // db_username variable, which is being declared in our secrets file
  username               = var.db_username
  
  // The password for the master user. This is being set by the 
  // db_username variable, which is being declared in our secrets file
  password               = var.db_password
  
  // This is the DB subnet group "db_subnet_group"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  
  // This is the security group for the database. It takes a list, but since
  // we only have 1 security group for our db, we are just passing in the
  // "db_sg" security group
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  // This refers to the skipping final snapshot of the database. It is a 
  // boolean that is set by the settings.database.skip_final_snapshot
  // variable, which is currently set to true.
  skip_final_snapshot    = var.settings.database.skip_final_snapshot

  // Here we are tagging the database with the name "mlops-zc-ta-database"
  tags = {
    Name = "mlops-zc-ta-mlflow-database-${var.env}"
  }
}

// Create an EC2 instance named "ec2_instance"
resource "aws_instance" "ec2_instance" {
  // count is the number of instance we want
  // since the variable settings.ec2_instance.count is set to 1, we will only get 1 EC2
  count                  = var.settings.ec2_instance.count
  
  // Here we need to select the ami for the EC2. The variable
  // settings.ec2_instance.ami is set to "ami-053b0d53c279acc90"
  ami                    = var.settings.ec2_instance.ami
  
  // This is the instance type of the EC2 instance. The variable
  // settings.ec2_instance.instance_type is set to "t3.2xlarge"
  instance_type          = var.settings.ec2_instance.instance_type
  
  // The subnet ID for the EC2 instance. Since "public_subnet" is a list
  // of public subnets, we want to grab the element based on the count variable.
  // Since count is 1, we will be grabbing the first subnet in  	
  // "public_subnet" and putting the EC2 instance in there
  subnet_id              = aws_subnet.public_subnet[count.index].id
  
  // The key pair to connect to the EC2 instance. We are using the "key_name" key 
  // pair that we created
  key_name               = var.settings.ec2_instance.key_name
  
  // The security groups of the EC2 instance. This takes a list, however we only
  // have 1 security group for the EC2 instances.
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  // The IAM instance profile for the EC2 instance. We are using the
  // varible "ec2_instance_profile".
  iam_instance_profile   = var.ec2_instance_profile

  lifecycle {
    prevent_destroy = true
  }

  // We are tagging the EC2 instance with the name "mlops-zc-ta-ec2-instance-" followed by
  // the count index
  tags = {
    Name = "mlops-zc-ta-ec2-instance-${count.index}-${var.env}"
  }
}

// Create an Elastic IP named "ec2_eip" for each
// EC2 instance
resource "aws_eip" "ec2_eip" {
	// count is the number of Elastic IPs to create. It is
	// being set to the variable settings.ec2_instance.count which
	// refers to the number of EC2 instances. We want an
	// Elastic IP for every EC2 instance
  count    = var.settings.ec2_instance.count

	// The EC2 instance. Since ec2_instance is a list of 
	// EC2 instances, we need to grab the instance by the 
	// count index. Since the count is set to 1, it is
	// going to grab the first and only EC2 instance
  instance = aws_instance.ec2_instance[count.index].id

	// We want the Elastic IP to be in the VPC
  domain      = "vpc"

	// Here we are tagging the Elastic IP with the name
	// "ec2-instance-eip-" followed by the count index
  tags = {
    Name = "mlops-zc-ta-ec2-instance-eip-${count.index}-${var.env}"
  }
}