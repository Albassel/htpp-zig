const std = @import("std");
const testing = std.testing;

const SPACE = 32;
const CR = 13;
const LF = 10;
const COLON = 58;
const HTAB = 9;

const numberChar = [_]u8{ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 };
const alphaChar = [_]u8{ 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122 };

fn byteMap(comptime map: [256]u1) [256]bool {
    var bool_map: [256]bool = undefined;
    for (map, 0..) |val, idx| {
        bool_map[idx] = (val != 0);
    }
    return bool_map;
}

const URL_SAFE = byteMap([_]u1{
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    //  \w !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
    0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    //  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1,
    //  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    //  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    //  `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    //  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~  del
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    //   ====== Extended ASCII  ======
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
});

const HEADER_NAME_SAFE = byteMap([_]u1{
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    //  \w !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0,
    //  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    //  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
    0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    //  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1,
    //  `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
    0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    //  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~  del
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
});

const ParseErr = error{
    /// The request is malformed and doesn't adhere to the standard Malformed
    Malformed,
};

const HttpVer = enum {
    /// Http 1.1
    One,
    /// Http 2.0
    Two,
};

// ---------------------
// Parsing HTTP headers
// ---------------------

/// An HTTP header
pub const Header = struct {
    name: []u8,
    val: []u8,

    /// Create a new HTTP header with the given name and value
    pub fn new(name: []u8, val: []u8) Header {
        return Header{ .name = name, .val = val };
    }
};

// Parses the headers with the empty line after them
fn parseHeaders(slice: []u8, alloc: std.mem.Allocator) anyerror!struct { headers: std.ArrayList(Header), read: usize } {
    var headers = std.ArrayList(Header).init(alloc);
    var offset: usize = 0;
    while (!std.mem.eql(u8, slice[offset..(offset + 2)], "\r\n")) {
        const name = try parseHeaderName(slice[offset..]);
        offset += name.read;
        const val = try parseHeaderValue(slice[offset..]);
        offset += val.read;
        try headers.append(Header.new(name.name, val.val));
    }
    return .{ .headers = headers, .read = (offset + 2) };
}

// parses the header name and removes the `:` character and any spaces after it
fn parseHeaderName(slice: []u8) ParseErr!struct { name: []u8, read: usize } {
    for (slice, 0..) |char, counter| {
        if (HEADER_NAME_SAFE[char]) {
            continue;
        } else if (char == COLON) {
            const name = slice[0..counter];
            if (slice[counter + 1] == SPACE or slice[counter + 1] == 9) {
                return .{ .name = name, .read = (counter + 2) };
            }
            return .{ .name = name, .read = (counter + 1) };
        }
        return ParseErr.Malformed;
    }
    unreachable;
}

fn parseHeaderValue(slice: []u8) ParseErr!struct { val: []u8, read: usize } {
    for (slice, 0..) |char, counter| {
        if (char == CR) {
            const val = slice[0..counter];
            if (slice[counter + 1] == LF) {
                return .{ .val = val, .read = (counter + 2) };
            }
            return ParseErr.Malformed;
        }
    }
    return ParseErr.Malformed;
}

// ---------------------
// Parsing HTTP requests
// ---------------------

/// The http method of a request. Only GET, POST, and PUT are supported
pub const Method = enum {
    /// The http GET method
    Get,
    /// The http POST method
    Post,
    /// The http PUT method
    Put,

    fn as_str(self: Method) []const u8 {
        if (self == Method.Get) {
            return "GET";
        } else if (self == Method.Post) {
            return "POST";
        } else {
            return "PUT";
        }
    }
};

