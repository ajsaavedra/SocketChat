# SocketChat
This is an iOS chat application that implements the Socket.IO-client for iOS/OS X. Using Node and Express, the application
allows users to create profiles on the server in order to be able to log in.

Once loggged in, users can chat with other online users, and are also are notified of when others enter and
leave the chatroom. They are also able to see which users are currently online and offline.

Using the [express app's](https://github.com/ajsaavedra/SocketIO-Chat-Node-Express) native api, Alamofire is used to asynchronously query the server in order to perform user validation.
