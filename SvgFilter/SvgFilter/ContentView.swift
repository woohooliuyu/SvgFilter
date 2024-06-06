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

struct ContentView: View {
    @State private var fileName: String = "拖动或选择文件"
    @State var oriFile: String = "www"
    @State var CString: String = "255"
    @State var MString: String = "255"
    @State var YString: String = "255"
    @State var KString: String = "255"
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("C")
                    if #available(macOS 12.0, *) {
                        TextField(text: $CString) {
                            
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                VStack {
                    Text("M")
                    if #available(macOS 12.0, *) {
                        TextField(text: $MString) {
                            
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                VStack {
                    Text("Y")
                    if #available(macOS 12.0, *) {
                        TextField(text: $YString) {
                            
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                VStack {
                    Text("K")
                    if #available(macOS 12.0, *) {
                        TextField(text: $KString) {
                            
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }

            HStack {
                ZStack {
                    SWebView(url: URL(string: oriFile)!)
                                .edgesIgnoringSafeArea(.all)  // 如果希望 WebView 填满整个屏幕
//                    Text(fileName)
//                        .padding()
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Color.gray.opacity(0.2))
//                        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
//                            if let provider = providers.first {
//                                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
//                                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
//                                        DispatchQueue.main.async {
//                                            self.fileName = url.lastPathComponent
//                                        }
//                                    }
//                                }
//                                return true
//                            }
//                            return false
//                        }
                }
            }

            Spacer()
            
            HStack {
                Button(action: selectFile) {
                    Text("选择文件")
                }
                .padding()
                
                Button(action: selectFile) {
                    Text("处理文件")
                }
                .padding()
            }
        }
        .frame(width: 400, height: 300)
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.fileName = url.lastPathComponent
            }
        }
        self.oriFile = "https://www.baidu.com"
    }
    
    func unzipFile(at url: URL) {
        do {
            let fileManager = FileManager()
            let documentsURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let destinationURL = documentsURL.appendingPathComponent(url.deletingPathExtension().lastPathComponent)

            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: url, to: destinationURL)
            print("解压成功: \(destinationURL.path)")
        } catch {
            print("解压失败: \(error)")
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
