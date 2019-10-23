import ballerina/config;
import ballerinax/java.jdbc;
import ballerina/log;

public type Student record {
    int std_id;
    string name;
    int age;
    string address;
};

# The `createDbConn` function is attached to the `studentMgtDb` object.
#
# + return - This is the description of the return value of
#            the `createDbConn` function.
public function createDbConn() returns jdbc:Client {
    jdbc:Client studentMgtDb = new ({
        url: "jdbc:mysql://" + config:getAsString("student.jdbc.dbHost") + ":" + config:getAsString("student.jdbc.dbPort") + "/" + config:getAsString("student.jdbc.db"),
        username: config:getAsString("student.jdbc.username"),
        password: config:getAsString("student.jdbc.password"),
        poolOptions: {maximumPoolSize: 5},
        dbOptions: {useSSL: false}
    });
    createTable(studentMgtDb);
    return studentMgtDb;
}

function createTable(jdbc:Client studentMgtDb) {
    log:printInfo("Creating student table if not exists");
    var createTable = studentMgtDb->update("CREATE TABLE IF NOT EXISTS student (std_id INT(11) NOT NULL AUTO_INCREMENT, name VARCHAR(100) NOT NULL, age INT(11) NOT NULL, address VARCHAR(200) NOT NULL, PRIMARY KEY (std_id))");
    handleDbResponse(createTable, "Create student table");
}

function handleDbResponse(jdbc:UpdateResult | jdbc:Error returned, string message) {
    if (returned is jdbc:UpdateResult) {
        log:printInfo(message + " status: " + returned.updatedRowCount.toString());
    } else {
        log:printInfo(message + " failed: " + <string>returned.detail()["message"]);
    }
}


