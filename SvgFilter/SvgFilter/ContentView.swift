import SwiftUI
import WebKit
import ZIPFoundation

struct SWebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        nsView.load(request)
    }
}

@available(macOS 12.0, *)
struct ContentView: View {
    @State private var fileName: String = "拖动或选择文件"
    @State var oriFile: String = "www"
    @State var ColorString: String = "#ffffff"
  
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("过滤色值")
                    
                    HStack {
                        if #available(macOS 12.0, *) {
                            TextField(text: $ColorString) {
                                
                            }.focused($isTextFieldFocused)
                        } else {
                            // Fallback on earlier versions
                        }
                        Button(action: confimClick, label: {
                            Text("确认")
                        })
                    }
                    
                }.frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                
                Spacer()
            }

            HStack {
                ZStack {
                    Text(fileName)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                            if let provider = providers.first {
                                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                                        DispatchQueue.main.async {
                                            self.fileName = url.lastPathComponent
                                        }
                                    }
                                }
                                return true
                            }
                            return false
                        }
                }
                
                SWebView(url: URL(string: oriFile)!)
                            .edgesIgnoringSafeArea(.all)  // 如果希望 WebView 填满整个屏幕
            }

            Spacer()
            
            HStack {
                Button(action: selectFile) {
                    Text("选择文件")
                }
                .padding()
                
                Button(action: selectFile) {
                    Text("导出文件")
                }
                .padding()
            }
        }
        .frame(width: 400, height: 300)
    }

    private func confimClick() {
        isTextFieldFocused = false
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.fileName = url.lastPathComponent
                if let url = unzipFile(at: url) {
                    if let artParentUrl = findAndUnzipFile(at: url) {
                        let contrivUrl = artParentUrl.appendingPathComponent("/art/contourv")
                    }
                }
            }
        }
        self.oriFile = "https://www.baidu.com"
    }
    
    func clearDirectory(at url: URL) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])

        for file in contents {
            try fileManager.removeItem(at: file)
        }
    }
    
    func unzipFile(at url: URL) -> URL? {
        do {
            let fileManager = FileManager()
            let documentsURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            try clearDirectory(at: documentsURL)
            
            let destinationURL = documentsURL.appendingPathComponent(url.deletingPathExtension().lastPathComponent)

            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: url, to: destinationURL)
            print("解压成功: \(destinationURL.path)")
            
            return destinationURL
        } catch {
            print("解压失败: \(error)")
            return nil
        }
    }
    
    func findAndUnzipFile(at url: URL) -> URL? {
        let fileManager = FileManager.default
        
        do {
            // 获取路径下的所有子文件夹
            let subdirectories = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            for subdirectory in subdirectories {
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: subdirectory.path, isDirectory: &isDirectory), isDirectory.boolValue {
                    // 在子文件夹中寻找 zip 文件
                    let files = try fileManager.contentsOfDirectory(at: subdirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                    
                    for file in files {
                        if file.pathExtension == "zip" {
                            let fileName = getFileNameWithoutExtension(from: file)
                            
                            // 找到 zip 文件并解压
                            let destinationURL = subdirectory.appendingPathComponent(fileName)
                            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                            
                            try fileManager.unzipItem(at: file, to: destinationURL)
                            print("Successfully unzipped file to \(destinationURL.path)")
                            return destinationURL
                        }
                    }
                }
            }
            print("No zip file found in the directory.")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getFileNameWithoutExtension(from url: URL) -> String {
        return url.deletingPathExtension().lastPathComponent
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(macOS 12.0, *) {
            ContentView()
        } else {
            // Fallback on earlier versions
        }
    }
}
