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

## Documentation
### Setting up our system

Four scripts are used in the setup of our secure VMs. They are designed for a CentOS 7 operating system, but should be transferable to any Linux OS. In Github, they are designated by `MasterScript_XXX.sh`. The steps for setup are easy in CONS3RT as all you have to do is upload the scripts as software assets, and add them to your system using the CONS3RT UI. Standing them up on your own is a little more challenging. The steps are as follows:

1. Download `MasterScript_EnvironmentVars_TEMPLATE.sh`. Save it as `MasterScript_EnvironmentVars.sh` on your computer.
2. In `MasterScript_EnvironmentVars.sh`, some of the data in the template needs to be replaced with your own keystone credentials and passwords. Any field that says /*PROJECT*/, /*USERNAME*/, or /*PASSWORD*/ needs to be replaced with the Openstack project name, keystone username, and keystone password, respectively. These are located on lines `31`, `32`, `70`, `71`, `72`, `80`, `81`, and `82`.
3. Finally in `MasterScript_EnvironmentVars.sh`, on lines 48 and 49, /*ACCESS KEY*/ and /*SECRET KEY*/ must be replaced with the projects EC2 access key and secret key. These can be obtained on the MOC Dashboard via the API Access tab.
4. Startup a brand new CentOS 7 VM
5. Change the password to the root user (`sudo passwd root`)
6. Log into the root user (`su -l root`)
1. This step is optional, but for organization, it is helpful to create a folder /scripts to hold all of the scripts you must run (`mkdir /scripts`)
1. Create a file `setup.sh` (`vi setup.sh`)
1. While in VI, copy the `MasterScript_EnvironmentVars.sh` text into this file. Make sure that the first line is correctly a comment, sometimes copying goes wrong.
1. Exit VI
1. Download the remaining scripts from our Github repo
    1. The command is : ```curl -O https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/XXX```
    1. The XXX at the end should be the three files
        1. `MasterScript_Install.sh`
        1. `MasterScript_Config.sh`
        1. `MasterScript_Launch.sh`
1. Run the command: `sed -i 's/\r$//' setup.sh`
1. This will resolve issues when converting the script to Linux
1. Run the `setup.sh` script (`bash setup.sh`)
1. Reboot the VM
1. Log back in, and then into the root user. Navigate back to the directory with the scripts in it.
1. Repeat steps 12-15 with the three other scripts, making sure to change the name where appropriate in the steps. __DO NOT REBOOT AFTER RUNNING `MasterScript_Launch.sh`__. The general order of installation is:                    
    1. `MasterScript_Install.sh`
    1. Reboot
    1. `MasterScript_Config.sh`
    1. Reboot
    1. `MasterScript_Launch.sh`
1. Now everything is running! What can you do…
    1. The command (```bash /media/StartAPI.sh```) will open up our interactive Object storage API to store your data securely within CEPH Object storage. Details on interacting with the API itself will be listed below.
    1. To interact with openstack on the root user
       * If you left the ```clouds.yaml``` file intact and only changed the passwords not the overall name of the clouds, moc_old and moc_new
        * The command (```openstack --os-cloud moc_old --os-auth-url https://kaizenold.massopen.cloud:5000```) will open up a terminal interface for the Openstack CLI to interact with your project on Kaizen Old
        * The command (```openstack --os-cloud moc_new --os-identity-api-version 3```) will open up a terminal interface for the Openstack CLI to interact with your project on New Kaizen
    1. Everything else is implemented in the background and will be detailed below.

### The Scripts
All of the scripts have logging functions built-in and will log error and info messages to a directory ```/var/log/cons3rt```. Each of the scripts is split into functions which are detailed below.

#### MasterScript_EnvironmentVars.sh
* `add_environment_vars()`:
    * Adds environment variables to be sourced upon login of the various users
        *    Without actual MOC admin privileges, we are assuming the root user will mimic this role; thus, the root user has access to the project name, and keystone credentials to access the MOC interface.
        *    A general user on the VM will not have such access, except through the CONS3RT UI. However, they will be able to store data; thus, they have access to the object storage access key and secret key.
* `create_clouds()`:
    *    Adds the openstack CLI configuration file, clouds.yaml
    *    Two clouds are created in the template, moc_old and moc_new as, we used both a Kaizen old and new account at certain points in the project. If you only need one account access you can remove one of the sections. Both clouds are configured using “operation_log” to log all events that are done in the CLI. This is to mimic configurations that could be made if we had access to the MOC backend.
#### MasterScript_Install.sh
*    `install_dependencies()`:
        *    installs all dependencies needed to run the various services we have stood up on the VM as well as the services themselves
*    `get_scripts()`:
        *    Downloads all relevant scripts from our Github repo and restrict permissions
        * Create simple files that are only a few lines of code manually
        * Create logging directory for Object Storage API
        * These scripts are securely stored in the `/code` directory which can only be modified by the root user
