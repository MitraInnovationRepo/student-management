import ballerinax/java.jdbc;
import ballerina/http;
import ballerina/io;
import ballerina/jsonutils;

# Description
#
# + returned - returned Parameter Description 
# + caller - caller Parameter Description 
# + message - message Parameter Description 
# + isRespond - isRespond Parameter Description
public function handleUpdate(jdbc:UpdateResult | error returned, http:Caller caller, string message, boolean isRespond) {

    if (returned is jdbc:UpdateResult) {
        io:println(message, " status: ", returned.updatedRowCount);
        if (isRespond) {
            sendResponse(caller, message + " Successful", 200);
        }
    } else {
        error err = returned;
        io:println(message, " failed: ", <string>err.detail()["message"]);
        if (isRespond) {
            sendResponse(caller, "Unable to " + message, 500);
        }
    }
}

public function handleSelect(table<Student> | error returned, http:Caller caller, string message, boolean isRespond) {
    if (returned is table<Student>) {
        if (isRespond) {
            json jsonConversionRet = jsonutils:fromTable(returned);
            sendResponse(caller, jsonConversionRet, 200);
        }
    } else {
        error err = returned;
        io:println(message, " failed: ", <string>err.detail()["message"]);
        if (isRespond) {
            sendResponse(caller, "Unable to " + message, 500);
        }
    }
}

public function sendResponse(http:Caller caller, string | json payloadMsg, int statusCode) {
    http:Response response = new;
    response.setPayload(payloadMsg);
    response.statusCode = statusCode;
    checkpanic caller->respond(response);
}
