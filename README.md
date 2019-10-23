# student-management (Ballerina V 1.0)

## Purpose
This is a use case of student-management service which is implemented using Ballerina V 1.0 with following resources.
1) Get all students [GET /students]
2) Add Student via json body [POST /students]
3) Delete Student by student Id [DELETE /students/{id}]
4) Get student details by student Id [GET /students/{id}]

Use Case mainly covers;
* Service implementation with CRUD operations
* Response and Error Handling
* Get values through config file
* Parallel processes
* Work with multiple modules
* Security features :
    * Handle tainted values
    * Use of keyStore (service protocol as HTTPS)
    * Encrypt passwords
    * Use of Basic Authentication
* Deploy through docker image

## Running Locally
### Get Repo
Clone project:
`git clone --recursive https://github.com/MitraInnovationRepo/student-management.git`

### Build the project
`ballerina build studentService`
This will Compile the source and create a excecutable .jar file in the target/bin directory.

### Run project
Since we are using values from config file and an entrypted value for the keystore password, its need to mention --b7a.config.file and --b7a.config.secret with the run cmd,

`ballerina run ./target/bin/studentService.jar --b7a.config.file=./config/studentConf.toml --b7a.config.secret=./config/secret.txt`

You can notice this will delete ./config/secret.txt file when service up.
When you are going to run the project at next time either you can add ./config/secret.txt file and give above command or else just run without --b7a.config.secret like below.

`ballerina run .\target\bin\studentService.jar --b7a.config.file=./config/studentConf.toml`

This will ask user input for decryption.

    ballerina: enter secret for config value decryption:
In this scenario we have used 1234 as the encrypt value. So give it as the input.