* ```gen_keys()```:
    * Generate a keystone token
    * Uses the keystone token and Barbican to generate keys for the object storage and log storage buckets
    * The keys as well as the initial keystone token are stored in the `/inf` directory which is also limited to root modification
* ```set_up_bucket()```:
    * Creates dedicated bucket to store logs using the `/code/Create_Log_Bucket.py` script
    * This bucket is named `log_bucket`
#### MasterScript_Config.sh
* ``filebeat_config()``:
    * Downloads filebeat configuration file from Github to correct directory
* ``logstash_config()``:
    * Downloads logstash configuration file from Github to correct directory
* ```fail2ban_config()```:
    * Configures fail2ban by creating necessary files
* ```cron_config()```:
    * Creates a crontab to send logs to the secure buckets every hour
* ```openstack_config()```:
    * Moves the clouds.yaml file to the `/etc/openstack directory` and sets permissions
#### MasterScript_Launch.sh
* Uses functions to start Filebeat, logstash, and fail2ban on the VM
    * ```start_filebeat()```
    * ```start_logstash()```
    * ```start_fail2ban()```


### The Object Storage API and Encryption

#### Object Storage Features

We have implemented the following security features for Ceph S3 buckets:
* Allowing only SSL requests
* Versioning objects in the buckets
* Generating logs for all bucket events
* Encrypting the objects stored in buckets

To ensure that users do not need to enable any of these features manually we have built an object storage API with an interactive CLI in Python.
#### How to Use the API
1. To start the API, run the command `bash /media/StartAPI.sh`. The API code itself is in `/code/ObjectStorageAPI.py`
2. The API will prompt the user to continue by entering (Y or N) at the beginning each transaction
3. The API will print all the options available to a user. The numbered list of available features are:
    1. List buckets
    2. Create bucket 
    3. Delete bucket
    4. List bucket versions
    5. Upload to bucket
    6. Download from bucket
    7. Delete from bucket
4. The general inputs that could be asked upon entering one of the given numbers are:
    * Key --> Name of the file that will be stored/is stored in the bucket
    * Path --> Path to the file that will be uploaded/where to be downloaded on the VM
    * Bucket --> Name of bucket to be operated on
        * All available buckets can be seen using the `List Buckets ` feature
        * Users other than the root cannot access the log bucket
            * The root can use `/code/download_logs.py` to download a given log file by entering the date of the file they want to download or all log files
 

#### Encryption
* `pyAesCrypt`:
    * Used to encrypt files (chunk by chunk)
* `Barbican`:
    * Used as a key management service (OpenStack's implementation)
    * Stores encryption keys remotely
* Encryption takes keys off of Barbican and uses the encryption method to encrypt files before being sent to the bucket
* Encrypted file is then pushed to the bucket encrypted
* By default, SSL/TLS is enabled 

### Logging Architecture
We have stood up the logging architecture as below:

The logging architecture follows this process:
1. Hosted services and OS specific events write their logs to /var/log on a linux machine
2. Filebeat collects the logs that are specified in its config file
    1. This configuration file is located at `/etc/filebeat/filebeat.yml`
    2. The logs we are collecting are defined in the input section of `filebeat.yml`
        * Hosted Services
        * Messages --> general VM activity
        * Secure --> logins, authentication
        * Bucket events
        * Openstack events
        * Startup Logs
    3. This is done using regular expressions and static casts of unchanging log directories
3. Filbeat forwards the logs to Logstash
    1. This is defined in the output section of `filebeat.yml`
5. Logstash recieves the logs from filebeat as an input
    1. This is defined in the inputs section of `/etc/logstash/conf.d/logstash.conf`
6. Logstash filters the logs removing any unecessary default tags
    1. This filter is defined in the filter section of `logstash.conf`
7. Logstash outputs the filtered logs to `/store_log` a secure folder on the VM
    1. This output is defined in the output section of `logstash.conf`
8. A cron job runs every hour, writing the logs to our secure bucket named `log_bucket` that was created on startup of the VM
    1. This cron job runs a script `/code/cron.sh` which sources neccessary environment variables for cron and then calls `/code/write_logs.py` to write the logs


### Fail2ban
Fail2ban is an Intrusion detection/protection system (IDS/IPS). It scans for brute force login attempts in real-time and bans the attackers. Blocks the IP addresses which show signs of brute force attacks or dictionary attacks. This program works in the background and continuously scans the log files for unusual login patterns and security breach attempts. 
We have set up Fail2ban through our automation scripts- `MasterScript_Install.sh`, `MasterScript_Config.sh` and `MasterScript_Launch.sh`.

Setting up Fail2ban involves the following steps:
1. Installing dependencies such as EPEL (which is covered in the `MasterScript_Install.sh` file)
2. Installing fail2ban (which is covered in the `MasterScript_Install.sh` file)
3. Configure settings for Fail2Ban (which is covered in the `MasterScript_Config.sh` file)
    * The configuration file is located at `/etc/fail2ban/jail.d/ssh.local` 
4. Run Fail2ban service (which is covered in the `MasterScript_Launch.sh` file)

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