pub const Request = struct {
    method: Method,
    path: []u8,
    headers: std.ArrayList(Header),
    body: []u8,

    /// Construct a new Response from its parts
    /// Use an empty `&str` to create a `Respose` with no body
    pub fn new(method: Method, path: []u8, headers: std.ArrayList(Header), body: []u8) Request {
        return Request{ .method = method, .path = path, .headers = headers, .body = body };
    }

    /// The byte representation of the Request transmittible over wire
    pub fn bytes(self: Request, alloc: std.mem.Allocator) std.ArrayList(u8) {
        var bytesVec = std.ArrayList(u8).init(alloc);
        bytesVec.writer().print("{s} {s} HTTP/1.1\r\n", .{ self.method.as_str(), self.path }) catch unreachable;
        for (self.headers.items) |header| {
            bytesVec.appendSlice(header.name) catch unreachable;
            bytesVec.appendSlice(": ") catch unreachable;
            bytesVec.appendSlice(header.val) catch unreachable;
            bytesVec.appendSlice("\r\n") catch unreachable;
        }
        bytesVec.appendSlice("\r\n") catch unreachable;
        bytesVec.appendSlice(self.body) catch unreachable;
        return bytesVec;
    }

    pub fn parse(slice: []u8, alloc: std.mem.Allocator) anyerror!Request {
        if (slice.len < 14) {
            return ParseErr.Malformed;
        }
        var offset: usize = 0;
        const method = try parseMethod(slice);
        offset += method.read;
        const path = try parsePath(slice[offset..]);
        offset += path.read;
        if (slice[offset..].len < 10) {
            return ParseErr.Malformed;
        }
        _ = try Request.parseHttpVersion(slice[offset..]);
        offset += 10;
        const headers = try parseHeaders(slice[offset..], alloc);
        offset += headers.read;
        return Request.new(method.method, path.path, headers.headers, slice[offset..]);
    }

    pub fn deinit(self: Request) void {
        self.headers.deinit();
    }

    //removes the \r\n after
    fn parseHttpVersion(slice: []u8) ParseErr!HttpVer {
        if (std.mem.eql(u8, slice[0..10], "HTTP/1.1\r\n")) {
            return HttpVer.One;
        } else if (std.mem.eql(u8, slice[0..10], "HTTP/2.0\r\n")) {
            return HttpVer.Two;
        } else {
            return ParseErr.Malformed;
        }
    }
};

//parses the method and removes white space after it
fn parseMethod(slice: []u8) ParseErr!struct { method: Method, read: usize } {
    if (std.mem.eql(u8, slice[0..4], "GET ")) {
        return .{ .method = Method.Get, .read = 4 };
    } else if (std.mem.eql(u8, slice[0..5], "POST ")) {
        return .{ .method = Method.Post, .read = 5 };
    } else if (std.mem.eql(u8, slice[0..4], "PUT ")) {
        return .{ .method = Method.Put, .read = 4 };
    }
    return ParseErr.Malformed;
}

// parses the path and removes the space after making sure it only contains URL safe characters
fn parsePath(slice: []u8) ParseErr!struct { path: []u8, read: usize } {
    for (slice, 0..) |char, counter| {
        if (URL_SAFE[char]) {
            continue;
        } else if (char == SPACE) {
            const path = slice[0..counter];
            if (path.len == 0) {
                return ParseErr.Malformed;
            }
            return .{ .path = path, .read = (counter + 1) };
        }
        return ParseErr.Malformed;
    }
    return ParseErr.Malformed;
}

// ----------------------
// Parsing HTTP responses
// ----------------------

