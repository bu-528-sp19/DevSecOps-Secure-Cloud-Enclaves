# DevSecOps-Secure-Cloud-Enclaves
## Vision and Goals

As the workplace evolves, so must security for such an environment. Today we live in the cloud-native and container security era, with IT professionals having to understand Docker, Kubernetes, serverless computing, and much more. This age of increasingly sophisticated systems has resulted in more complex cyber-attacks, and the legacy firewalls can’t keep up anymore. Resources that can be entirely firewalled off from the world are becoming rarer everyday.  Even on-prem infrastructures for internal applications has to connect to an outside resource at some point (backups, S3 storage, etc).

It is also no longer so simple to just restrict all external traffic using a firewall; IT departments cannot simply have a whitelist, as everything is dynamic now. For example, consider the remote employee trying to connect from their home PC,tablet, or even an IoT device. All these have non-static IP addresses, so the whitelist would have to be updated constantly. With multiple endpoints now to consider, the surface area for malicious activity has increased immensely. 

With this, new methods have to be implemented within one’s infrastructure to ensure security.  Among these methods are logging, or event entries which captures information related to a specific event that occurred which is tied to a certain device.   These should include critical events such as starting and stopping a system or service, any and all attempted log-ins, system security settings, account changes (user or application based), and much more.  These extensive logs could capture a timestamp, the user/system/device tied to the event, etc.  This information keeps track of important transactions, so that any attackers actions may be logged, such that post attack investigations can deduce what went wrong. 

Naturally, with such a wealth of information, any malicious actor would want to go after such logs, so as to hide their actions.  To prevent this, audit logs are kept under strong access control to limit the amount of users who may modify such vital resources.  It would also be reasonable to ensure that even if the attacker managed to access the logs in some way, that they wouldn’t be of value to them; this is usually done through encryption..

Setting up such an environment, with all of these features to ensure security, would intuitively take many hours of labor on the departments responsible. With this in mind, DevSecOps will provide an automated approach to ensure a secure cloud enclave.  Specifically, we will use CONS3RT, a leading-edge cloud and security orchestration service, to implement governance and industry standards when it comes to security.  This will include such vital aspects such as logging and identity access management.

## Users/Personas Of The Project
The users of the project would be:
* __Mission owner__- Admin to the project system from the customer’s side, who would control access and security of other customer users. The mission owner would control the customer user access levels. 
* __General users__- People with access to the data involved with the project.
* __Support users__- Users from Jackpine technologies organization, who would control the updates and maintenance of the CONS3RT software.  These users would provide us with access to the CONS3RT software, and enable us to access the MOC through CONS3RT.
* __MOC (Massachusetts Open Cloud) admin__ - MOC admin would provide resources required for the project and would allocate space for the project over the MOC. We would receive access to resources such as Ceph storage through the MOC admin.
* __Open source developers’ community__ - Since the project is open source, open source developers can contribute to it to enhance the features of the project and to add more functionalities to it.
* __Regulatory agencies__- Agencies that oversee, audit and accredit service providers. The Department of Defense, for an instance, is one such regulatory agency, which imposes a 60-day maximum password lifetime restriction on the users of the system.

## Scope
“DevSecOps: Secure Cloud Enclaves” aims to provide a solution that automates building of secure enclaves within the Massachusetts Open Cloud. In terms of compliance, this shall include, but not be limited to the FedRAMP Moderate/DoD Impact Level 2 security specifications as the immediate goal, with a vision to extend this for Impact Level 4 in the future.

