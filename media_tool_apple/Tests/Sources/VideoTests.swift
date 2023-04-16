
// Video files used by tests
let videoUrls: [String : String] = [
  // Big Buck Bunny VP9 - https://test-videos.co.uk/bigbuckbunny/webm-vp9
  // "bigbuckbunny_vp9_640x360.webm": "https://test-videos.co.uk/vids/bigbuckbunny/webm/vp9/360/Big_Buck_Bunny_360_10s_1MB.webm",
  // "bigbuckbunny_vp9_1280x720.webm": "https://test-videos.co.uk/vids/bigbuckbunny/webm/vp9/720/Big_Buck_Bunny_720_10s_2MB.webm",

  // Big Buck Bunny H.264 - https://test-videos.co.uk/bigbuckbunny/mp4-h264
  // "bigbuckbunny_h264_640x360.mp4": "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4",
  // "bigbuckbunny_h264_1280x720.mp4": "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_2MB.mp4",

  // Big Buck Bunny H.265 - https://test-videos.co.uk/bigbuckbunny/mp4-h265
  // "bigbuckbunny_h265_640x360.mp4": "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h265/360/Big_Buck_Bunny_360_10s_1MB.mp4",
  "bigbuckbunny_h265_1280x720.mp4": "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h265/720/Big_Buck_Bunny_720_10s_2MB.mp4",

  // Portrait Video H.264
  // "sunset_h264_portrait_480_848.mp4": "",

  // Jellyfish - https://test-videos.co.uk/jellyfish/mp4-h265
  // Chromium test videos - https://github.com/chromium/chromium/tree/master/media/test/data
  // WebM test videos - https://github.com/webmproject/libwebm/tree/main/testing/testdata
]

// Compress and test all videos
func testAllVideos() async throws {
  for video in videoUrls {
    try await VideoTool.compress(path: "./media/\(video.key)")
  }
}