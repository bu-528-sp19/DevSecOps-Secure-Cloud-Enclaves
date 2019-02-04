# DevSecOps-Secure-Cloud-Enclaves
## Vision and Goals

As the workplace evolves, so must security for such an environment. Today we live in the cloud-native and container security era, with IT professionals having to understand Docker, Kubernetes, serverless computing, and much more. This age of increasingly sophisticated systems has resulted in more complex cyber-attacks, and the legacy firewalls can’t keep up anymore. Resources that can be entirely firewalled off from the world are becoming rarer everyday.  Even on-prem infrastructures for internal applications has to connect to an outside resource at some point (backups, S3 storage, etc).

It is also no longer so simple to just restrict all external traffic using a firewall; IT departments cannot simply have a whitelist, as everything is dynamic now. For example, consider the remote employee trying to connect from their home PC,tablet, or even an IoT device. All these have non-static IP addresses, so the whitelist would have to be updated constantly. With multiple endpoints now to consider, the surface area for malicious activity has increased immensely. 

With this, new methods have to be implemented within one’s infrastructure to ensure security.  Among these methods are logging, or event event entries which capture information related to a specific event that occurred which imaced a certain device.   These should include critical events such as starting and stopping a system or service, any and all attempted log-ins, system security settings, account changes (user or application based), and much more.  These extensive logs could capture a timestamp, the user/system/device tied to the event, etc.  This information keeps track of important transactions, so that any attackers actions may be logged, such that post attack investigations can deduce what went wrong. 

Naturally, with such a wealth of information, any malicious actor would want to go after such logs, so as to hide their actions.  To prevent this, audit logs are kept under strong access control to limit the amount of users who may modify such vital resources.  It would also be reasonable to ensure that even if the attacker managed to access the logs in some way, that they wouldn’t be of value to them; this is usually done through encryption..

Setting up such an environment, with all of these features to ensure security, would intuitively take many hours of labor on the departments responsible. With this in mind, DevSecOps will provide an automated approach to ensure a secure cloud enclave.  Specifically, we will use CONS3RT, a leading-edge cloud and security orchestration service, to implement governance and industry standards when it comes to security.  This will include such vital aspects such as logging and identity access management.

## Users/Personas Of The Project
The users of the project would be:
* __Mission owner__- Admin to the project system from the customer’s side, who would control access and security of other customer users. The mission owner would control the customer user access levels.
* __General users__- People with access to the data involved with the project.
* __Support users__- Users from Jackpine technologies organization, who would control the updates and maintenance of the CONS3RT software. 
* __MOC (Massachusetts Open Cloud) admin__ - MOC admin would provide resources required for the project and would allocate space for the project over the MOC.
* __Open source developers’ community__ - Since the project is open source, open source developers can contribute to it to enhance the features of the project and to add more functionalities to it.
* __Regulatory agencies__- Agencies that oversee, audit and accredit service providers.

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
Object storage and its security and logging components will be designed as follows:
* Storage will be implemented in the form of buckets that can house any number of objects
* A dedicated bucket will be used to store logs
* Only SSL requests will be allowed on the buckets
* Public read/write will be disabled on the buckets
* Versioning will be enabled on the buckets, which implies that:
  * Previous versions of objects can be restored
  * Deleted objects can be restored
* Logging will be enabled on the buckets, which implies that:
  * Object level logging will monitor and record the operations carried out on objects within a bucket
  * Server access logging will monitor and record the requests that are made to a bucket
* All traffic and management events in the cloudspace will be logged
* Log file validation will be enabled

### Accounts & Credentials:
The DoD (Department of Defense) requirements regarding accounts and credentials will be implemented. These requirements are as follows:
* A 60-day maximum password lifetime will be imposed, on both user and application credentials
* Passwords will adhere to a specification of “at a minimum, a case sensitive 8-character mix of upper case letters, lower case letters, numbers, and special characters, including at least one of each.” [1]

### Keys & Encryption:
Encryption and Key Management is a stretch goal that includes:
* Enabling encryption on object storage buckets, which implies that:
  * All objects will be encrypted when they are stored in the buckets
* Encrypting volumes (combination of multiple partitions into a single logical unit of storage) [2]
* Rotation of access keys (Still needs to verified whether applicable on MOC)

### Java Workflow:
The end goal of this project is to combine the scripts and processes into a consolidated product, which can be released as a part of CONS3RT. This is envisioned to be built using workflows designed in Java.

## Solution Concept

This section provides a high-level outline of the solution.

