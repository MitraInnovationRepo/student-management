import studentHandler as stdHandler;
import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerinax/java.jdbc;
jdbc:Client stdMgtDbConn = stdHandler:createDbConn();
//listener http:Listener studentMgtServiceListener = new (config:getAsInt("student.listener.port"));
listener http:Listener studentMgtServiceListener
    = new(config:getAsInt("student.listener.port", 9095), config = {
        secureSocket: {
            keyStore: {
                path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
                password: config:getAsString("student.listener.password")
            }
        }
});

@http:ServiceConfig {
    basePath: "/students"
}

service studentMgtService on studentMgtServiceListener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    resource function getAllStudents(http:Caller caller, http:Request req) {
        io:println("\nThe select operation - Select students from db");
        var selectStudents = stdMgtDbConn->select("SELECT * FROM student", stdHandler:Student);
        stdHandler:handleSelect(selectStudents, caller, "Get All Students ", true);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/{std_id}"
    }
    resource function getStudentDataById(http:Caller caller, http:Request req, string std_id) {
        io:println("\nThe select operation - Get student Data by Id " + std_id);
        jdbc:Parameter paramStdId = {sqlType: "INTEGER", value:std_id};
        var studentData = stdMgtDbConn->select("SELECT * FROM student where std_id = ?", stdHandler:Student, paramStdId);
        stdHandler:handleSelect(studentData, caller, "Get Student by id " + <@untainted> std_id, true);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/",
        body: "std",
        consumes: ["application/json"]
    }

    resource function addStudent(http:Caller caller, http:Request req, stdHandler:Student std) {
        io:println("\nThe Insert operation - Insert students to db");

        int sId = std.std_id;
        var sName = std.name;
        int sAge = std.age;
        var sAddress = std.address;

        var addStudents = stdMgtDbConn->update("INSERT INTO student(std_id, name, age, address) VALUES (?, ?, ?, ?)", sId, sName, sAge, sAddress);
        stdHandler:handleUpdate(addStudents, caller, "Add Student", true);
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/{std_id}"
    }

    resource function deleteStudent(http:Caller caller, http:Request req, string std_id) {
        io:println("\nThe Delete operation - Delete student with std_id " + std_id);
        var deleteStudents = stdMgtDbConn->update("DELETE FROM student WHERE std_id = ?", std_id);
        stdHandler:handleUpdate(deleteStudents, caller, "Delete Student", true);
    }
}
