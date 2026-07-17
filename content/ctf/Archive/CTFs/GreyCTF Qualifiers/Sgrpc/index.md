---
draft: "true"
---


![[Pasted image 20250531104132.png]]

When I open the page, I momentarily see some body text before the connection is reset.

![[Pasted image 20250531104240.png]]

If we try to curl, we get `Received HTTP/0.9 when not allowed`. We may need to modify our request to meet certain conditions for the server to accept it.

This is a very old version of HTTP, and curl doesn't accept response from it by default, so we have to specify the `--http0.9` and `--output -` options.

![[Pasted image 20250531105512.png]]

This shows we're now able to initiate the connection, but the server still resets it.

If I try to interact with it using netcat I don't receive any further response though.

![[Pasted image 20250531105919.png]]

To get some confirmation of what protocol we're dealing with, I'll run an nmap scan (which I should have done to start with):
`nmap -sV -p33202 challs.nusgreyhats.org`

```
PORT      STATE SERVICE VERSION
33202/tcp open  grpc
```

As the challenge title would suggest, it turns out this is gRPC! I've only heard of gRPC, never interacted with it, so this will be a new experience for me. I do know that gRPC usesa binary format to communicate, instead of ASCII like HTTP, so it can be trickier to interact with in an ad hoc setting.

However we do have tools like [grpcurl](https://github.com/fullstorydev/grpcurl) which will hopefully make this easier. Following the usage instructions from its Github readme, I'll pull the container image using Docker...

`docker pull fullstorydev/grpcurl:latest`

... and run it against the target:
`docker run fullstorydev/grpcurl -plaintext challs.nusgreyhats.org:33202 list`

```
Failed to list services: rpc error: code = PermissionDenied desc = This reflection method is disabled
```

# Source Code Analysis
At this point it felt like a good time to look at the source code, since I hadn't yet...

## main.go
```
import (
	"context"
	"flag"
	"github.com/google/go-cmp/cmp"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection/grpc_reflection_v1"
	"google.golang.org/protobuf/types/known/emptypb"
	"log"
	"net"
	"os"

	pb "ctf.nusgreyhats.org/sgrpc/flag"
)
```

Immediately in the imports we see that the flag is imported as a protobuf (pb) to avoid leaking it in this source code.

```
func (s *server) Hello(_ context.Context, _ *emptypb.Empty) (*pb.HelloReply, error) {
	reply := "Hello from QuanYang"
	return &pb.HelloReply{Message: &reply}, nil
}

func (s *server) GetFlag(_ context.Context, in *pb.FlagRequest) (*pb.FlagReply, error) {
	flagValue := os.Getenv("FLAG")
	unauthorized := "unauthorized"
	if in.GetFirstCondition() != <redacted> || !cmp.Equal(in.GetSecondCondition(), <redacted>) || in.GetLastCondition() != <redacted> {
		return &pb.FlagReply{Flag: &unauthorized}, nil
	}
	return &pb.FlagReply{Flag: &flagValue}, nil
}
```

We see that we should be able to reach the hello route to get the message "Hello from QuanYang".



## customreflect.go





```
syntax = "proto3";

package flag;

import "google/protobuf/empty.proto";

service Flag {
  rpc Hello(google.protobuf.Empty) returns (HelloReply);
  rpc GetFlag(FlagRequest) returns (FlagReply);
}

message HelloReply {
  string message = 1;
}

message FlagRequest {
  string first_condition = 1;
  bytes second_condition = 2;
  string last_condition = 3;
}

message FlagReply {
  string flag = 1;
}
```

```
docker run -v "$PWD:/work" -w /work fullstorydev/grpcurl \
  -plaintext \
  -import-path . \
  -proto flag.proto \
  -d '{}' \
  challs.nusgreyhats.org:33202 flag.Flag/Hello
```

returns:
```
{
  "message": "Hello from QuanYang"
}
```
