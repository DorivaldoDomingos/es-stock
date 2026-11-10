# Prepara o computador para servir a API ao telemóvel na mesma rede Wi-Fi.
# Executar numa janela do PowerShell aberta COMO ADMINISTRADOR:
#   powershell -ExecutionPolicy Bypass -File scripts\preparar_rede_local.ps1

$porta = 3000
$nomeRegra = "ES Stock API"

# 1. abre a porta da API na firewall do Windows (só na rede privada)
$existe = Get-NetFirewallRule -DisplayName $nomeRegra -ErrorAction SilentlyContinue
if (-not $existe) {
    New-NetFirewallRule -DisplayName $nomeRegra -Direction Inbound -Action Allow `
        -Protocol TCP -LocalPort $porta -Profile Private | Out-Null
    Write-Host "Regra de firewall criada para a porta $porta (rede privada)."
} else {
    Write-Host "A regra de firewall já existia."
}

# 2. mostra os endereços do computador na rede
Write-Host ""
Write-Host "Endereços deste computador (use o do Wi-Fi no telemóvel):"
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } |
    ForEach-Object { Write-Host ("  http://{0}:{1}   ({2})" -f $_.IPAddress, $porta, $_.InterfaceAlias) }

Write-Host ""
Write-Host "No telemóvel: ecrã de login, rodapé 'Servidor', e escreva o endereço acima."
Write-Host "Se o Windows pedir para classificar a rede, escolha 'Privada'."
