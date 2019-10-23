import studentHandler as stdHandler;
import ballerina/auth;
import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerinax/java.jdbc;
//import ballerina/docker;

jdbc:Client stdMgtDbConn = stdHandler:createDbConn();
auth:InboundBasicAuthProvider basicAuthProvider = new;
http:BasicAuthHandler basicAuthHandler = new (basicAuthProvider);

//@docker:Expose {}
listener http:Listener studentMgtServiceListener
= new (config:getAsInt("student.listener.port", 9095), config = {
    auth: {
        authHandlers: [basicAuthHandler]
    },
    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: config:getAsString("student.listener.password")
        }
    }
});

//@docker:Config {name: "student-management", tag: "v1.0"}

@http:ServiceConfig {
    basePath: "/students",
    auth: {
        scopes: ["scope1"]
    }
}

service studentMgtService on studentMgtServiceListener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/",
        auth: {
            scopes: ["scope2"]
        }
    }
    resource function getAllStudents(http:Caller caller, http:Request req) {
        worker worker1 {
            log:printInfo("Parallel Process - worker1 Started -> Select all students from db");
            var selectStudents = stdMgtDbConn->select("SELECT * FROM student", stdHandler:Student);
            stdHandler:handleSelect(selectStudents, caller, "Get All Students ", true);
            log:printInfo("Parallel Process - worker1 Ended");
        }
        worker worker2 {
            log:printInfo("Parallel Process - worker2 Started");
            //Can do some parallel work
            log:printInfo("Parallel Process - worker2 Ended");
        }
        _ = wait {worker1, worker2};
        log:printInfo("Parallel Process Ended");
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/{std_id}",
        auth: {
            enabled: false
        }
    }

    resource function getStudentDataById(http:Caller caller, http:Request req, string std_id) {
        log:printInfo("The select operation - Get student Data by Id " + std_id);
        jdbc:Parameter paramStdId = {sqlType: "INTEGER", value: std_id};
        var studentData = stdMgtDbConn->select("SELECT * FROM student where std_id = ?", stdHandler:Student, paramStdId);
        stdHandler:handleSelect(studentData, caller, "Get Student by id " + <@untainted>std_id, true);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/",
        body: "std",
        consumes: ["application/json"]
    }

    resource function addStudent(http:Caller caller, http:Request req, stdHandler:Student std) {
        log:printInfo("The Insert operation - Insert student to db");

        var addStudents = stdMgtDbConn->update("INSERT INTO student(std_id, name, age, address) VALUES (?, ?, ?, ?)", std.std_id, std.name, std.age, std.address);
        stdHandler:handleUpdate(addStudents, caller, "Add Student", true);
    }

    //Delete resource needs auth user with both scope1 and scope2
    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/{std_id}",
        auth: {
            scopes: [["scope1"], ["scope2"]]
        }
    }

    resource function deleteStudent(http:Caller caller, http:Request req, string std_id) {
        log:printInfo("The Delete operation - Delete student with std_id " + std_id);
        var deleteStudents = stdMgtDbConn->update("DELETE FROM student WHERE std_id = ?", std_id);
        stdHandler:handleUpdate(deleteStudents, caller, "Delete Student", true);
    }
}
