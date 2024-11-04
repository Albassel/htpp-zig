const std = @import("std");
const root = @import("root.zig");

pub fn main() !void {
    const REQ = @constCast("GET /wp-content/uploads/pink.jpg HTTP/1.1\r\nHost: www.kittyhell.com\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; ja-JP-mac; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 Pathtraq/0.9\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: ja,en-us;q=0.7,en;q=0.3\r\nAccept-Encoding: gzip,deflate\r\nAccept-Charset: Shift_JIS,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 115\r\nConnection: keep-alive\r\nCookie: wp_ozh_wsa_visits=2; wp_ozh_wsa_visit_lasttime=xxxxxxxxxx; __utma=xxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.x; __utmz=xxxxxxxxx.xxxxxxxxxx.x.x.utmccn=(referral)|utmcsr=reader.livedoor.com|utmcct=/reader/|utmcmd=referral|padding=under256\r\n\r\n");

    const RES = @constCast("HTTP/1.1 200 OK\r\nDate: Wed, 21 Oct 2015 07:28:00 GMT\r\nHost: www.kittyhell.com\r\nUser-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; ja-JP-mac; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 Pathtraq/0.9\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: ja,en-us;q=0.7,en;q=0.3\r\nAccept-Encoding: gzip,deflate\r\nAccept-Charset: Shift_JIS,utf-8;q=0.7,*;q=0.7\r\nKeep-Alive: 115\r\nConnection: keep-alive\r\nCookie: wp_ozh_wsa_visits=2; wp_ozh_wsa_visit_lasttime=xxxxxxxxxx; __utma=xxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.xxxxxxxxxx.x; __utmz=xxxxxxxxx.xxxxxxxxxx.x.x.utmccn=(referral)|utmcsr=reader.livedoor.com|utmcct=/reader/|utmcmd=referral|padding=under256\r\n\r\n");

    //const config = .{ .safety = true };
    //var gpa = std.heap.GeneralPurposeAllocator(config){};
    //defer _ = gpa.deinit();
    //const allocator = gpa.allocator();

    //const allocator = std.heap.page_allocator;

    const allocator = std.heap.c_allocator;

    //var buf = [_]u8{0} ** 10000;
    //var fba = std.heap.FixedBufferAllocator.init(buf[0..]);
    //const allocator = fba.allocator();

    // Benchmarking request parsing

    // Warmup period
    for (0..1000) |_| {
        const parsed = try root.Request.parse(REQ, allocator);
        defer parsed.deinit();
    }
    const reqStart = std.time.nanoTimestamp();
    for (0..1000) |_| {
        var parsed = try root.Request.parse(REQ, allocator);
        defer parsed.deinit();
    }
    const reqEnd = std.time.nanoTimestamp();
    std.debug.print("It took {} ns to parse 1000 requests\n", .{(reqEnd - reqStart)});

    // Benchmarking response parsing

    // Warmup period
    for (0..1000) |_| {
        const parsed = try root.Response.parse(RES, allocator);
        defer parsed.deinit();
    }
    const resStart = std.time.nanoTimestamp();
    for (0..1000) |_| {
        const parsed = try root.Response.parse(RES, allocator);
        defer parsed.deinit();
    }
    const resEnd = std.time.nanoTimestamp();
    std.debug.print("It took {} ns to parse 1000 responses\n", .{(resEnd - resStart)});
}
