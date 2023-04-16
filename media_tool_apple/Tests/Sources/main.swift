import Foundation

// Download file from url and save to local directory 
func downloadFile(url: String, path: String) async throws {
  let url: URL = URL(string: url)!
  let (data, _) = try await URLSession.shared.data(from: url)
  try data.write(to: URL(fileURLWithPath: path))
}

// Fetch all video files
for video in videoUrls {
  let path: String = "./media/\(video.key)"
  if !FileManager.default.fileExists(atPath: path) {
    try await downloadFile(url: video.value, path: path)
  }
}

// Run video tests
try await testAllVideos()