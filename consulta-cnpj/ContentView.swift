import SwiftUI

struct ContentView: View {
    @State private var cnpj: String = ""
    @State private var companyInfo: [String: Any] = [:]
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            // Título
            Text("Consulta CNPJ")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)

            // Campo de entrada
            TextField("Digite o CNPJ (ex: 12.345.678/0001-95)", text: $cnpj)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: cnpj) { newValue in
                    cnpj = formatCNPJ(input: newValue)
                }

            Button("Buscar empresa") {
                fetchCompanyInfo(for: cnpj)
            }
            .frame(height: 50)
            .buttonStyle(.borderedProminent)

            // Exibição de erros
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            // Exibição das informações
            if !companyInfo.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // Informações básicas
                        Section(header: Text("Informações Básicas").font(.headline)) {
                            InfoRow(label: "Nome", value: companyInfo["nome"] as? String)
                            InfoRow(label: "Nome Fantasia", value: companyInfo["fantasia"] as? String)
                            InfoRow(label: "Situação", value: companyInfo["situacao"] as? String)
                            InfoRow(label: "Tipo", value: companyInfo["tipo"] as? String)
                            InfoRow(label: "Data de Abertura", value: companyInfo["abertura"] as? String)
                            InfoRow(label: "Capital Social", value: companyInfo["capital_social"] as? String)
                        }

                        // Endereço
                        Section(header: Text("Endereço").font(.headline)) {
                            InfoRow(label: "Logradouro", value: companyInfo["logradouro"] as? String)
                            InfoRow(label: "Número", value: companyInfo["numero"] as? String)
                            InfoRow(label: "Cidade", value: companyInfo["municipio"] as? String)
                            InfoRow(label: "Estado", value: companyInfo["uf"] as? String)
                            InfoRow(label: "CEP", value: companyInfo["cep"] as? String)
                        }

                        // Contato
                        Section(header: Text("Contato").font(.headline)) {
                            InfoRow(label: "Telefone", value: companyInfo["telefone"] as? String)
                            InfoRow(label: "Email", value: companyInfo["email"] as? String)
                        }

                        // Sócios
                        if let socios = companyInfo["qsa"] as? [[String: Any]] {
                            Section(header: Text("Sócios").font(.headline)) {
                                ForEach(socios.indices, id: \.self) { index in
                                    let socio = socios[index]
                                    InfoRow(label: "Nome", value: socio["nome"] as? String)
                                    InfoRow(label: "Cargo", value: socio["qual"] as? String)
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    func fetchCompanyInfo(for cnpj: String) {
        guard !cnpj.isEmpty, cnpj.count == 14 else {
            errorMessage = "Por favor, insira um CNPJ válido com 14 dígitos."
            return
        }

        let urlString = "https://www.receitaws.com.br/v1/cnpj/\(cnpj)"
        guard let url = URL(string: urlString) else {
            errorMessage = "URL inválida."
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Nenhum dado recebido."
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.companyInfo = json
                        self.errorMessage = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Falha ao analisar os dados."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }

    func resetSearch() {
        cnpj = ""
        companyInfo = [:]
        errorMessage = nil
    }

    func formatCNPJ(input: String) -> String {
        let filtered = input.filter { "0123456789".contains($0) }
        return String(filtered.prefix(14)) // Limita a 14 dígitos
    }
}

struct InfoRow: View {
    let label: String
    let value: String?

    @State private var copiedText: Bool = false

    var body: some View {
        HStack {
            Text("\(label):")
                .fontWeight(.bold)
            Spacer()
            Text(copiedText ? "Copiado" : (value ?? "N/A"))
                .onTapGesture {
                    copyToClipboard(value: value)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

        }
    }

    private func copyToClipboard(value: String?) {
        guard let value = value else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        copiedText = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            copiedText = false
        }
    }
}

@main
struct CNPJApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(systemSymbolName: "building.2.crop.circle", accessibilityDescription: "CNPJ Info")
        statusBarItem?.button?.action = #selector(togglePopover)
        statusBarItem?.button?.target = self

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 450)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
    }

    @objc func togglePopover() {
        guard let button = statusBarItem?.button else { return }

        if popover?.isShown == true {
            popover?.performClose(nil)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