__Global Architectural Structure of the Project__

![Architecture](https://github.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/blob/master/Architecture.png "Project Architecture")

Currently CONS3RT’s functionality in an OpenStack environment is limited to setting up the firewall, routing, and networks. The setup of this cloud allocation is completely automated. When created, the cloud allocation can be access by the user and the CONS3RT admins through separate Network Address Translation (NAT) gateways as shown in _Figure 1_. A user can go into their allocation and begin setting up VMs and using it. This project will be centered around implementing object storage, logging, key management and encryption, and other security essentials to secure the cloud allocations. Since CONS3RT is a cloud orchestration platform, the setup of these security standards will be completely automated through scripting.

__Design Implications and Discussion:__

* __Scripting:__ The scripting aspect of the project is flexible, in that the necessity of automation is paramount while the language it is written in is not. Most likely the scripting will be done in either Python, bash, or powershell. In the final stages of the product, if all key goals are met, the scripts will be converted into Java workflows so that they can be productionalized as a part of CONS3RT.
* __Object Storage:__ To include an object storage feature, the OpenStack Swift Object Storage API will be used. This platform is already built to function in an OpenStack environment. The platform is also flexible in that it allows scripting in a variety of programming languages. In addition, it offers object encryption and versioning which are among our security standards. Another consideration was GlusterFS, but the OpenStack Object storage API seemed the better option for ease of use and capability.
* __Logging:__ For logging the two main considerations were FluentD and Logstash. Logstash is easier to configure and procedural in nature, but needs to be deployed along with another caching tool, Redis, to ensure reliability. As the main focus of the project is reliable security, the better option is thus FluentD, which is the more reliable logging platform but initially harder to configure.
* __Accounts and Credentials:__ The rotation and changing of accounts and credentials, as well as controlling access to various functions in the cloud allocation will be done using both functionality from the CONS3RT service and the OpenStack Keystone Identity API.
* __Key Management Service:__ OpenStack has some suggested software to deal with encryption and key management. Barbican, the OpenStack Key Manager service, will be used for volume encryption by generating and storing keys. An open-source Key Management Interoperability Protocol, PyKMIP library, to define message formats for the manipulation of keys.

## Acceptance Criteria

The minimum viable product for the project involves a system designed in a scripting language that includes automation of:
1. Storage
2. Logging
3. Managing accounts and credentials

The stretch goals for the project include:
1. Managing keys and encryption
2. Designing Java Workflows

Further, we intend to identify vulnerabilities in our system, if any, during validation by using the Tenable tool, which is a vulnerability scan tool used to accurately identify, investigate and prioritize vulnerabilities.

## Release Planning

Note: As automation is paramount in the goal of the project, the project will follow an “automation as we go” model. 

1. __Sprint 1: February 4 - 14__
  * Access the MOC through CONS3RT
  * Begin to verify Tenable as a validation tool
  * Begin to configure object storage
2. __Sprint 2: February 15 - 28__
 * Finish Object Storage
    * Creation of Buckets
    * Securing of Buckets
      * Disable Public Read/Write
      * Allow only SSL Requests
      * Object Versioning
3. __Sprint 3: March 1 - 21__
  * Start Logging
    * Create dedicated bucket for logs
    * Enable object level and server access logging
4. __Sprint 4: March 22 - April 4__
  * Finish Logging
    * Enable validation of log files
  * Accounts and Credentials
    * 60-Day password rotation
    * Enforcing password specifications
5. __Sprint 5: April 5 - 18__
  * Testing of services
    * Validation using tenable
 * Documentation of Project
6. __Final Demo Sprint: April 19 - May 7__
  * Finished product
  * Stretch goals (time permitting)

## Sources and References
===================
1. The application must enforce a 60-day maximum password lifetime restriction., STIG Viewer. (https://www.stigviewer.com/stig/application_security_and_development/2017-01-09/finding/V-69573)
2. What is Volume Encryption. 
(https://www.jetico.com/file-downloads/web_help/bcve3_enterprise/html/01_introduction/02_what_is_ve.htm)
3. Tenable tool 
https://www.tenable.com/products/tenable-io
4. Firewall Isn’t Enough Sources
https://www.twistlock.com/2018/05/23/firewalls-role-cloud-native-security/
https://www.comtech-networking.com/blog/item/303-a-firewall-isn-t-enough-protecting-yourself-against-the-threats-you-can-t-see/
https://www.owasp.org/index.php/Logging_Cheat_Sheet#Introduction
https://security.berkeley.edu/security-audit-logging-guideline