pub const Response = struct {
    status: u16,
    reason: []u8,
    headers: std.ArrayList(Header),
    body: []u8,

    /// Construct a new `Response` from its parts.
    /// Use an empty `&str` to create a `Respose` with no reason phrase
    /// Use an empty `&str` to create a `Respose` with no body
    pub fn new(status: u16, reason: []u8, headers: std.ArrayList(Header), body: []u8) Response {
        return Response{ .status = status, .reason = reason, .headers = headers, .body = body };
    }

    pub fn bytes(self: Response, alloc: std.mem.Allocator) std.ArrayList(u8) {
        var bytesVec = std.ArrayList(u8).init(alloc);
        if (self.reason.len == 0) {
            bytesVec.writer().print("HTTP/1.1 {}\r\n", .{self.status}) catch unreachable;
        } else {
            bytesVec.writer().print("HTTP/1.1 {} {s}\r\n", .{ self.status, self.reason }) catch unreachable;
        }
        for (self.headers.items) |header| {
            bytesVec.appendSlice(header.name) catch unreachable;
            bytesVec.appendSlice(": ") catch unreachable;
            bytesVec.appendSlice(header.val) catch unreachable;
            bytesVec.appendSlice("\r\n") catch unreachable;
        }
        bytesVec.appendSlice("\r\n") catch unreachable;
        bytesVec.appendSlice(self.body) catch unreachable;
        return bytesVec;
    }

    pub fn parse(slice: []u8, alloc: std.mem.Allocator) anyerror!Response {
        _ = try Response.parseHttpVersion(slice);
        var offset: usize = 9;
        const status = try parseStatus(slice[offset..]);
        offset += status.read;
        const headers = try parseHeaders(slice[offset..], alloc);
        offset += headers.read;
        return Response.new(status.status, status.reason, headers.headers, slice[offset..]);
    }

    fn parseHttpVersion(slice: []u8) ParseErr!HttpVer {
        if (std.mem.eql(u8, slice[0..9], "HTTP/1.1 ")) {
            return HttpVer.One;
        } else if (std.mem.eql(u8, slice[0..9], "HTTP/2.0 ")) {
            return HttpVer.Two;
        } else {
            return ParseErr.Malformed;
        }
    }

    pub fn deinit(self: Response) void {
        self.headers.deinit();
    }
};

fn arrayContains(arr: []const u8, value: u8) bool {
    for (arr) |num| {
        if (value == num) {
            return true;
        }
    }
    return false;
}

//parses the method and removes white space after it
//Returns the status, reason phrase, and bytes read
fn parseStatus(slice: []u8) ParseErr!struct { status: u16, reason: []u8, read: usize } {
    for (slice, 0..) |char, counter| {
        // a number character
        if (arrayContains(&numberChar, char)) {
            continue;
        } else if (char == SPACE) {
            const status = slice[0..counter];
            if (status.len > 3) {
                return ParseErr.Malformed;
            }
            //there is a reason phrase
            if (arrayContains(&alphaChar, slice[counter + 1])) {
                const reason = try parseReason(slice[(counter + 1)..]);
                //SAFETY: already checked that the input is valid ascii
                return .{ .status = std.fmt.parseInt(u16, status, 10) catch unreachable, .reason = reason.reason, .read = counter + 1 + reason.read };
                //there is no reason phrase
            } else if (slice[counter + 1] == CR) {
                if (slice[counter + 2] != LF) {
                    return ParseErr.Malformed;
                }
                return .{ .status = std.fmt.parseInt(u16, status, 10) catch unreachable, .reason = "", .read = counter + 3 };
            } else {
                return ParseErr.Malformed;
            }
        } else if (char == CR) {
            const status = slice[0..counter];
            if (status.len > 3) {
                return ParseErr.Malformed;
            }
            if (slice[counter + 1] != LF) {
                return ParseErr.Malformed;
            }
            return .{ .status = std.fmt.parseInt(u16, status, 10) catch unreachable, .reason = "", .read = counter + 2 };
        } else {
            return ParseErr.Malformed;
        }
    }
    return ParseErr.Malformed;
}

fn parseReason(slice: []u8) ParseErr!struct { reason: []u8, read: usize } {
    for (slice, 0..) |char, counter| {
        if (HEADER_NAME_SAFE[char]) {
            continue;
        } else if (char == CR) {
            const reason = slice[0..counter];
            if (slice[counter + 1] != LF) {
                return ParseErr.Malformed;
            }
            return .{ .reason = reason, .read = counter + 2 };
        } else {
            return ParseErr.Malformed;
        }
    }
    return ParseErr.Malformed;
}

// ---------------------
//         tests
// ---------------------

