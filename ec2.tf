# key pair (login)

resource aws_key_pair deployer {
    key_name = "terra-key-ec2"
    public_key = file("terra-key-ec2.pub")
}
# VPC & security group
    resource aws_default_vpc default {

    }
    resource aws_security_group my_security_group {
        name = "automate-sg"
        description = "This will add a TF generated security group"
        vpc_id = aws_default_vpc.default.id #interpolation
        # Inbound rules
        ingress {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "SSH open"
        }
        ingress {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "HTTP open"
        }
        ingress {
            from_port = 8000
            to_port = 8000
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "Flask app"
        }
        #outbound rules
        egress{
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            description = "all access open"
        }

        tags = {
            Name = "allow_tls"
        }

    }
    
# ec2 instance

resource aws_instance my_instance {
    # count = 2 # meta argumenet
    for_each = tomap ({
        my-instance-1 = "t3.micro"
        my-instance-2 = "t3.micro"
    })
    key_name = aws_key_pair.deployer.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type = each.value
    ami = var.ec2_ami_id
    user_data = file("install-nginx.sh")

    root_block_device {
        volume_size = var.ec2_root_storage_size
        volume_type = "gp3"
    } 
    tags = {
        Name = each.key
    }
}