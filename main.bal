import ballerina/ftp;
import ballerina/io;
import ballerina/log;

// Creates the listener with the connection parameters and the protocol-related
// configuration. The listener listens to the files
// with the given file name pattern located in the specified path.
listener ftp:Listener fileListener = new ({
    protocol: ftp:SFTP,
    host: "eu-west-1.sftpcloud.io",
    auth: {
        credentials: {
            username: "6c04313f0dad43a190340bdad0789fce",
            password: "zYMAqOzzB6rdSqIHqyuIcSHIbsD7uzLN"
        }
    },
    port: 22,
    path: "/test-dir",
    fileNamePattern: "(.*).txt"
});

// One or many services can listen to the SFTP listener for the
// periodically-polled file related events.
service on fileListener {

    // When a file event is successfully received, the `onFileChange` method is called.
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        log:printInfo("File change event received.");
        // `addedFiles` contains the paths of the newly-added files/directories
        // after the last polling was called.
        foreach ftp:FileInfo addedFile in event.addedFiles {
            // Get the newly added file from the SFTP server as a `byte[]` stream.
            stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);

            // Write the content to a file.
            check io:fileWriteBlocksFromStream(string `./local/${addedFile.name}`, fileStream);
            check fileStream.close();
        }
    }
}
