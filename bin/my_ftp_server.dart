
import "dart:io";

import "package:ftp_server/ftp_server.dart";
import "package:ftp_server/server_type.dart";
import "package:postgres/postgres.dart";
Future<void> main(List<String> arguments) async {
  String host = Platform.environment["dbhost"]??"localhost";
  String databaseName = Platform.environment["dbname"]??"myapp";
  String user = Platform.environment["dbuser"]??"postgres";
  String password = Platform.environment["dbpassword"]??"taufiq1729";
  Endpoint endpoint = Endpoint(host: host, database: databaseName,username: user,password: password);
  Pool connPool = Pool.withEndpoints([endpoint],settings: PoolSettings(
    maxConnectionCount: 3,
    sslMode: SslMode.disable
  ));
  String ftpUser = "admin";
  String ftpPass = "admin";
  await connPool.runTx<void>((tx) async {
    var result = await tx.execute(r"SELECT * FROM ftp_server");
    if(result.isEmpty){
      throw Exception("There is no Authenticated Data");
    }
    Map<String,dynamic> authMap = result.first.toColumnMap();
    ftpUser = authMap["username"];
    ftpPass = authMap["password"];
  });

  var sharedDir = "";
  if(Platform.isWindows){
    sharedDir = "shared_dir";
  } else if(Platform.isLinux){
    sharedDir = "/opt/shared_dir/";
  }

  FtpServer ftpServer = FtpServer(
    21, 
    sharedDirectories: [sharedDir],
    serverType: ServerType.readAndWrite,
    username: ftpUser,
    password: ftpPass,
  );

  print("FTP Started in Port 21...");
  await ftpServer.start();
}