#### FedRAMP Impact Levels
![FedRAMP Impact Levels](https://github.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/blob/master/impact%20levels.JPG "FedRAMP Impact Levels")
_(Source: https://iasecontent.disa.mil/cloud/SRG/index.html#3INFORMATIONSECURITYOBJECTIVES/IMPACTLEVELS)_

The features of this project can be can be summarized under five main headings:
1. Storage
2. Logging
3. Accounts & Credentials
4. Keys and Encryption
5. Java Workflow

### Storage and Logging:
Object storage and its security and logging components are designed as follows:
* Storage is implemented in the form of buckets that can house any number of objects
* A dedicated bucket is used to store logs
* Only SSL requests are allowed on the buckets
* Public read/write is disabled on the buckets
* Versioning is enabled on the buckets, which implies that:
  * Previous versions of objects can be restored
  * Deleted objects can be restored
* Logs are generated through the APIs we have created and scripted and are stored on the buckets
* Log file validation is enabled

### Accounts & Credentials:
The DoD (Department of Defense) requirements regarding accounts and credentials were to be implemented. These requirements are as follows:
* A 60-day maximum password lifetime should be imposed, on both user and application credentials
* Passwords should adhere to a specification of “at a minimum, a case sensitive 8-character mix of upper case letters, lower case letters, numbers, and special characters, including at least one of each.” [1]
* However, as we do not have permissions to change/modify keystone credentials, and also, as the MOC is moving away from Keystone credentials and more towards institution single sign-on, we are not managing accounts and credentials as a part of this project.

### Keys & Encryption:
Encryption and Key Management (which was originally a stretch goal, now a part of the MVP) includes:
* Designing an API to encrypt the objects before uploading them to the bucket, and decrypting before serving to the user.
* Generating keys and storing them.

### Java Workflow:
The end goal of this project is to combine the scripts and processes into a consolidated product, which can be released as a part of CONS3RT. This is envisioned to be built using workflows designed in Java.

## Solution Concept

This section provides a high-level outline of the solution.

__Global Architectural Structure of the Project__

![Architecture](https://github.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/blob/master/Architecture.png "Project Architecture")

Currently CONS3RT’s functionality in an OpenStack environment is limited to setting up the firewall, routing, and networks. The setup of this cloud allocation is completely automated. When created, the cloud allocation can be access by the user and the CONS3RT admins through separate Network Address Translation (NAT) gateways as shown in _Figure 1_. A user can go into their allocation and begin setting up VMs and using it. This project will be centered around implementing object storage, logging, key management and encryption, and other security essentials to secure the cloud allocations. Since CONS3RT is a cloud orchestration platform, the setup of these security standards will be completely automated through scripting.

__Design Implications and Discussion:__

* __Scripting:__ The scripting aspect of the project is flexible, in that the necessity of automation is paramount while the language it is written in is not. We have extensively used Shell scripting to convert all our programs into scripts that would enable automation. These scripts are put up on CONS3RT in the form of software assets. In the final stages of the product, if all key goals are met, the scripts will be converted into Java workflows so that they can be productionalized as a part of CONS3RT.
* __Object Storage:__ Since the MOC is compatible with Ceph storage, the underlying object storage feature is Ceph. We have used the S3 API provided by Ceph for the creation of buckets.
* __Logging:__ For logging we are working with Filebeat and Logstash, two components that belong to the ELK-stack pipeline. Filebeat plays the role of a logging agent — it collects log data from critical log files and forwards the data to Logstash. Logstash, further filters the logs received from Filebeat, and outputs the filtered logs to a file. We are using a cron job to send these filtered logs from the file to our bucket.  
* __Key Management Service:__ We are using Barbican, the OpenStack Key Manager service, for generating and storing keys. We have one key for the log bucket and one for data bucket. Log bucket has a seperate key for security purposes.

## Acceptance Criteria

The minimum viable product for the project involves a system designed in a scripting language that includes automation of:
1. Storage
2. Logging
3. Managing keys and encryption

The stretch goals for the project include:
1. Designing Java Workflows

In addition, we have installed and configured an Intrusion Detection/Prevention System called Fail2Ban, to detect excessive attempts to login in. Further, We intend to identify vulnerabilities in our system, if any, during validation by using the Tenable tool, which is a vulnerability scan tool used to accurately identify, investigate and prioritize vulnerabilities. In CONS3RT, the tenable tool is embedded in the Nessus scan software asset, which we will be adding to our test VM. 

## Release Planning

Note: As automation is paramount in the goal of the project, the project will follow an “automation as we go” model. 
The Sprint taskboards can be found in the following link:
https://tree.taiga.io/project/bowenislandsong-devsecops-secure-cloud-enclaves/taskboard/sprint-1-13885?kanban-status=1539726
1. __Sprint 1: January 31 - Feburary 21__
  * Access the MOC through CONS3RT
  * Begin to verify Tenable as a validation tool
  * Begin to configure object storage
2. __Sprint 2: February 21 - March 7__
 * Learning how to implement secure buckets
    * Creation of Buckets
    * Securing of Buckets
      * Disable Public Read/Write
      * Allow only SSL Requests
      * Object Versioning
 * Using the S3 API to access MOC Ceph
      * Create buckets
      * Enable read/write to buckets
 * Configure console access to our MOC Account   
3. __Sprint 3: March 7 - March 28__
  * Write Scripts to automate Object storage processes
  * Start Logging
    * Configure Logging
      * OS Level Events
      * Services on the VM
      * Object Level Logging
4. __Sprint 4: March 28 - April 11__
  * Enable validation of log files
  * Scripting Configurations
    * Script Logging Configuration and Deployment on a VM
  * Key Management and Encryption
    * Encrypting object at rest
    * Managing keys using Barbican
   
5. __Sprint 5: April 11 - April 25__
 * Finish Key Management and Encryption
 * Finish Scripting and Deploying on the VM
 * Documentation of Project
6. __Final Demo Sprint: April 25 - May 7__
  * Testing of services
    * Validation using tenable
  * Finished product
  * Stretch goals (time permitting)
    * Java workflows
  
  ## Our mentors
* Peter Walsh ([peter.walsh@jackpinetech.com](peter.walsh@jackpinetech.com))
* Joe Yennaco ([joe.yennaco@jackpinetech.com](joe.yennaco@jackpinetech.com))

## Contributors
* Avantika Dasgupta ([avandg@bu.edu](avandg@bu.edu))
* Ethan Mcllhenny ([epm11@bu.edu](epm11@bu.edu))
* Josh Manning ([joshe@bu.edu](joshe@bu.edu))
* Dharmit Dalvi ([dharmit@bu.edu](dharmit@bu.edu))


## Sources and References
===================
1. The application must enforce a 60-day maximum password lifetime restriction., STIG Viewer. (https://www.stigviewer.com/stig/application_security_and_development/2017-01-09/finding/V-69573)
2. What is Volume Encryption. 
(https://www.jetico.com/file-downloads/web_help/bcve3_enterprise/html/01_introduction/02_what_is_ve.htm)
3. Tenable tool 
https://www.tenable.com/products/tenable-io
4. Firewall Isn’t Enough Sources:
(https://www.twistlock.com/2018/05/23/firewalls-role-cloud-native-security/)
(https://www.comtech-networking.com/blog/item/303-a-firewall-isn-t-enough-protecting-yourself-against-the-threats-you-can-t-see/)
(https://www.owasp.org/index.php/Logging_Cheat_Sheet#Introduction)
(https://security.berkeley.edu/security-audit-logging-guideline)
5. Introduction to Logstash
(https://www.elastic.co/guide/en/logstash/current/introduction.html)
6. Working with Filebeat modules
(https://www.elastic.co/guide/en/logstash/current/filebeat-modules.html)
7. MOC Elasticsearch tutorial
(https://docs.massopen.cloud/en/latest/elk/Elasticsearch.html)
