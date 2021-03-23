locals {
  user_data = <<-EOF
            #!/usr/bin/bash
            yum install docker -y
            systemctl enable docker
            systemctl start docker
            docker run -d -p 80:80 --name dokuwiki bitnami/dokuwiki:latest
            EOF
}


resource "aws_launch_template" "asg_temp" {
    name_prefix   = "hw8-ec2"
    image_id      = "ami-0533f2ba8a1995cf9"
    instance_type = "t2.micro"
    
    user_data  = base64encode(local.user_data)
    
    
    vpc_security_group_ids = [aws_security_group.example.id]
    
    depends_on = [aws_security_group.example]
}

resource "aws_autoscaling_group" "bar" {
    availability_zones = ["us-east-1a"]
    desired_capacity   = 1
    max_size           = 1
    min_size           = 1

    launch_template {
        id      = aws_launch_template.asg_temp.id
        version = "$Latest"
  }
}