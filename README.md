# Htpp-zig

A **fast** and simple HTTP 1.1 parser written in zig

This is a port of the Rust [http](https://github.com/Albassel/htpp) crate

# Usage

To parse an HTTP request:

```zig
const req = @constCast("GET / HTTP/1.1\r\n\r\n");

const allocator = testing.allocator;
const parsed = try Request.parse(req, allocator);
defer parsed.deinit();
try std.testing.expect(parsed.method == Method.Get);
try std.testing.expect(std.mem.eql(u8, parsed.path, "/"));
```

To parse an HTTP response:

```zig
let res = b"HTTP/1.1 200 OK\r\n\r\n";

const allocator = testing.allocator;
const parsed = try Response.parse(res, allocator);
defer parsed.deinit();
try std.testing.expect(parsed.status == 200);
try std.testing.expect(std.mem.eql(u8, parsed.reason, "OK"));
```

# Contribution

Feel free to make a pull request if you think you can improve the code
