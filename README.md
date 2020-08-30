Heya peeps!

Here are the steps to deploy a whole application (WordPress with MySQL Database) over AWS VPC .
The accessibility of the WordPress will be public while for the database (MySQL) will be private.

So here are the steps!

Steps:
------
    1. Create a VPC.
    2. In that VPC, we have to create 2 subnets:
            2.1.    public subnet [ Accessible for Public World! ]
            2.2.    private subnet [ Restricted for Public World! ]
    3. Create a public facing internet gateway to connect VPC/Network to the internet world and then we have to attach this gateway to the VPC.
    4. Create a routing table for Internet gateway so that instance can connect to outside world, and then we have to update and associate it with public subnet.
    5. Launch an ec2 instance which has WordPress setup already having the security group allowing port 80 so that our client can connect to our WordPress site.   Also attach the key to instance for further login into it.
    6. Launch an ec2 instance which has MYSQL setup already with security group allowing port 3306 in private subnet so that our WordPress instance can connect with the same. Also attach the key with the same.


Note:
-----
    1. WordPress instance has to be part of public subnet so that our client can connect our site.
    2. MySQL instance has to be part of private subnet so that outside world can't connect to it.
    3. Don't forgot to add auto IP assign and auto DNS name assignment option to be enabled.
    
Code contains proper comments for better understanding

Enjoy :)
