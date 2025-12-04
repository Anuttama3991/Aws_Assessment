# Task 1 – Custom VPC with Public & Private Subnets

## Requirements achieved
- Custom VPC (10.0.0.0/16)  
- 2 Public subnets + 2 Private subnets across ap-south-1a & 1b  
- Internet Gateway attached  
- NAT Gateway + Elastic IP in public subnet  
- Separate public & private route tables with correct routes

## Screenshots

**VPC**  
![VPC](screenshots/vpc.png)

**Subnets**  
![Subnets](screenshots/subnets.png)

**Internet Gateway**  
![IGW](screenshots/igw.png)

**NAT Gateway (active)**  
![NAT](screenshots/nat.png)

**Private Route Table → NAT**  
![Private Route](screenshots/private-route-table.png)

**All resources destroyed on 2025-12-04** – zero cost.
