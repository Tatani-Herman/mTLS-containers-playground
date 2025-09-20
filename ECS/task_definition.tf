resource "aws_ecs_task_definition" "hello" {
  family                   = "hello-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "http-echo"
      image     = "hashicorp/http-echo:0.2.3"
      essential = true
      portMappings = [
        {
          containerPort = 5678
          protocol      = "tcp"
        }
      ]
      command = ["-text", "Hello world from ECS!"]
    }
  ])
}