test "test request parsing" {
    const REQ = @constCast("GET /wp-content/uploads/pink.jpg HTTP/1.1\r\nHost: www.kittyhell.com\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; ja-JP-mac; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 Pathtraq/0.9\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: ja,en-us;q=0.7,en;q=0.3\r\nAccept-Encoding: gzip,deflate\r\nAccept-Charset: Shift_JIS,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 115\r\nConnection: keep-alive\r\nCookie: wp_ozh_wsa_visits=2; wp_ozh_wsa_visit_lasttime=xxxxxxxxxx; __utma=xxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.x; __utmz=xxxxxxxxx.xxxxxxxxxx.x.x.utmccn=(referral)|utmcsr=reader.livedoor.com|utmcct=/reader/|utmcmd=referral|padding=under256\r\n\r\n");

    const allocator = testing.allocator;
    const parsed = try Request.parse(REQ, allocator);
    defer parsed.deinit();
    try std.testing.expect(parsed.method == Method.Get);
    try std.testing.expect(std.mem.eql(u8, parsed.path, "/wp-content/uploads/pink.jpg"));
    try std.testing.expect(parsed.headers.items.len == 9);
}

test "test request to bytes" {
    const REQ = @constCast("GET /wp-content/uploads/pink.jpg HTTP/1.1\r\nHost: www.kittyhell.com\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; ja-JP-mac; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 Pathtraq/0.9\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: ja,en-us;q=0.7,en;q=0.3\r\nAccept-Encoding: gzip,deflate\r\nAccept-Charset: Shift_JIS,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 115\r\nConnection: keep-alive\r\nCookie: wp_ozh_wsa_visits=2; wp_ozh_wsa_visit_lasttime=xxxxxxxxxx; __utma=xxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.x; __utmz=xxxxxxxxx.xxxxxxxxxx.x.x.utmccn=(referral)|utmcsr=reader.livedoor.com|utmcct=/reader/|utmcmd=referral|padding=under256\r\n\r\n");

    const allocator = testing.allocator;
    const parsed = try Request.parse(REQ, allocator);
    defer parsed.deinit();
    const bytes = parsed.bytes(allocator);
    defer bytes.deinit();
    try std.testing.expect(std.mem.eql(u8, bytes.items, REQ));
}

test "test response parsing" {
    const RES = @constCast("HTTP/1.1 200 OK\r\nDate: Wed, 21 Oct 2015 07:28:00 GMT\r\nHost: www.kittyhell.com\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; ja-JP-mac; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 Pathtraq/0.9\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: ja,en-us;q=0.7,en;q=0.3\r\nAccept-Encoding: gzip,deflate\r\nAccept-Charset: Shift_JIS,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 115\r\nConnection: keep-alive\r\nCookie: wp_ozh_wsa_visits=2; wp_ozh_wsa_visit_lasttime=xxxxxxxxxx; __utma=xxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.x; __utmz=xxxxxxxxx.xxxxxxxxxx.x.x.utmccn=(referral)|utmcsr=reader.livedoor.com|utmcct=/reader/|utmcmd=referral|padding=under256\r\n\r\n");

    const allocator = testing.allocator;
    const parsed = try Response.parse(RES, allocator);
    defer parsed.deinit();
    try std.testing.expect(parsed.status == 200);
    try std.testing.expect(std.mem.eql(u8, parsed.reason, "OK"));
    try std.testing.expect(parsed.headers.items.len == 10);
}

test "test response to bytes" {
    const RES = @constCast("HTTP/1.1 200 OK\r\nDate: Wed, 21 Oct 2015 07:28:00 GMT\r\nHost: www.kittyhell.com\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; ja-JP-mac; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 Pathtraq/0.9\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: ja,en-us;q=0.7,en;q=0.3\r\nAccept-Encoding: gzip,deflate\r\nAccept-Charset: Shift_JIS,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 115\r\nConnection: keep-alive\r\nCookie: wp_ozh_wsa_visits=2; wp_ozh_wsa_visit_lasttime=xxxxxxxxxx; __utma=xxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.x; __utmz=xxxxxxxxx.xxxxxxxxxx.x.x.utmccn=(referral)|utmcsr=reader.livedoor.com|utmcct=/reader/|utmcmd=referral|padding=under256\r\n\r\n");

    const allocator = testing.allocator;
    const parsed = try Response.parse(RES, allocator);
    defer parsed.deinit();
    const bytes = parsed.bytes(allocator);
    defer bytes.deinit();
    try std.testing.expect(std.mem.eql(u8, bytes.items, RES));
}
